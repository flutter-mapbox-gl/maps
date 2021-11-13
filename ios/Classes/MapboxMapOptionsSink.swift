
import Mapbox

protocol MapboxMapOptionsSink {
    func setCameraTargetBounds(bounds: MGLCoordinateBounds?)
    func setCompassEnabled(compassEnabled: Bool)
    func setStyleString(styleString: String)
    func setMinMaxZoomPreference(min: Double, max: Double)
    func setRotateGesturesEnabled(rotateGesturesEnabled: Bool)
    func setScrollGesturesEnabled(scrollGesturesEnabled: Bool)
    func setTiltGesturesEnabled(tiltGesturesEnabled: Bool)
    func setTrackCameraPosition(trackCameraPosition: Bool)
    func setZoomGesturesEnabled(zoomGesturesEnabled: Bool)
    func setMyLocationEnabled(myLocationEnabled: Bool)
    func setMyLocationTrackingMode(myLocationTrackingMode: MGLUserTrackingMode)
    func setMyLocationRenderMode(myLocationRenderMode: MyLocationRenderMode)
    func setLogoViewMargins(x: Double, y: Double)
    func setCompassViewPosition(position: MGLOrnamentPosition)
    func setCompassViewMargins(x: Double, y: Double)
    func setAttributionButtonMargins(x: Double, y: Double)
    func setAttributionButtonPosition(position: MGLOrnamentPosition)
}
