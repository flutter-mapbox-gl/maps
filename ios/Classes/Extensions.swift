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

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString[start...]
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: String(hexColor))
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
