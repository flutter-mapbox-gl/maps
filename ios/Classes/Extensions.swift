import Mapbox

extension MGLMapCamera {
    func toDict(mapView: MGLMapView) -> [String: Any] {
        let zoom = MGLZoomLevelForAltitude(
            altitude,
            pitch,
            centerCoordinate.latitude,
            mapView.frame.size
        )
        return ["bearing": heading,
                "target": centerCoordinate.toArray(),
                "tilt": pitch,
                "zoom": zoom]
    }

    static func fromDict(_ dict: [String: Any], mapView: MGLMapView) -> MGLMapCamera? {
        guard let target = dict["target"] as? [Double],
              let zoom = dict["zoom"] as? Double,
              let tilt = dict["tilt"] as? CGFloat,
              let bearing = dict["bearing"] as? Double else { return nil }
        let location = CLLocationCoordinate2D.fromArray(target)
        let altitude = MGLAltitudeForZoomLevel(zoom, tilt, location.latitude, mapView.frame.size)
        return MGLMapCamera(
            lookingAtCenter: location,
            altitude: altitude,
            pitch: tilt,
            heading: bearing
        )
    }
}

extension CLLocation {
    func toDict() -> [String: Any]? {
        return ["position": coordinate.toArray(),
                "altitude": altitude,
                "bearing": course,
                "speed": speed,
                "horizontalAccuracy": horizontalAccuracy,
                "verticalAccuracy": verticalAccuracy,
                "timestamp": Int(timestamp.timeIntervalSince1970 * 1000)]
    }
}

extension CLHeading {
    func toDict() -> [String: Any]? {
        return ["magneticHeading": magneticHeading,
                "trueHeading": trueHeading,
                "headingAccuracy": headingAccuracy,
                "x": x,
                "y": y,
                "z": z,
                "timestamp": Int(timestamp.timeIntervalSince1970 * 1000)]
    }
}

extension CLLocationCoordinate2D {
    func toArray() -> [Double] {
        return [latitude, longitude]
    }

    static func fromArray(_ array: [Double]) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: array[0], longitude: array[1])
    }
}

extension MGLCoordinateBounds {
    func toArray() -> [[Double]] {
        return [sw.toArray(), ne.toArray()]
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
        var scale = UIScreen.main.scale
        var absolutePath = "\(path)\(scale)x/\(imageName)"
        // Check if the image exists, if not try a an unscaled path.
        if Bundle.main.path(forResource: absolutePath, ofType: nil) == nil {
            absolutePath = "\(path)\(imageName)"
        } else {
            // found asset with higher resolution - increase scale even further to compensate
            scale *= scale
        }
        // Load image if it exists.
        if let path = Bundle.main.path(forResource: absolutePath, ofType: nil) {
            let imageUrl = URL(fileURLWithPath: path)
            if let imageData: Data = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData, scale: scale)
            {
                return image
            }
        }
        return nil
    }
}

public extension UIColor {
    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString[start...]

            let scanner = Scanner(string: String(hexColor))
            var hexNumber: UInt64 = 0

            if hexColor.count == 6 {
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000FF) / 255
                    a = 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 8 {
                if scanner.scanHexInt64(&hexNumber) {
                    a = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
                    r = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000_00FF) / 255

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
        return Array(dropFirst())
    }
}
