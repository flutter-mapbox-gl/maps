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
        definition: OfflineRegionDefinition,
        metadata: [String: Any],
        result: @escaping FlutterResult,
        registrar: FlutterPluginRegistrar,
        channelHandler: OfflineChannelHandler
    ) {
        // Prepare downloader
        let downloader = OfflinePackDownloader(
            result: result,
            channelHandler: channelHandler,
            regionDefintion: definition,
            metadata: metadata
        )

        // Download region
        let id = downloader.download()
        // retain downloader by its generated id
        activeDownloaders[id] = downloader
    }

    static func regionsList(result: @escaping FlutterResult) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let packs = offlineStorage.packs else {
            result("[]")
            return
        }
        let regionsArgs = packs.compactMap { pack in
            return OfflineRegion.fromOfflinePack(pack)?.toDictionary()
        }
        guard let regionsArgsJsonData = try? JSONSerialization.data(withJSONObject: regionsArgs),
            let regionsArgsJsonString = String(data: regionsArgsJsonData, encoding: .utf8)
            else {
                result(FlutterError(code: "RegionListError", message: nil, details: nil))
                return
        }
        result(regionsArgsJsonString)
    }

    static func setOfflineTileCountLimit(result: @escaping FlutterResult, maximumCount: UInt64) {
        let offlineStorage = MGLOfflineStorage.shared
        offlineStorage.setMaximumAllowedMapboxTiles(maximumCount)
        result(nil)
    }

    static func deleteRegion(result: @escaping FlutterResult, id: Int) {
        let offlineStorage = MGLOfflineStorage.shared
        guard let pacs = offlineStorage.packs else { return }
        let packToRemove = pacs.first(where: { pack -> Bool in
            let contextJsonObject = try? JSONSerialization.jsonObject(with: pack.context)
            let contextJsonDict = contextJsonObject as? [String: Any]
            if let regionId = contextJsonDict?["id"] as? Int {
                return regionId == id
            } else {
                return false
            }
        })
        if let packToRemoveUnwrapped = packToRemove {
            // deletion is only safe if the download is suspended
            packToRemoveUnwrapped.suspend()
            OfflineManagerUtils.releaseDownloader(id: id)

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
}
