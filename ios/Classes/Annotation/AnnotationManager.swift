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
}
