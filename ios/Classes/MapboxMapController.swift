import Flutter
import UIKit
import Mapbox
import MapboxAnnotationExtension

class MapboxMapController: NSObject, FlutterPlatformView, MGLMapViewDelegate, MapboxMapOptionsSink, MGLAnnotationControllerDelegate {
    
    private var registrar: FlutterPluginRegistrar
    private var channel: FlutterMethodChannel?
    
    private var mapView: MGLMapView
    private var isMapReady = false
    private var mapReadyResult: FlutterResult?
    
    private var initialTilt: CGFloat?
    private var cameraTargetBounds: MGLCoordinateBounds?
    private var trackCameraPosition = false
    private var myLocationEnabled = false

    private var symbolAnnotationController: MGLSymbolAnnotationController?
    private var circleAnnotationController: MGLCircleAnnotationController?
    private var lineAnnotationController: MGLLineAnnotationController?

    func view() -> UIView {
        return mapView
    }
    
    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, registrar: FlutterPluginRegistrar) {
        mapView = MGLMapView(frame: frame)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.registrar = registrar
        
        super.init()
        
        channel = FlutterMethodChannel(name: "plugins.flutter.io/mapbox_maps_\(viewId)", binaryMessenger: registrar.messenger())
        channel!.setMethodCallHandler(onMethodCall)
        
        mapView.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)
        
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
        case "map#invalidateAmbientCache":
            MGLOfflineStorage.shared.invalidateAmbientCache{
                (error) in
                if let error = error {
                    result(error)
                } else{
                    result(nil)
                }
            }
        case "map#updateMyLocationTrackingMode":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            if let myLocationTrackingMode = arguments["mode"] as? UInt, let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode) {
                setMyLocationTrackingMode(myLocationTrackingMode: trackingMode)
            }
            result(nil)
        case "map#matchMapLanguageWithDeviceDefault":
            if let style = mapView.style {
                style.localizeLabels(into: nil)
            }
            result(nil)
        case "map#updateContentInsets":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }

            if let bounds = arguments["bounds"] as? [String: Any],
                let top = bounds["top"] as? CGFloat,
                let left = bounds["left"]  as? CGFloat,
                let bottom = bounds["bottom"] as? CGFloat,
                let right = bounds["right"] as? CGFloat,
                let animated = arguments["animated"] as? Bool {
                mapView.setContentInset(UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), animated: animated) {
                    result(nil)
                }
            } else {
                result(nil)
            }
        case "map#setMapLanguage":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            if let localIdentifier = arguments["language"] as? String, let style = mapView.style {
                let locale = Locale(identifier: localIdentifier)
                style.localizeLabels(into: locale)
            }
            result(nil)
        case "map#setTelemetryEnabled":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            let telemetryEnabled = arguments["enabled"] as? Bool
            UserDefaults.standard.set(telemetryEnabled, forKey: "MGLMapboxMetricsEnabled")
            result(nil)
        case "map#getTelemetryEnabled":
            let telemetryEnabled = UserDefaults.standard.bool(forKey: "MGLMapboxMetricsEnabled")
            result(telemetryEnabled)
        case "map#getVisibleRegion":
            var reply = [String: NSObject]()
            let visibleRegion = mapView.visibleCoordinateBounds
            reply["sw"] = [visibleRegion.sw.latitude, visibleRegion.sw.longitude] as NSObject
            reply["ne"] = [visibleRegion.ne.latitude, visibleRegion.ne.longitude] as NSObject
            result(reply)
        case "camera#move":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView) {
                mapView.setCamera(camera, animated: false)
            }
            result(nil)
        case "camera#animate":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView) {
                mapView.setCamera(camera, animated: true)
            }
            result(nil)
        case "symbol#add":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            
            // Parse geometry
            if let options = arguments["options"] as? [String: Any],
                let geometry = options["geometry"] as? [Double] {
                // Convert geometry to coordinate and create symbol.
                let coordinate = CLLocationCoordinate2DMake(geometry[0], geometry[1])
                let symbol = MGLSymbolStyleAnnotation(coordinate: coordinate)
                Convert.interpretSymbolOptions(options: arguments["options"], delegate: symbol)
                // Load icon image from asset if an icon name is supplied.
                if let iconImage = options["iconImage"] as? String {
                    addIconImageToMap(iconImageName: iconImage)
                }
                symbolAnnotationController.addStyleAnnotation(symbol)
                result(symbol.identifier)
            } else {
                result(nil)
            }
        case "symbol#update":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let symbolId = arguments["symbol"] as? String else { return }

            for symbol in symbolAnnotationController.styleAnnotations(){
                if symbol.identifier == symbolId {
                    Convert.interpretSymbolOptions(options: arguments["options"], delegate: symbol as! MGLSymbolStyleAnnotation)
                    // Load (updated) icon image from asset if an icon name is supplied.
                    if let options = arguments["options"] as? [String: Any],
                        let iconImage = options["iconImage"] as? String {
                        addIconImageToMap(iconImageName: iconImage)
                    }
                    symbolAnnotationController.updateStyleAnnotation(symbol)
                    break;
                }
            }
            result(nil)
        case "symbol#remove":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let symbolId = arguments["symbol"] as? String else { return }

            for symbol in symbolAnnotationController.styleAnnotations(){
                if symbol.identifier == symbolId {
                    symbolAnnotationController.removeStyleAnnotation(symbol)
                    break;
                }
            }
            result(nil)
        case "circle#add":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            if let options = arguments["options"] as? [String: Any],
                let geometry = options["geometry"] as? [Double] {
                // Convert geometry to coordinate and create circle.
                let coordinate = CLLocationCoordinate2DMake(geometry[0], geometry[1])
                let circle = MGLCircleStyleAnnotation(center: coordinate)
                Convert.interpretCircleOptions(options: arguments["options"], delegate: circle)
                circleAnnotationController.addStyleAnnotation(circle)
                result(circle.identifier)
            } else {
                result(nil)
            }
        case "circle#update":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let circleId = arguments["circle"] as? String else { return }
            
            for circle in circleAnnotationController.styleAnnotations() {
                if circle.identifier == circleId {
                    Convert.interpretCircleOptions(options: arguments["options"], delegate: circle as! MGLCircleStyleAnnotation)
                    circleAnnotationController.updateStyleAnnotation(circle)
                    break;
                }
            }
            result(nil)
        case "circle#remove":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let circleId = arguments["circle"] as? String else { return }
            
            for circle in circleAnnotationController.styleAnnotations() {
                if circle.identifier == circleId {
                    circleAnnotationController.removeStyleAnnotation(circle)
                    break;
                }
            }
            result(nil)
        case "line#add":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            if let options = arguments["options"] as? [String: Any],
                let geometry = options["geometry"] as? [[Double]] {
                // Convert geometry to coordinate and create a line.
                var lineCoordinates: [CLLocationCoordinate2D] = []
                for coordinate in geometry {
                    lineCoordinates.append(CLLocationCoordinate2DMake(coordinate[0], coordinate[1]))
                }
                let line = MGLLineStyleAnnotation(coordinates: lineCoordinates, count: UInt(lineCoordinates.count))
                Convert.interpretLineOptions(options: arguments["options"], delegate: line)
                lineAnnotationController.addStyleAnnotation(line)
                result(line.identifier)
            } else {
                result(nil)
            }
        case "line#update":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let lineId = arguments["line"] as? String else { return }
            
            for line in lineAnnotationController.styleAnnotations() {
                if line.identifier == lineId {
                    Convert.interpretLineOptions(options: arguments["options"], delegate: line as! MGLLineStyleAnnotation)
                    lineAnnotationController.updateStyleAnnotation(line)
                    break;
                }
            }
            result(nil)
        case "line#remove":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let lineId = arguments["line"] as? String else { return }
            
            for line in lineAnnotationController.styleAnnotations() {
                if line.identifier == lineId {
                    lineAnnotationController.removeStyleAnnotation(line)
                    break;
                }
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func addIconImageToMap(iconImageName: String) {
        // Check if the image has already been added to the map.
        if self.mapView.style?.image(forName: iconImageName) == nil {
            // Build up the full path of the asset.
            // First find the last '/' ans split the image name in the asset directory and the image file name.
            if let range = iconImageName.range(of: "/", options: [.backwards]) {
                let directory = String(iconImageName[..<range.lowerBound])
                let assetPath = registrar.lookupKey(forAsset: "\(directory)/")
                let fileName = String(iconImageName[range.upperBound...])
                // If we can load the image from file then add it to the map.
                if let imageFromAsset = UIImage.loadFromFile(imagePath: assetPath, imageName: fileName) {
                    self.mapView.style?.setImage(imageFromAsset, forName: iconImageName)
                }
            }
        }
    }

    private func updateMyLocationEnabled() {
        mapView.showsUserLocation = self.myLocationEnabled
    }
    
    private func getCamera() -> MGLMapCamera? {
        return trackCameraPosition ? mapView.camera : nil
        
    }
    
    /*
    *  UITapGestureRecognizer
    *  On tap invoke the map#onMapClick callback.
    */
    @objc @IBAction func handleMapTap(sender: UITapGestureRecognizer) {
        // Get the CGPoint where the user tapped.
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        channel?.invokeMethod("map#onMapClick", arguments: [
                      "x": point.x,
                      "y": point.y,
                      "lng": coordinate.longitude,
                      "lat": coordinate.latitude,
                  ])
    }
    
    /*
     *  MGLAnnotationControllerDelegate
     */
    func annotationController(_ annotationController: MGLAnnotationController, didSelect styleAnnotation: MGLStyleAnnotation) {
        guard let channel = channel else {
            return
        }
        
        if let symbol = styleAnnotation as? MGLSymbolStyleAnnotation {
            channel.invokeMethod("symbol#onTap", arguments: ["symbol" : "\(symbol.identifier)"])
        } else if let circle = styleAnnotation as? MGLCircleStyleAnnotation {
            channel.invokeMethod("circle#onTap", arguments: ["circle" : "\(circle.identifier)"])
        } else if let line = styleAnnotation as? MGLLineStyleAnnotation {
            channel.invokeMethod("line#onTap", arguments: ["line" : "\(line.identifier)"])
        }
    }
    
    // This is required in order to hide the default Maps SDK pin
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation {
            return nil
        }
        return MGLAnnotationView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
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

        lineAnnotationController = MGLLineAnnotationController(mapView: self.mapView)
        lineAnnotationController!.annotationsInteractionEnabled = true
        lineAnnotationController?.delegate = self

        symbolAnnotationController = MGLSymbolAnnotationController(mapView: self.mapView)
        symbolAnnotationController!.annotationsInteractionEnabled = true
        symbolAnnotationController?.delegate = self
        
        circleAnnotationController = MGLCircleAnnotationController(mapView: self.mapView)
        circleAnnotationController!.annotationsInteractionEnabled = true
        circleAnnotationController?.delegate = self

        mapReadyResult?(nil)
        if let channel = channel {
            channel.invokeMethod("map#onStyleLoaded", arguments: nil)
        }
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
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Only for Symbols images should loaded.
        guard let symbol = annotation as? Symbol,
            let iconImageFullPath = symbol.iconImage else {
                return nil
        }
        // Reuse existing annotations for better performance.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: iconImageFullPath)
        if annotationImage == nil {
            // Initialize the annotation image (from predefined assets symbol folder).
            if let range = iconImageFullPath.range(of: "/", options: [.backwards]) {
                let directory = String(iconImageFullPath[..<range.lowerBound])
                let assetPath = registrar.lookupKey(forAsset: "\(directory)/")
                let iconImageName = String(iconImageFullPath[range.upperBound...])
                let image = UIImage.loadFromFile(imagePath: assetPath, imageName: iconImageName)
                if let image = image {
                    annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: iconImageFullPath)
                }
            }
        }
        return annotationImage
    }
    
    // On tap invoke the symbol#onTap callback.
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
       if let symbol = annotation as? Symbol {
            channel?.invokeMethod("symbol#onTap", arguments: ["symbol" : "\(symbol.id)"])
        
        }
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
   
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        if let channel = channel {
            channel.invokeMethod("map#onCameraTrackingChanged", arguments: ["mode": mode.rawValue])
            if mode == .none {
                channel.invokeMethod("map#onCameraTrackingDismissed", arguments: [])
            }
        }
    }
    
    func mapViewDidBecomeIdle(_ mapView: MGLMapView) {
        if let channel = channel {
            channel.invokeMethod("map#onIdle", arguments: []);
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        if let channel = channel {
            channel.invokeMethod("camera#onMoveStarted", arguments: []);
        }
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if !trackCameraPosition { return };
        if let channel = channel {
            channel.invokeMethod("camera#onMove", arguments: [
                "position": getCamera()?.toDict(mapView: mapView)
            ]);
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        if let channel = channel {
            channel.invokeMethod("camera#onIdle", arguments: []);
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
    func setLogoViewMargins(x: Double, y: Double) {
        mapView.logoViewMargins = CGPoint(x: x, y: y)
    }
    func setCompassViewPosition(position: MGLOrnamentPosition) {
        mapView.compassViewPosition = position
    }
    func setCompassViewMargins(x: Double, y: Double) {
        mapView.compassViewMargins = CGPoint(x: x, y: y)
    }
    func setAttributionButtonMargins(x: Double, y: Double) {
        mapView.attributionButtonMargins = CGPoint(x: x, y: y)
    }
}
