
class Options<G: Geometry> {

    // Work around because Swift does not support generic protocols (or abstract classes).
    func build(id: UInt64) -> Feature<G>? {
        assert(false, "This method must be overriden by the subclass")
    }
}
