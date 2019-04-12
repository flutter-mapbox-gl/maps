import Mapbox

class LineManager: AnnotationManager<LineGeometry> {
    private let ID_GEOJSON_SOURCE = "mapbox-ios-line-source"
    private let ID_GEOJSON_LAYER = "mapbox-ios-line-layer"
    var layer: MGLLineStyleLayer?
    
    init() {
        super.init(sourceId: ID_GEOJSON_SOURCE)
        layer = MGLLineStyleLayer(identifier: ID_GEOJSON_LAYER, source: source)
    }
    
    func create(options: LineOptions) -> Line? {
        setDataDrivenLayerProperties(options: options)
        return super.create(options: options)
    }
    
    func update(id: UInt64, options: LineOptions) {
        setDataDrivenLayerProperties(options: options)
        super.update(id:id, options: options)
    }
    
    func setDataDrivenLayerProperties(options: LineOptions) {
        guard let layer = layer else { return }
        
        if let _ = options.lineJoin {
            layer.lineJoin = NSExpression(forKeyPath: LineOptions.KEY_LINE_JOIN)
        }
        if let _ = options.lineOpacity {
            layer.lineOpacity = NSExpression(forKeyPath: LineOptions.KEY_LINE_OPACITY)
        }
        if let _ = options.lineColor {
            layer.lineColor = NSExpression(forKeyPath: LineOptions.KEY_LINE_COLOR)
        }
        if let _ = options.lineWidth {
            layer.lineWidth = NSExpression(forKeyPath: LineOptions.KEY_LINE_WIDTH)
        }
        if let _ = options.lineGapWidth {
            layer.lineGapWidth = NSExpression(forKeyPath: LineOptions.KEY_LINE_GAP_WIDTH)
        }
        if let _ = options.lineOffset {
            layer.lineOffset = NSExpression(forKeyPath: LineOptions.KEY_LINE_OFFSET)
        }
        if let _ = options.lineBlur {
            layer.lineBlur = NSExpression(forKeyPath: LineOptions.KEY_LINE_BLUR)
        }
        if let _ = options.linePattern {
            layer.linePattern = NSExpression(forKeyPath: LineOptions.KEY_LINE_PATTERN)
        }
    }
}
