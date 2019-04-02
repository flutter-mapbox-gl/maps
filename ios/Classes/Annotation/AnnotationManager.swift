import Mapbox

// This class is reponsible for the management of annotations. The annotations are
// serialized to a FeatureCollection GeoJSON structure which are passed on to the
// map's data source.
class AnnotationManager<G: Geometry>  {
    private(set) var source: MGLShapeSource
    
    internal var annotations: [Float: Annotation<G>]
    private var currentId: Float = 0
    
    init(sourceId: String) {
        source = MGLShapeSource(identifier: sourceId, shape: nil, options: nil)
        annotations = [Float: Annotation<G>]()
    }
    
    func create(options: Options<G>) -> Annotation<G>? {
        if let annotation = options.build(id: currentId) {
            annotations[currentId] = annotation
            currentId += 1
            updateSource()
            return annotation
        }
        return nil
    }
    
    func updateSource() {
        let features = Array(annotations.values)
        let featureCollection = FeatureCollection<G>(features: features)
        let data = try! JSONEncoder().encode(featureCollection)
        let shape = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature
        source.shape = shape
    }
}
