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

extension CLLocation {
    func toDict() -> [String: Any]? {
        return ["position": self.coordinate.toArray(),
                "altitude": self.altitude,
                "bearing": self.course,
                "speed": self.speed,
                "horizontalAccuracy": self.horizontalAccuracy,
                "verticalAccuracy": self.verticalAccuracy,
                "timestamp": Int(self.timestamp.timeIntervalSince1970 * 1000)
        ]
    }
}

extension CLHeading {
    func toDict() -> [String: Any]? {
        return ["magneticHeading": self.magneticHeading,
                "trueHeading": self.trueHeading,
                "headingAccuracy": self.headingAccuracy,
                "x": self.x,
                "y": self.y,
                "z": self.z,
                "timestamp": Int(self.timestamp.timeIntervalSince1970 * 1000),
        ]
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

extension UIImage {
    static func loadFromFile(imagePath: String, imageName: String) -> UIImage? {
        // Add the trailing slash in path if missing.
        let path = imagePath.hasSuffix("/") ? imagePath : "\(imagePath)/"
        // Build scale dependant image path.
        let scale = UIScreen.main.scale
        var absolutePath = "\(path)\(scale)x/\(imageName)"
        // Check if the image exists, if not try a an unscaled path.
        if Bundle.main.path(forResource: absolutePath, ofType: nil) == nil {
            absolutePath = "\(path)\(imageName)"
        }
        // Load image if it exists.
        if let path = Bundle.main.path(forResource: absolutePath, ofType: nil) {
            let imageUrl: URL = URL(fileURLWithPath: path)
            if  let imageData: Data = try? Data(contentsOf: imageUrl),
                let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
                return image
            }
        }
        return nil
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString[start...]
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: String(hexColor))
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}


extension Array {
    var tail: Array {
        return Array(self.dropFirst())
    }
}
