import Mapbox

class Symbol : MGLPointAnnotation, SymbolOptionsSink {

    private var _id = UUID().uuidString
    var id: String {
        get { return _id }
    }

    private var _iconImage: String?
    var iconImage: String? {
        get { return _iconImage }
    }

    var textField: String? {
        get { return title }
    }

    var geometry: CLLocationCoordinate2D {
        get{ return coordinate }
    }

    // MARK: Setters
    
    func setIconSize(iconSize: Double) {
        
    }

    func setIconImage(iconImage: String) {
        _iconImage = iconImage
    }
    
    func setIconRotate(iconRotate: Double) {
        
    }
    
    func setIconAnchor(iconAnchor: String) {
        
    }
    
    func setTextField(textField: String) {
        title = textField
    }
    
    func setTextSize(textSize: Double) {
        
    }
    
    func setTextMaxWidth(textMaxWidth: Double) {
        
    }
    
    func setTextLetterSpacing(textLetterSpacing: Double) {
        
    }
    
    func setTextJustify(textJustify: String) {
        
    }
    
    func setTextAnchor(textAnchor: String) {
        
    }
    
    func setTextRotate(textRotate: Double) {
        
    }
    
    func setTextTransform(textTransform: String) {
        
    }
    
    func setIconOpacity(iconOpacity: Double) {
        
    }
    
    func setIconColor(iconColor: String) {
        
    }
    
    func setIconHaloColor(iconHaloColor: String) {
        
    }
    
    func setIconHaloWidth(iconHaloWidth: Double) {
        
    }
    
    func setIconHaloBlur(iconHaloBlur: Double) {
        
    }
    
    func setTextOpacity(textOpacity: Double) {
        
    }
    
    func setTextColor(textColor: String) {
        
    }
    
    func setTextHaloColor(textHaloColor: String) {
        
    }
    
    func setTextHaloWidth(textHaloWidth: Double) {
        
    }
    
    func setTextHaloBlur(textHaloBlur: Double) {
        
    }

    func setGeometry(geometry: [Double]) {
        if geometry.count == 2, -90...90 ~= geometry[0], -180...180 ~= geometry[1] {
            coordinate = CLLocationCoordinate2D(latitude: geometry[0], longitude: geometry[1])
        } else {
            NSLog("Invalid geometry")
        }
    }

    func setZIndex(zIndex: Int) {
        
    }
    
    func setDraggable(draggable: Bool) {
        
    }
}
