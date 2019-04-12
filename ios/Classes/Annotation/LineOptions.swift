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

    private var properties: [String: AnyEncodable]
    
    init(properties: [String: AnyEncodable]) {
        self.properties = properties
    }

    convenience override init() {
        self.init(properties: [String: AnyEncodable]())
    }

    private(set) var geometry: LineGeometry?
    func setGeometry(geometry: [[Double]]) {
        self.geometry = LineGeometry(coordinates: geometry)
    }
    
    var lineJoin: String? {
        get {
            if let value = properties[LineOptions.KEY_LINE_JOIN] {
                return value.encodable as? String
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_JOIN] = AnyEncodable(newValue)
        }
    }
    
    var lineOpacity: Double? {
        get {
            if let value = properties[LineOptions.KEY_LINE_OPACITY] {
                return value.encodable as? Double
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_OPACITY] = AnyEncodable(newValue)
        }
    }
    
    var lineColor: String? {
        get {
            if let value = properties[LineOptions.KEY_LINE_COLOR] {
                return value.encodable as? String
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_COLOR] = AnyEncodable(newValue)
        }
    }
    
    var lineWidth: Double? {
        get {
            if let value = properties[LineOptions.KEY_LINE_WIDTH] {
                return value.encodable as? Double
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_WIDTH] = AnyEncodable(newValue)
        }
    }
    
    var lineGapWidth: Double? {
        get {
            if let value = properties[LineOptions.KEY_LINE_GAP_WIDTH] {
                return value.encodable as? Double
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_GAP_WIDTH] = AnyEncodable(newValue)
        }
    }
    
    var lineOffset: Double? {
        get {
            if let value = properties[LineOptions.KEY_LINE_OFFSET] {
                return value.encodable as? Double
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_OFFSET] = AnyEncodable(newValue)
        }
    }
    
    var lineBlur: Double? {
        get {
            if let value = properties[LineOptions.KEY_LINE_BLUR] {
                return value.encodable as? Double
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_BLUR] = AnyEncodable(newValue)
        }
    }
    
    var linePattern: String? {
        get {
            if let value = properties[LineOptions.KEY_LINE_PATTERN] {
                return value.encodable as? String
            }
            return nil
        }
        set(newValue) {
            properties[LineOptions.KEY_LINE_PATTERN] = AnyEncodable(newValue)
        }
    }
    
    override func build(id: UInt64) -> Feature<LineGeometry>? {
        if let geometry = geometry  {
            return Line(id: id, geometry: geometry, properties: properties)
        }
        return nil
    }
}
