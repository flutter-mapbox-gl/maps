//
//  OfflineRegionData.swift
//  location
//
//  Created by Patryk on 02/06/2020.
//

import Foundation
import Mapbox

class OfflineRegion {
    let id: Int
    let bounds: [[Double]]
    let metadata: [String: Any]?
    let mapStyleUrl: URL
    let minZoom: Double
    let maxZoom: Double

    init(id: Int, bounds: [[Double]], metadata: [String: Any]?, mapStyleUrl: URL, minZoom: Double, maxZoom: Double) {
        self.id = id
        self.bounds = bounds
        self.metadata = metadata
        self.mapStyleUrl = mapStyleUrl
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }

    func prepareContext() -> Data {
        let context = ["metadata": metadata ?? [], "id": id] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: context, options: [])
        return jsonData ?? Data()
    }
    
    func toJsonString() -> String {
        let formatString = #"{"id":%ld,"bounds":%@,"metadata":%@,"mapStyleUrl":"%@","minZoom":%f,"maxZoom":%f}"#
        let boundsJsonData = (try? JSONSerialization.data(withJSONObject: bounds)) ?? Data()
        let boundJsonString = String(data: boundsJsonData, encoding: .utf8) ?? "[]"
        var metadataJsonString = "null"
        if let metadata = metadata {
            let metadataJsonData = (try? JSONSerialization.data(withJSONObject: metadata)) ?? Data()
            metadataJsonString = String(data: metadataJsonData, encoding: .utf8) ?? "null"
        }
        let jsonString = String(format: formatString, id, boundJsonString, metadataJsonString, mapStyleUrl.path, minZoom, maxZoom)
        return jsonString
    }

    static func fromOfflineRegionDefinition(_ region: OfflineRegionDefinition, id: Int) -> OfflineRegion {
        return OfflineRegion(
            id: id,
            bounds: region.bounds,
            metadata: region.metadata,
            mapStyleUrl: region.mapStyleUrl,
            minZoom: region.minZoom,
            maxZoom: region.maxZoom
        );
    }

    static func fromOfflinePack(_ pack: MGLOfflinePack) -> OfflineRegion? {
        guard let region = pack.region as? MGLTilePyramidOfflineRegion,
            let dataObject = try? JSONSerialization.jsonObject(with: pack.context, options: []),
            let dict = dataObject as? [String: Any],
            let id = dict["id"] as? Int,
            let metadata = dict["metadata"] as? [String: Any] else { return nil }
        return OfflineRegion(
            id: id,
            bounds: boundsToArray(region.bounds),
            metadata: metadata,
            mapStyleUrl: region.styleURL,
            minZoom: region.minimumZoomLevel,
            maxZoom: region.maximumZoomLevel
        )
    }

    private static func boundsToArray(_ bounds: MGLCoordinateBounds) -> [[Double]] {
        let ne = [bounds.ne.latitude, bounds.ne.longitude]
        let sw = [bounds.sw.latitude, bounds.sw.longitude]
        return [sw, ne]
    }
}
