import Mapbox

extension MGLMapCamera {
    func toDict(mapView: MGLMapView) -> [String: Any] {
        let zoom = MGLZoomLevelForAltitude(self.altitude, self.pitch, self.centerCoordinate.latitude, mapView.frame.size)
        return ["bearing": self.heading,
                "target": self.centerCoordinate.toArray(),
                "tilt": self.pitch,
                "zoom": zoom]
    }
    static func fromDict(_ dict: [String: Any], mapView: MGLMapView) -> MGLMapCamera? {
        guard let target = dict["target"] as? [Double],
            let zoom = dict["zoom"] as? Double,
            let tilt = dict["tilt"] as? CGFloat,
            let bearing = dict["bearing"] as? Double else { return nil }
        let location = CLLocationCoordinate2D.fromArray(target)
        let altitude = MGLAltitudeForZoomLevel(zoom, tilt, location.latitude, mapView.frame.size)
        return MGLMapCamera(lookingAtCenter: location, altitude: altitude, pitch: tilt, heading: bearing)
    }
}

extension CLLocationCoordinate2D {
    func toArray()  -> [Double] {
        return [self.latitude, self.longitude]
    }
    static func fromArray(_ array: [Double]) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: array[0], longitude: array[1])
    }
}

extension MGLCoordinateBounds {
    func toArray()  -> [[Double]] {
        return [self.sw.toArray(), self.ne.toArray()]
    }
    static func fromArray(_ array: [[Double]]) -> MGLCoordinateBounds {
        let southwest = CLLocationCoordinate2D.fromArray(array[0])
        let northeast = CLLocationCoordinate2D.fromArray(array[1])
        return MGLCoordinateBounds(sw: southwest, ne: northeast)
    }
}
