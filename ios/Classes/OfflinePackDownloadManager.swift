//
//  OfflinePackDownloadManager.swift
//  location
//
//  Created by Patryk on 03/06/2020.
//

import Flutter
import Foundation
import Mapbox

class OfflinePackDownloader {
    // MARK: Properties
    private let result: FlutterResult
    private let channelHandler: OfflineChannelHandler
    private let regionDefinition: OfflineRegionDefinition
    private let metadata: [String: Any]

    /// Currently managed pack
    private var pack: MGLOfflinePack?
    
    /// This variable is set to true when this downloader has finished downloading and called the result method. It is used to prevent
    /// the result method being called multiple times
    private var isCompleted = false
    
    // MARK: Initializers
    init(result: @escaping FlutterResult, channelHandler: OfflineChannelHandler, regionDefintion: OfflineRegionDefinition, metadata: [String: Any]) {
        self.result = result
        self.channelHandler = channelHandler
        self.regionDefinition = regionDefintion
        self.metadata = metadata

        setupNotifications()
    }
    
    deinit {
        print("Removing offline pack notification observers")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public methods
    func download() -> Int {
        let storage = MGLOfflineStorage.shared
        // While the Android SDK generates a region ID in createOfflineRegion, the iOS
        // SDK does not have this feature. Therefore, we generate a region ID here.
        let id = UUID().hashValue
        let regionData = OfflineRegion(id: id, metadata: metadata, definition: regionDefinition)
        let tilePyramidRegion = regionDefinition.toMGLTilePyramidOfflineRegion()
        storage.addPack(for: tilePyramidRegion, withContext: regionData.prepareContext()) { [weak self] (pack, error) in
            if let pack = pack {
                self?.onPackCreated(pack: pack)
            } else {
                self?.onPackCreationError(error: error)
            }
        }
        return id
    }
    
    // MARK: Pack management
    private func onPackCreated(pack: MGLOfflinePack) {
        if let region = OfflineRegion.fromOfflinePack(pack),
           let regionData = try? JSONSerialization.data(withJSONObject: region.toDictionary()) {
            // Start downloading
            self.pack = pack
            pack.resume()
            // Provide region with generated
            result(String(data: regionData, encoding: .utf8))
            channelHandler.onStart()
        } else {
            onPackCreationError(error: OfflinePackError.InvalidPackData)
        }
    }
    
    private func onPackCreationError(error: Error?) {
        // Reset downloading state
        channelHandler.onError(
            errorCode: "mapboxInvalidRegionDefinition",
            errorMessage: error?.localizedDescription,
            errorDetails: nil
        )
        result(FlutterError(
            code: "mapboxInvalidRegionDefinition",
            message: error?.localizedDescription,
            details: nil
        ))
    }
    
    // MARK: Progress obseration
    @objc private func onPackDownloadProgress(notification: NSNotification) {
        // Verify if correct pack is checked
        guard let pack = notification.object as? MGLOfflinePack,
            verifyPack(pack: pack) else { return }
        // Calculate progress of downloading
        let packProgress = pack.progress
        let downloadProgress = calculateDownloadingProgress(
            requiredResourceCount: packProgress.countOfResourcesExpected,
            completedResourceCount: packProgress.countOfResourcesCompleted
        )
        // Check if downloading is complete
        if (pack.state == .complete) {
            print("Region downloaded successfully")
            // set download state to inactive
            // This can be called multiple times but result can only be called once. We use this
            // check to ensure that
            guard !isCompleted else { return }
            isCompleted = true
            channelHandler.onSuccess()
            result(nil)
            if let region = OfflineRegion.fromOfflinePack(pack) {
                OfflineManagerUtils.releaseDownloader(id:region.id)
            }
        } else {
            print("Region download progress \(downloadProgress)")
            channelHandler.onProgress(progress: downloadProgress)
        }
    }
    
    @objc private func onPackDownloadError(notification: NSNotification) {
        guard let pack = notification.object as? MGLOfflinePack,
            verifyPack(pack: pack) else { return }
        let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError
        print("Pack download error: \(String(describing: error?.localizedDescription))")
        // set download state to inactive
        isCompleted = true
        channelHandler.onError(
            errorCode: "Downloading error",
            errorMessage: error?.localizedDescription,
            errorDetails: nil
        )
        result(FlutterError(
            code: "Downloading error",
            message: error?.localizedDescription,
            details: nil
        ))
        if let region = OfflineRegion.fromOfflinePack(pack) {
            OfflineManagerUtils.deleteRegion(result: result, id: region.id)
            OfflineManagerUtils.releaseDownloader(id:region.id)
        }
    }
    
    @objc private func onMaximumAllowedMapboxTiles(notification: NSNotification) {
        guard let pack = notification.object as? MGLOfflinePack,
            verifyPack(pack: pack) else { return }
        let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount]
        as AnyObject).uint64Value ?? 0
        print("Mapbox tile count limit exceeded: \(maximumCount)")
        // set download state to inactive
        isCompleted = true
        channelHandler.onError(
            errorCode: "mapboxTileCountLimitExceeded",
            errorMessage: "Mapbox tile count limit exceeded: \(maximumCount)",
            errorDetails: nil
        )
        result(FlutterError(
            code: "mapboxTileCountLimitExceeded",
            message: "Mapbox tile count limit exceeded: \(maximumCount)",
            details: nil
        ))
        if let region = OfflineRegion.fromOfflinePack(pack) {
            OfflineManagerUtils.deleteRegion(result: result, id: region.id)
            OfflineManagerUtils.releaseDownloader(id: region.id)
        }
    }
    
    // MARK: Util methods
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPackDownloadProgress(notification:)),
            name: NSNotification.Name.MGLOfflinePackProgressChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPackDownloadError(notification:)),
            name: NSNotification.Name.MGLOfflinePackError,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMaximumAllowedMapboxTiles(notification:)),
            name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached,
            object: nil
        )
    }
    
    /// Since NotificationCenter will send notifications about all packs downloads we need to make sure we only handle packs
    /// managed by this downloader. So this method checks if the pack we got from a notification is the same as the pack being
    /// managed by this downloader and if it is it returns true. Otherwise it returns false
    private func verifyPack(pack: MGLOfflinePack) -> Bool {
        guard let currentlyManagedPack = self.pack else {
            // No pack is being managed yet
            return false
        }
        // We can tell whether 2 packs are the same by comparing metadata we assigned earlier
        return pack.context == currentlyManagedPack.context
    }
    
    private func calculateDownloadingProgress(
        requiredResourceCount: UInt64,
        completedResourceCount: UInt64
    ) -> Double {
        return requiredResourceCount > 0
            ? 100.0 * Double(completedResourceCount) / Double(requiredResourceCount)
            : 0.0
    }
}

enum OfflinePackError: Error {
    case InvalidPackData
}
