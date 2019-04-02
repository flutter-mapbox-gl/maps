import Mapbox

class LineOptions: Options<LineGeometry> {
    private var properties = [String: AnyEncodable]()
    
    private(set) var geometry: LineGeometry?
    func setGeometry(geometry: [[Double]]) {
        self.geometry = LineGeometry(coordinates: geometry)
    }
    
    override func build(id: Float) -> Feature<LineGeometry>? {
        if let geometry = geometry  {
            return Line(id: id, geometry: geometry, properties: properties)
        }
        return nil
    }
}
