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
}
