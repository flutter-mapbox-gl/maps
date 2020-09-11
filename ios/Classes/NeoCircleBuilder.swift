import Mapbox
import MapboxAnnotationExtension
import Turf


class NeoCircleBuilder {
    
    static let STROKE_WIDTH_MULTIPLIER: Double = 18
    static let RADIUS_MULTIPLIER: Double = 65
    
    static func createNeoCircleFeature (options: [String: Any], radius: Double) -> MGLPolygonFeature {
        
        
        
        let geometry : [Double] = options["geometry"] as? [Double] ?? [0,0]
        let lat : Double = geometry[0]
        let lon : Double = geometry[1]
        
        
        let polygon : MGLPolygon = polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), withMeterRadius: radius)
        
        
        let newFeature = MGLPolygonFeature(coordinates: polygon.coordinates, count: polygon.pointCount)
        
        
        let fillColor : String = options["fill-color"] as? String ?? "#FFFFFF"
        let fillOpacity : Double = options["fill-opacity"] as? Double ?? 0
        let borderWidth : Double = options["border-width"] as? Double ?? 0
        let borderColor : String = options["border-color"] as? String ?? "#FFFFFF"
        let borderOpacity : Double = options["border-opacity"] as? Double ?? 0
        
        
        newFeature.attributes = [
            "radius": radius,
            "fill-color": fillColor,
            "fill-opacity": fillOpacity,
            "border-color": "#FFFFFF",
            "border-width": borderWidth,
            "border-opacity": borderOpacity
        ]
        
        return newFeature
    }
    
    
    static func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MGLPolygon {
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        // earth radius in meters
        let centerLatRadians: Double = coordinate.latitude * Double.pi / 180
        let centerLonRadians: Double = coordinate.longitude * Double.pi / 180
        var coordinates = [CLLocationCoordinate2D]()
        //array to hold all the points
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * Double.pi / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / Double.pi
            let pointLon: Double = pointLonRadians * 180 / Double.pi
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            coordinates.append(point)
        }
        return MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
    }
    
}
