import Mapbox

class Symbol: MGLPointAnnotation, SymbolOptionsSink {
    private var _id = UUID().uuidString
    var id: String { return _id }

    private var _iconImage: String?
    var iconImage: String? { return _iconImage }

    var textField: String? { return title }

    var geometry: CLLocationCoordinate2D { return coordinate }

    // MARK: Setters

    func setIconSize(iconSize _: Double) {}

    func setIconImage(iconImage: String) {
        _iconImage = iconImage
    }

    func setIconRotate(iconRotate _: Double) {}

    func setIconAnchor(iconAnchor _: String) {}

    func setTextField(textField: String) {
        title = textField
    }

    func setTextSize(textSize _: Double) {}

    func setTextMaxWidth(textMaxWidth _: Double) {}

    func setTextLetterSpacing(textLetterSpacing _: Double) {}

    func setTextJustify(textJustify _: String) {}

    func setTextAnchor(textAnchor _: String) {}

    func setTextRotate(textRotate _: Double) {}

    func setTextTransform(textTransform _: String) {}

    func setIconOpacity(iconOpacity _: Double) {}

    func setIconColor(iconColor _: String) {}

    func setIconHaloColor(iconHaloColor _: String) {}

    func setIconHaloWidth(iconHaloWidth _: Double) {}

    func setIconHaloBlur(iconHaloBlur _: Double) {}

    func setTextOpacity(textOpacity _: Double) {}

    func setTextColor(textColor _: String) {}

    func setTextHaloColor(textHaloColor _: String) {}

    func setTextHaloWidth(textHaloWidth _: Double) {}

    func setTextHaloBlur(textHaloBlur _: Double) {}

    func setGeometry(geometry: [Double]) {
        if geometry.count == 2, -90 ... 90 ~= geometry[0], -180 ... 180 ~= geometry[1] {
            coordinate = CLLocationCoordinate2D(latitude: geometry[0], longitude: geometry[1])
        } else {
            NSLog("Invalid geometry")
        }
    }

    func setZIndex(zIndex _: Int) {}

    func setDraggable(draggable _: Bool) {}
}
