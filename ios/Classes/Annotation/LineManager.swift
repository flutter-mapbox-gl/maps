import Mapbox

class LineManager: AnnotationManager<LineGeometry> {
    private let ID_GEOJSON_SOURCE = "mapbox-ios-line-source"
    private let ID_GEOJSON_LAYER = "mapbox-ios-line-layer"
    var layer: MGLLineStyleLayer?
    
    init(identifier: String) {
        super.init(sourceId: ID_GEOJSON_SOURCE)
        
        layer = MGLLineStyleLayer(identifier: ID_GEOJSON_LAYER, source: source)
    }
}
