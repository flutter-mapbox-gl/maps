import Foundation
import Mapbox

class OfflineRegionDefinition {
    let bounds: [[Double]]
    let metadata: [String: Any]?
    let mapStyleUrl: URL
    let minZoom: Double
    let maxZoom: Double

    init(bounds: [[Double]], metadata: [String: Any]?, mapStyleUrl: URL, minZoom: Double, maxZoom: Double) {
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

    static func fromJsonString(_ jsonString: String) -> OfflineRegionDefinition? {
        guard let jsonData = jsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let jsonDict = jsonObject as? [String: Any],
            let bounds = jsonDict["bounds"] as? [[Double]],
            let mapStyleUrlString = jsonDict["mapStyleUrl"] as? String,
            let mapStyleUrl = URL(string: mapStyleUrlString),
            let minZoom = jsonDict["minZoom"] as? Double,
            let maxZoom = jsonDict["maxZoom"] as? Double
            else { return nil }
        return OfflineRegionDefinition(
            bounds: bounds,
            metadata: jsonDict["metadata"] as? [String: Any],
            mapStyleUrl: mapStyleUrl,
            minZoom: minZoom,
            maxZoom: maxZoom
        )
    }

    func toMGLTilePyramidOfflineRegion() -> MGLTilePyramidOfflineRegion {
        return MGLTilePyramidOfflineRegion(
            styleURL: mapStyleUrl,
            bounds: getBounds(),
            fromZoomLevel: minZoom,
            toZoomLevel: maxZoom
        )
    }
}
