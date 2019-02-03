import Flutter
import UIKit
import Mapbox

class MapboxMapController: NSObject, FlutterPlatformView {
    
    var mapView: MGLMapView
    
    func view() -> UIView {
        return mapView
    }
    
    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        mapView = MGLMapView(frame: frame)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.init()
        
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/mapbox_maps_\(viewId)", binaryMessenger: messenger)
        channel.setMethodCallHandler(onMethodCall)
    }
    
    func onMethodCall(methodCall: FlutterMethodCall, result: FlutterResult) {
        switch(methodCall.method) {
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
