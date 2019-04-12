class LineBuilder: LineOptionsSink {
    private var lineOptions: LineOptions
    private var lineManager: LineManager
    
    init(lineManager: LineManager, options: LineOptions) {
        self.lineManager = lineManager
        self.lineOptions = options
    }
    
    convenience init(lineManager: LineManager) {
        self.init(lineManager: lineManager, options: LineOptions())
    }
    
    convenience init(lineManager: LineManager, line: Line) {
        let lineOptions = LineOptions(properties: line.properties)
        lineOptions.setGeometry(geometry: line.geometry.coordinates)
        self.init(lineManager: lineManager, options: lineOptions)
    }
    
    func setGeometry(geometry: [[Double]]) {
        var geojsonGeometry: [[Double]] = [[Double]]()
        for geo in geometry {
            geojsonGeometry.append([geo[1], geo[0]])
        }
        lineOptions.setGeometry(geometry: geojsonGeometry)
    }
    
    func setLineJoin(lineJoin: String) {
        lineOptions.lineJoin = lineJoin
    }
    
    func setLineOpacity(lineOpacity: Double) {
        lineOptions.lineOpacity = lineOpacity
    }
    
    func setLineColor(lineColor: String) {
        lineOptions.lineColor = lineColor
    }
    
    func setLineWidth(lineWidth: Double) {
        lineOptions.lineWidth = lineWidth
    }
    
    func setLineGapWidth(lineGapWidth: Double) {
        lineOptions.lineGapWidth = lineGapWidth
    }
    
    func setLineOffset(lineOffset: Double) {
        lineOptions.lineOffset = lineOffset
    }
    
    func setLineBlur(lineBlur: Double) {
        lineOptions.lineBlur = lineBlur
    }
    
    func setLinePattern(linePattern: String) {
        lineOptions.linePattern = linePattern
    }
    
    func build() -> Line? {
        return lineManager.create(options: lineOptions)
    }
    
    func update(id: UInt64) {
        lineManager.update(id: id, options: lineOptions)
    }
}
