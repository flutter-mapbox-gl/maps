import Mapbox

class LineManager: AnnotationManager<LineGeometry> {
    private let ID_GEOJSON_SOURCE = "mapbox-ios-line-source"
    private let ID_GEOJSON_LAYER = "mapbox-ios-line-layer"
    var layer: MGLLineStyleLayer?
    
    init() {
        super.init(sourceId: ID_GEOJSON_SOURCE)
        
        layer = MGLLineStyleLayer(identifier: ID_GEOJSON_LAYER, source: source)
        setDataDrivenLayerProperties()
    }
    
    func setDataDrivenLayerProperties() {
        if let layer = layer {
            layer.lineJoin = NSExpression(forKeyPath: LineOptions.KEY_LINE_JOIN)
            layer.lineOpacity = NSExpression(forKeyPath: LineOptions.KEY_LINE_OPACITY)
            layer.lineColor = NSExpression(forKeyPath: LineOptions.KEY_LINE_COLOR)
            layer.lineWidth = NSExpression(forKeyPath: LineOptions.KEY_LINE_WIDTH)
            layer.lineGapWidth = NSExpression(forKeyPath: LineOptions.KEY_LINE_GAP_WIDTH)
            layer.lineOffset = NSExpression(forKeyPath: LineOptions.KEY_LINE_OFFSET)
            layer.lineBlur = NSExpression(forKeyPath: LineOptions.KEY_LINE_BLUR)
            //FIX: Setting the line pattern does not show a line.
//            layer.linePattern = NSExpression(forKeyPath: LineOptions.KEY_LINE_PATTERN)
        }
    }
}
