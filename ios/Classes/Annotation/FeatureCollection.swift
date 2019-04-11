struct FeatureCollection<G: Geometry>: Encodable {
    let type = "FeatureCollection"
    var features: [Feature<G>]
}

struct Feature<G: Geometry>: Encodable {
    var id: UInt64
    let type: String = "Feature"
    var geometry: G
    var properties: [String : AnyEncodable]
}

struct AnyEncodable: Encodable {
    var encodable: Encodable

    init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
