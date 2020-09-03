import Mapbox
import MapboxAnnotationExtension


class NeoCircleBuilder {
    
    static func createNeoCircleFeature (options: [String: Any], radius: Double) -> MGLPointFeature {
        
        let newFeature = MGLPointFeature()
        
        let geometry : [Double] = options["geometry"] as? [Double] ?? [0,0]
        let lat : Double = geometry[0]
        let lon : Double = geometry[1]
        let circleColor : String = options["circleColor"] as? String ?? "#FFFFFF"
        let circleOpacity : Double = options["circleOpacity"] as? Double ?? 0
        let circleStrokeWidth : Double = options["circleStrokeWidth"] as? Double ?? 0
        let circleStrokeColor : String = options["circleStrokeColor"] as? String ?? "#FFFFFF"
        let circleStrokeOpacity : Double = options["circleStrokeOpacity"] as? Double ?? 0
        
        newFeature.coordinate = CLLocationCoordinate2DMake(lat, lon)
        
        newFeature.attributes = [
            "radius": radius * 75,
            "circle-color": circleColor,
            "circle-opacity": circleOpacity,
            "circle-stroke-color": circleStrokeColor,
            "circle-stroke-width": circleStrokeWidth * 18,
            "circle-stroke-opacity": circleStrokeOpacity
        ]
        
        return newFeature
    }
    
}
