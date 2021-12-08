
protocol SymbolOptionsSink {
    func setIconSize(iconSize: Double)
    func setIconImage(iconImage: String)
    func setIconRotate(iconRotate: Double)
//    final Offset iconOffset;
    func setIconAnchor(iconAnchor: String)
    func setTextField(textField: String)
    func setTextSize(textSize: Double)
    func setTextMaxWidth(textMaxWidth: Double)
    func setTextLetterSpacing(textLetterSpacing: Double)
    func setTextJustify(textJustify: String)
    func setTextAnchor(textAnchor: String)
    func setTextRotate(textRotate: Double)
    func setTextTransform(textTransform: String)
//    final Offset textOffset;
    func setIconOpacity(iconOpacity: Double)
    func setIconColor(iconColor: String)
    func setIconHaloColor(iconHaloColor: String)
    func setIconHaloWidth(iconHaloWidth: Double)
    func setIconHaloBlur(iconHaloBlur: Double)
    func setTextOpacity(textOpacity: Double)
    func setTextColor(textColor: String)
    func setTextHaloColor(textHaloColor: String)
    func setTextHaloWidth(textHaloWidth: Double)
    func setTextHaloBlur(textHaloBlur: Double)

    func setGeometry(geometry: [Double])
    func setZIndex(zIndex: Int)
    func setDraggable(draggable: Bool)
}
