//
//  OfflineRegionData.swift
//  location
//
//  Created by Patryk on 02/06/2020.
//

import Foundation
import Mapbox

class OfflineRegionData {
    var id: Int
    var bounds: [[Double]]
    var metadata: [String: Any]?
    var mapStyleUrl: URL
    var minZoom: Double
    var maxZoom: Double
    
    init(id: Int, bounds: [[Double]], metadata: [String: Any]?, mapStyleUrl: URL, minZoom: Double, maxZoom: Double) {
        self.id = id
        self.bounds = bounds
        self.metadata = metadata
        self.mapStyleUrl = mapStyleUrl
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
    
    func getBounds() -> MGLCoordinateBounds {
        return MGLCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: bounds[0][0], longitude: bounds[0][1]),
            ne: CLLocationCoordinate2D(latitude: bounds[1][0], longitude: bounds[1][1])
        )
    }
    
    static func fromJsonString(_ jsonString: String) -> OfflineRegionData? {
        guard let jsonData = jsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let jsonDict = jsonObject as? [String: Any],
            let id = jsonDict["id"] as? Int,
            let bounds = jsonDict["bounds"] as? [[Double]],
            let mapStyleUrlString = jsonDict["mapStyleUrl"] as? String,
            let mapStyleUrl = URL(string: mapStyleUrlString),
            let minZoom = jsonDict["minZoom"] as? Double,
            let maxZoom = jsonDict["maxZoom"] as? Double
            else { return nil }
        return OfflineRegionData(
            id: id,
            bounds: bounds,
            metadata: jsonDict["metadata"] as? [String: Any],
            mapStyleUrl: mapStyleUrl,
            minZoom: minZoom,
            maxZoom: maxZoom
        )
    }
    
    func toJsonString() -> String {
        let formatString = #"{"id":%d,"bounds":%@,"metadata":%@,"mapStyleUrl":"%@","minZoom":%f,"maxZoom":%f}"#
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
    
    func toJsonDict() -> [String: Any] {
        return [
            "id": id,
            "bounds": bounds,
            "metadata": metadata as Any,
            "mapStyleUrl": mapStyleUrl.path,
            "minZoom": Double(minZoom),
            "maxZoom": Double(maxZoom)
        ]
    }
    
    static func fromOfflineRegion(_ region: MGLTilePyramidOfflineRegion, metadata: Data) -> OfflineRegionData? {
        guard let dataObject = try? JSONSerialization.jsonObject(with: metadata, options: []),
            var dict = dataObject as? [String: Any],
            dict.keys.contains("id"),
            let id = dict["id"] as? Int else { return nil }
        dict.removeValue(forKey: "id")
        return OfflineRegionData(
            id: id,
            bounds: boundsToArray(region.bounds),
            metadata: dict,
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
