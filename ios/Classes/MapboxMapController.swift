import Flutter
import UIKit
import Mapbox

class MapboxMapController: NSObject, FlutterPlatformView, MGLMapViewDelegate, MapboxMapOptionsSink {

    private var mapView: MGLMapView
    private var isMapReady = false
    private var mapReadyResult: FlutterResult?
    private var  channel: FlutterMethodChannel

    private var initialTilt: CGFloat?
    private var cameraTargetBounds: MGLCoordinateBounds?
    private var trackCameraPosition = false
    private var myLocationEnabled = false

    func view() -> UIView {
        return mapView
    }

    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        mapView = MGLMapView(frame: frame)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        channel = FlutterMethodChannel(name: "plugins.flutter.io/mapbox_maps_\(viewId)", binaryMessenger: messenger)

        super.init()

        channel.setMethodCallHandler(onMethodCall)

        mapView.delegate = self

        if let args = args as? [String: Any] {
            Convert.interpretMapboxMapOptions(options: args["options"], delegate: self)
            if let initialCameraPosition = args["initialCameraPosition"] as? [String: Any],
                let camera = MGLMapCamera.fromDict(initialCameraPosition, mapView: mapView),
                let zoom = initialCameraPosition["zoom"] as? Double {
                mapView.setCenter(camera.centerCoordinate, zoomLevel: zoom, direction: camera.heading, animated: false)
                initialTilt = camera.pitch
            }
        }
    }

    func onMethodCall(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(methodCall.method) {
        case "map#waitForMap":
            if isMapReady {
                result(nil)
            } else {
                mapReadyResult = result
            }
        case "map#update":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            Convert.interpretMapboxMapOptions(options: arguments["options"], delegate: self)
            if let camera = getCamera() {
                result(camera.toDict(mapView: mapView))
            } else {
                result(nil)
            }
        case "camera#move":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView) {
                mapView.setCamera(camera, animated: false)
            }
        case "camera#animate":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView) {
                mapView.setCamera(camera, animated: true)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func updateMyLocationEnabled() {
        mapView.showsUserLocation = self.myLocationEnabled
    }

    private func getCamera() -> MGLMapCamera? {
        return trackCameraPosition ? mapView.camera : nil
    }

    /*
     *  MGLMapViewDelegate
     */
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        isMapReady = true
        updateMyLocationEnabled()

        if let initialTilt = initialTilt {
            let camera = mapView.camera
            camera.pitch = initialTilt
            mapView.setCamera(camera, animated: false)
        }

        mapReadyResult?(nil)
    }

    func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
        guard let bbox = cameraTargetBounds else { return true }
        // Get the current camera to restore it after.
        let currentCamera = mapView.camera

        // From the new camera obtain the center to test if it’s inside the boundaries.
        let newCameraCenter = newCamera.centerCoordinate

        // Set the map’s visible bounds to newCamera.
        mapView.camera = newCamera
        let newVisibleCoordinates = mapView.visibleCoordinateBounds

        // Revert the camera.
        mapView.camera = currentCamera

        // Test if the newCameraCenter and newVisibleCoordinates are inside bbox.
        let inside = MGLCoordinateInCoordinateBounds(newCameraCenter, bbox)
        let intersects = MGLCoordinateInCoordinateBounds(newVisibleCoordinates.ne, bbox) && MGLCoordinateInCoordinateBounds(newVisibleCoordinates.sw, bbox)

        return inside && intersects
    }

    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        channel.invokeMethod("map#onCameraTrackingChanged", arguments: ["mode": mode.rawValue])
        if mode == .none {
            channel.invokeMethod("map#onCameraTrackingDismissed", arguments: [])
        }
    }

    /*
     *  MapboxMapOptionsSink
     */
    func setCameraTargetBounds(bounds: MGLCoordinateBounds?) {
        cameraTargetBounds = bounds
    }
    func setCompassEnabled(compassEnabled: Bool) {
        mapView.compassView.isHidden = compassEnabled
        mapView.compassView.isHidden = !compassEnabled
    }
    func setMinMaxZoomPreference(min: Double, max: Double) {
        mapView.minimumZoomLevel = min
        mapView.maximumZoomLevel = max
    }
    func setStyleString(styleString: String) {
        // Check if json, url or plain string:
        if styleString.isEmpty {
            NSLog("setStyleString - string empty")
        } else if (styleString.hasPrefix("{") || styleString.hasPrefix("[")) {
            // Currently the iOS Mapbox SDK does not have a builder for json.
            NSLog("setStyleString - JSON style currently not supported")
        } else {
            mapView.styleURL = URL(string: styleString)
        }
    }
    func setRotateGesturesEnabled(rotateGesturesEnabled: Bool) {
        mapView.allowsRotating = rotateGesturesEnabled
    }
    func setScrollGesturesEnabled(scrollGesturesEnabled: Bool) {
        mapView.allowsScrolling = scrollGesturesEnabled
    }
    func setTiltGesturesEnabled(tiltGesturesEnabled: Bool) {
        mapView.allowsTilting = tiltGesturesEnabled
    }
    func setTrackCameraPosition(trackCameraPosition: Bool) {
        self.trackCameraPosition = trackCameraPosition
    }
    func setZoomGesturesEnabled(zoomGesturesEnabled: Bool) {
        mapView.allowsZooming = zoomGesturesEnabled
    }
    func setMyLocationEnabled(myLocationEnabled: Bool) {
        if (self.myLocationEnabled == myLocationEnabled) {
            return
        }
        self.myLocationEnabled = myLocationEnabled
        updateMyLocationEnabled()
    }
    func setMyLocationTrackingMode(myLocationTrackingMode: MGLUserTrackingMode) {
        mapView.userTrackingMode = myLocationTrackingMode
    }
}
