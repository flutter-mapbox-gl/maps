class LineBuilder: LineOptionsSink {
    private var lineOptions: LineOptions
    private var lineManager: LineManager
    
    init(lineManager: LineManager) {
        self.lineManager = lineManager
        lineOptions = LineOptions()
    }
    
    func setGeometry(geometry: [[Double]]) {
        var geojsonGeometry: [[Double]] = [[Double]]()
        for geo in geometry {
            geojsonGeometry.append([geo[1], geo[0]])
        }
        lineOptions.setGeometry(geometry: geojsonGeometry)
    }
    
    func build() -> Line? {
        return lineManager.create(options: lineOptions)
    }
}
