//
//  OfflineManagerUtils.swift
//  location
//
//  Created by Patryk on 02/06/2020.
//

import Flutter
import Foundation
import Mapbox

class OfflineManagerUtils {
    static var activeDownloaders: [Int: OfflinePackDownloader] = [:]
    
    static func downloadRegion(
        regionData: OfflineRegionData,
        result: @escaping FlutterResult,
        registrar: FlutterPluginRegistrar
    ) {
        // Prepare channel
        let channelName = "downloadOfflineRegion_\(regionData.id)"
        let channelHandler = OfflineChannelHandler(
            messenger: registrar.messenger(),
            channelName: channelName
        )
        // Define the offline region
        let definition = generateRegionDefinition(args: regionData)
        // Prepare metadata
        let metadata = prepareMetadata(args: regionData)
        // Prepare downloader
        let downloader = OfflinePackDownloader(
            result: result,
            channelHandler: channelHandler,
            region: definition,
            metadata: metadata,
            regionId: regionData.id
        )
        // Save downloader so it does not get deallocated
        activeDownloaders[regionData.id] = downloader
        
        // Download region
        downloader.download()
    }
    
    static func regionsList(result: @escaping FlutterResult) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let packs = offlineStorage.packs else {
            result("[]")
            return
        }
        let regionsArgs = packs.compactMap { pack -> [String: Any]? in
            guard let definition = pack.region as? MGLTilePyramidOfflineRegion,
                let regionArgs = OfflineRegionData.fromOfflineRegion(definition, metadata: pack.context),
                let jsonData = regionArgs.toJsonString().data(using: .utf8),
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
                let jsonDict = jsonObject as? [String: Any]
                else { return nil }
            return jsonDict
        }
        guard let regionsArgsJsonData = try? JSONSerialization.data(withJSONObject: regionsArgs),
            let regionsArgsJsonString = String(data: regionsArgsJsonData, encoding: .utf8)
            else {
                result(FlutterError(code: "RegionListError", message: nil, details: nil))
                return
        }
        result(regionsArgsJsonString)
    }
    
    static func deleteRegion(result: @escaping FlutterResult, id: Int) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let pacs = offlineStorage.packs else { return }
        let packToRemove = pacs.compactMap({ pack -> (MGLOfflinePack, Int)? in
            let contextJsonObject = try? JSONSerialization.jsonObject(with: pack.context)
            let contextJsonDict = contextJsonObject as? [String: Any]
            if let id = contextJsonDict?["id"] as? Int {
                return (pack, id)
            } else {
                return nil
            }
        }).first(where: { $0.1 == id })?.0
        if let packToRemoveUnwrapped = packToRemove {
            offlineStorage.removePack(packToRemoveUnwrapped) { error in
                if let error = error {
                    result(FlutterError(
                        code: "DeleteRegionError",
                        message: error.localizedDescription,
                        details: nil
                    ))
                } else {
                    result(nil)
                }
            }
        } else {
            result(FlutterError(
                code: "DeleteRegionError",
                message: "There is no region with given id to delete",
                details: nil
            ))
        }
    }
    
    /// Removes downloader from cache so it's memory can be deallocated
    static func releaseDownloader(id: Int) {
        activeDownloaders.removeValue(forKey: id)
    }
    
    private static func generateRegionDefinition(
        args: OfflineRegionData
    ) -> MGLTilePyramidOfflineRegion {
        // Create a bounding box for the offline region
        return MGLTilePyramidOfflineRegion(
            styleURL: args.mapStyleUrl,
            bounds: args.getBounds(),
            fromZoomLevel: args.minZoom,
            toZoomLevel: args.maxZoom
        )
    }
    
    private static func prepareMetadata(args: OfflineRegionData) -> Data {
        // Make copy of received metadata
        var metadata = args.metadata ?? [String: Any]()
        metadata["id"] = args.id
        let jsonData = try? JSONSerialization.data(withJSONObject: metadata, options: [])
        return jsonData ?? Data()
    }
}
