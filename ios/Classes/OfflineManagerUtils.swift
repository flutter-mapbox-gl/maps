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
    static func downloadRegion(
        regionData: OfflineRegionData,
        result: FlutterResult,
        registrar: FlutterPluginRegistrar
    ) {
        // Prepare channel
        let channelName = "downloadOfflineRegion_\(regionData.id)"
        let channelHandler = OfflineChannelHandler(
            messenger: registrar.messenger(),
            channelName: channelName
        )
        // Setup the OfflineStorage
        let storage = MGLOfflineStorage.shared
        // Define the offline region
        let definition = generateRegionDefinition(args: regionData)
        // Prepare metadata
        let metadata = prepareMetadata(args: regionData)
        // Tracker of result
        var isComplete = false
        
        // Download region
    }
    
    static func regionsList(result: FlutterResult) {
//        let offlineStorage = MGLOfflineStorage.shared.pa
        result("[]")
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
