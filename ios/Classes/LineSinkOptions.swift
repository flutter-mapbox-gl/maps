import Mapbox

protocol LineOptionsSink {
    func setGeometry(geometry: [[Double]])

    func setLineJoin(lineJoin: String)
    func setLineOpacity(lineOpacity: Double)
    func setLineColor(lineColor: String)
    func setLineWidth(lineWidth: Double)
    func setLineGapWidth(lineGapWidth: Double)
    func setLineOffset(lineOffset: Double)
    func setLineBlur(lineBlur: Double)
    func setLinePattern(linePattern: String)
}
