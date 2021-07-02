import Foundation
import Mapbox

class OfflineRegionDefinition {
    let bounds: [[Double]]
    let mapStyleUrl: URL
    let minZoom: Double
    let maxZoom: Double

    init(bounds: [[Double]], mapStyleUrl: URL, minZoom: Double, maxZoom: Double) {
        self.bounds = bounds
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

    static func fromDictionary(_ jsonDict: [String: Any]) -> OfflineRegionDefinition? {
        guard let bounds = jsonDict["bounds"] as? [[Double]],
            let mapStyleUrlString = jsonDict["mapStyleUrl"] as? String,
            let mapStyleUrl = URL(string: mapStyleUrlString),
            let minZoom = jsonDict["minZoom"] as? Double,
            let maxZoom = jsonDict["maxZoom"] as? Double
            else { return nil }
        return OfflineRegionDefinition(
            bounds: bounds,
            mapStyleUrl: mapStyleUrl,
            minZoom: minZoom,
            maxZoom: maxZoom
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "bounds": self.bounds,
            "mapStyleUrl": self.mapStyleUrl.absoluteString,
            "minZoom": self.minZoom,
            "maxZoom": self.maxZoom,
        ];
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
