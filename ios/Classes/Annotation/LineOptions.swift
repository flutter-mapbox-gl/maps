import Mapbox

class LineOptions: Options<LineGeometry> {
    static let KEY_LINE_JOIN = "line-join"
    static let KEY_LINE_OPACITY = "line-opacity"
    static let KEY_LINE_COLOR = "line-color"
    static let KEY_LINE_WIDTH = "line-width"
    static let KEY_LINE_GAP_WIDTH = "line-gap-width"
    static let KEY_LINE_OFFSET = "line-offset"
    static let KEY_LINE_BLUR = "line-blur"
    static let KEY_LINE_PATTERN = "line-pattern"

    private var properties = [String: AnyEncodable]()
    
    private(set) var geometry: LineGeometry?
    func setGeometry(geometry: [[Double]]) {
        self.geometry = LineGeometry(coordinates: geometry)
    }
    
    var lineJoin: String? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_JOIN] = AnyEncodable(newValue)
        }
    }
    
    var lineOpacity: Double? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_OPACITY] = AnyEncodable(newValue)
        }
    }
    
    var lineColor: String? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_COLOR] = AnyEncodable(newValue)
        }
    }
    
    var lineWidth: Double? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_WIDTH] = AnyEncodable(newValue)
        }
    }
    
    var lineGapWidth: Double? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_GAP_WIDTH] = AnyEncodable(newValue)
        }
    }
    
    var lineOffset: Double? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_OFFSET] = AnyEncodable(newValue)
        }
    }
    
    var lineBlur: Double? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_BLUR] = AnyEncodable(newValue)
        }
    }
    
    var linePattern: String? {
        get {
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_PATTERN] = AnyEncodable(newValue)
        }
    }
    
    override func build(id: Float) -> Feature<LineGeometry>? {
        if let geometry = geometry  {
            return Line(id: id, geometry: geometry, properties: properties)
        }
        return nil
    }
}
