import Flutter
import Mapbox
import MapboxAnnotationExtension
import UIKit

class MapboxMapController: NSObject, FlutterPlatformView, MGLMapViewDelegate, MapboxMapOptionsSink,
    MGLAnnotationControllerDelegate
{
    private var registrar: FlutterPluginRegistrar
    private var channel: FlutterMethodChannel?

    private var mapView: MGLMapView
    private var isMapReady = false
    private var isFirstStyleLoad = true
    private var onStyleLoadedCalled = false
    private var mapReadyResult: FlutterResult?

    private var initialTilt: CGFloat?
    private var cameraTargetBounds: MGLCoordinateBounds?
    private var trackCameraPosition = false
    private var myLocationEnabled = false

    private var symbolAnnotationController: MGLSymbolAnnotationController?
    private var circleAnnotationController: MGLCircleAnnotationController?
    private var lineAnnotationController: MGLLineAnnotationController?
    private var fillAnnotationController: MGLPolygonAnnotationController?

    private var annotationOrder = [String]()
    private var annotationConsumeTapEvents = [String]()

    private var featureLayerIdentifiers = Set<String>()

    func view() -> UIView {
        return mapView
    }

    init(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        if let args = args as? [String: Any] {
            if let token = args["accessToken"] as? String? {
                MGLAccountManager.accessToken = token
            }
        }
        mapView = MGLMapView(frame: frame)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.registrar = registrar

        super.init()

        channel = FlutterMethodChannel(
            name: "plugins.flutter.io/mapbox_maps_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        channel!
            .setMethodCallHandler { [weak self] in self?.onMethodCall(methodCall: $0, result: $1) }

        mapView.delegate = self

        let singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleMapTap(sender:))
        )
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleMapLongPress(sender:))
        )
        for recognizer in mapView.gestureRecognizers!
            where recognizer is UILongPressGestureRecognizer
        {
            longPress.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(longPress)

        if let args = args as? [String: Any] {
            Convert.interpretMapboxMapOptions(options: args["options"], delegate: self)
            if let initialCameraPosition = args["initialCameraPosition"] as? [String: Any],
               let camera = MGLMapCamera.fromDict(initialCameraPosition, mapView: mapView),
               let zoom = initialCameraPosition["zoom"] as? Double
            {
                mapView.setCenter(
                    camera.centerCoordinate,
                    zoomLevel: zoom,
                    direction: camera.heading,
                    animated: false
                )
                initialTilt = camera.pitch
            }
            if let annotationOrderArg = args["annotationOrder"] as? [String] {
                annotationOrder = annotationOrderArg
            }
            if let annotationConsumeTapEventsArg = args["annotationConsumeTapEvents"] as? [String] {
                annotationConsumeTapEvents = annotationConsumeTapEventsArg
            }
            if let onAttributionClickOverride = args["onAttributionClickOverride"] as? Bool {
                if onAttributionClickOverride {
                    setupAttribution(mapView)
                }
            }
        }
    }

    func removeAllForController(controller: MGLAnnotationController, ids: [String]) {
        let idSet = Set(ids)
        let annotations = controller.styleAnnotations()
        controller.removeStyleAnnotations(annotations.filter { idSet.contains($0.identifier) })
    }

    func onMethodCall(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        switch methodCall.method {
        case "map#waitForMap":
            if isMapReady {
                result(nil)
                // only call map#onStyleLoaded here if isMapReady has happend and isFirstStyleLoad is true
                if isFirstStyleLoad {
                    isFirstStyleLoad = false

                    if let channel = channel {
                        onStyleLoadedCalled = true
                        channel.invokeMethod("map#onStyleLoaded", arguments: nil)
                    }
                }
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
            MGLOfflineStorage.shared.invalidateAmbientCache {
                error in
                if let error = error {
                    result(error)
                } else {
                    result(nil)
                }
            }
        case "map#updateMyLocationTrackingMode":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            if let myLocationTrackingMode = arguments["mode"] as? UInt,
               let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode)
            {
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
               let left = bounds["left"] as? CGFloat,
               let bottom = bounds["bottom"] as? CGFloat,
               let right = bounds["right"] as? CGFloat,
               let animated = arguments["animated"] as? Bool
            {
                mapView.setContentInset(
                    UIEdgeInsets(top: top, left: left, bottom: bottom, right: right),
                    animated: animated
                ) {
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
        case "map#queryRenderedFeatures":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            let layerIds = arguments["layerIds"] as? Set<String>
            var filterExpression: NSPredicate?
            if let filter = arguments["filter"] as? [Any] {
                filterExpression = NSPredicate(mglJSONObject: filter)
            }
            var reply = [String: NSObject]()
            var features: [MGLFeature] = []
            if let x = arguments["x"] as? Double, let y = arguments["y"] as? Double {
                features = mapView.visibleFeatures(
                    at: CGPoint(x: x, y: y),
                    styleLayerIdentifiers: layerIds,
                    predicate: filterExpression
                )
            }
            if let top = arguments["top"] as? Double,
               let bottom = arguments["bottom"] as? Double,
               let left = arguments["left"] as? Double,
               let right = arguments["right"] as? Double
            {
                features = mapView.visibleFeatures(
                    in: CGRect(x: left, y: top, width: right, height: bottom),
                    styleLayerIdentifiers: layerIds,
                    predicate: filterExpression
                )
            }
            var featuresJson = [String]()
            for feature in features {
                let dictionary = feature.geoJSONDictionary()
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: []
                ),
                    let theJSONText = String(data: theJSONData, encoding: .ascii)
                {
                    featuresJson.append(theJSONText)
                }
            }
            reply["features"] = featuresJson as NSObject
            result(reply)
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
        case "map#toScreenLocation":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let latitude = arguments["latitude"] as? Double else { return }
            guard let longitude = arguments["longitude"] as? Double else { return }
            let latlng = CLLocationCoordinate2DMake(latitude, longitude)
            let returnVal = mapView.convert(latlng, toPointTo: mapView)
            var reply = [String: NSObject]()
            reply["x"] = returnVal.x as NSObject
            reply["y"] = returnVal.y as NSObject
            result(reply)
        case "map#toScreenLocationBatch":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let data = arguments["coordinates"] as? FlutterStandardTypedData else { return }
            let latLngs = data.data.withUnsafeBytes {
                Array(
                    UnsafeBufferPointer(
                        start: $0.baseAddress!.assumingMemoryBound(to: Double.self),
                        count: Int(data.elementCount)
                    )
                )
            }
            var reply: [Double] = Array(repeating: 0.0, count: latLngs.count)
            for i in stride(from: 0, to: latLngs.count, by: 2) {
                let coordinate = CLLocationCoordinate2DMake(latLngs[i], latLngs[i + 1])
                let returnVal = mapView.convert(coordinate, toPointTo: mapView)
                reply[i] = Double(returnVal.x)
                reply[i + 1] = Double(returnVal.y)
            }
            result(FlutterStandardTypedData(
                float64: Data(bytes: &reply, count: reply.count * 8)
            ))
        case "map#getMetersPerPixelAtLatitude":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            var reply = [String: NSObject]()
            guard let latitude = arguments["latitude"] as? Double else { return }
            let returnVal = mapView.metersPerPoint(atLatitude: latitude)
            reply["metersperpixel"] = returnVal as NSObject
            result(reply)
        case "map#toLatLng":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let x = arguments["x"] as? Double else { return }
            guard let y = arguments["y"] as? Double else { return }
            let screenPoint = CGPoint(x: x, y: y)
            let coordinates: CLLocationCoordinate2D = mapView.convert(
                screenPoint,
                toCoordinateFrom: mapView
            )
            var reply = [String: NSObject]()
            reply["latitude"] = coordinates.latitude as NSObject
            reply["longitude"] = coordinates.longitude as NSObject
            result(reply)
        case "camera#move":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert
                .parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView)
            {
                mapView.setCamera(camera, animated: false)
            }
            result(nil)
        case "camera#animate":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = Convert
                .parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView)
            {
                if let duration = arguments["duration"] as? TimeInterval {
                    mapView.setCamera(camera, withDuration: TimeInterval(duration / 1000),
                                      animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName
                                          .easeInEaseOut))
                    result(nil)
                }
                mapView.setCamera(camera, animated: true)
            }
            result(nil)
        case "symbols#addAll":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }

            if let options = arguments["options"] as? [[String: Any]] {
                var symbols: [MGLSymbolStyleAnnotation] = []
                for o in options {
                    if let symbol = getSymbolForOptions(options: o) {
                        symbols.append(symbol)
                    }
                }
                if !symbols.isEmpty {
                    symbolAnnotationController.addStyleAnnotations(symbols)
                    symbolAnnotationController
                        .annotationsInteractionEnabled = annotationConsumeTapEvents
                        .contains("AnnotationType.symbol")
                }

                result(symbols.map { $0.identifier })
            } else {
                result(nil)
            }
        case "symbol#update":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let symbolId = arguments["symbol"] as? String else { return }

            for symbol in symbolAnnotationController.styleAnnotations() {
                if symbol.identifier == symbolId {
                    Convert.interpretSymbolOptions(
                        options: arguments["options"],
                        delegate: symbol as! MGLSymbolStyleAnnotation
                    )
                    // Load (updated) icon image from asset if an icon name is supplied.
                    if let options = arguments["options"] as? [String: Any],
                       let iconImage = options["iconImage"] as? String
                    {
                        addIconImageToMap(iconImageName: iconImage)
                    }
                    symbolAnnotationController.updateStyleAnnotation(symbol)
                    break
                }
            }
            result(nil)
        case "symbols#removeAll":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let symbolIds = arguments["ids"] as? [String] else { return }

            removeAllForController(controller: symbolAnnotationController, ids: symbolIds)
            result(nil)

        case "symbol#getGeometry":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let symbolId = arguments["symbol"] as? String else { return }

            var reply: [String: Double]?
            for symbol in symbolAnnotationController.styleAnnotations() {
                if symbol.identifier == symbolId {
                    if let geometry = symbol.geoJSONDictionary["geometry"] as? [String: Any],
                       let coordinates = geometry["coordinates"] as? [Double]
                    {
                        reply = ["latitude": coordinates[1], "longitude": coordinates[0]]
                    }
                    break
                }
            }
            result(reply)
        case "symbolManager#iconAllowOverlap":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let iconAllowOverlap = arguments["iconAllowOverlap"] as? Bool else { return }

            symbolAnnotationController.iconAllowsOverlap = iconAllowOverlap
            result(nil)
        case "symbolManager#iconIgnorePlacement":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let iconIgnorePlacement = arguments["iconIgnorePlacement"] as? Bool
            else { return }

            symbolAnnotationController.iconIgnoresPlacement = iconIgnorePlacement
            result(nil)
        case "symbolManager#textAllowOverlap":
            guard let symbolAnnotationController = symbolAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let textAllowOverlap = arguments["textAllowOverlap"] as? Bool else { return }

            symbolAnnotationController.textAllowsOverlap = textAllowOverlap
            result(nil)
        case "symbolManager#textIgnorePlacement":
            result(FlutterMethodNotImplemented)
        case "circle#add":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            if let options = arguments["options"] as? [String: Any],
               let geometry = options["geometry"] as? [Double]
            {
                // Convert geometry to coordinate and create circle.
                let coordinate = CLLocationCoordinate2DMake(geometry[0], geometry[1])
                let circle = MGLCircleStyleAnnotation(center: coordinate)
                Convert.interpretCircleOptions(options: arguments["options"], delegate: circle)
                circleAnnotationController.addStyleAnnotation(circle)
                circleAnnotationController
                    .annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.circle")
                result(circle.identifier)
            } else {
                result(nil)
            }

        case "circle#addAll":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            var identifier: String?
            if let allOptions = arguments["options"] as? [[String: Any]] {
                var circles: [MGLCircleStyleAnnotation] = []

                for options in allOptions {
                    if let geometry = options["geometry"] as? [Double] {
                        guard geometry.count > 0 else { break }

                        let coordinate = CLLocationCoordinate2DMake(geometry[0], geometry[1])
                        let circle = MGLCircleStyleAnnotation(center: coordinate)
                        Convert.interpretCircleOptions(options: options, delegate: circle)
                        circles.append(circle)
                    }
                }
                if !circles.isEmpty {
                    circleAnnotationController.addStyleAnnotations(circles)
                }
                result(circles.map { $0.identifier })
            } else {
                result(nil)
            }

        case "circle#update":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let circleId = arguments["circle"] as? String else { return }

            for circle in circleAnnotationController.styleAnnotations() {
                if circle.identifier == circleId {
                    Convert.interpretCircleOptions(
                        options: arguments["options"],
                        delegate: circle as! MGLCircleStyleAnnotation
                    )
                    circleAnnotationController.updateStyleAnnotation(circle)
                    break
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
                    break
                }
            }
            result(nil)

        case "circle#removeAll":
            guard let circleAnnotationController = circleAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let ids = arguments["ids"] as? [String] else { return }

            removeAllForController(controller: circleAnnotationController, ids: ids)
            result(nil)

        case "line#add":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }

            if let options = arguments["options"] as? [String: Any] {
                var coordinates = Convert.getCoordinates(options: options)
                let line = MGLLineStyleAnnotation(
                    coordinates: &coordinates,
                    count: UInt(coordinates.count)
                )
                Convert.interpretLineOptions(options: options, delegate: line)
                lineAnnotationController.addStyleAnnotation(line)
                lineAnnotationController.annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.line")
                result(line.identifier)
            } else {
                result(nil)
            }

        case "line#addAll":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }

            var identifier: String?
            if let allOptions = arguments["options"] as? [[String: Any]] {
                var lines: [MGLLineStyleAnnotation] = []

                for options in allOptions {
                    var coordinates = Convert.getCoordinates(options: options)
                    let line = MGLLineStyleAnnotation(
                        coordinates: &coordinates,
                        count: UInt(coordinates.count)
                    )
                    Convert.interpretLineOptions(options: options, delegate: line)
                    lines.append(line)
                }
                if !lines.isEmpty {
                    lineAnnotationController.addStyleAnnotations(lines)
                }
                result(lines.map { $0.identifier })
            } else {
                result(nil)
            }

        case "line#update":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let lineId = arguments["line"] as? String else { return }

            for line in lineAnnotationController.styleAnnotations() {
                if line.identifier == lineId {
                    Convert.interpretGeometryUpdate(
                        options: arguments["options"],
                        delegate: line as! MGLLineStyleAnnotation
                    )
                    Convert.interpretLineOptions(
                        options: arguments["options"],
                        delegate: line as! MGLLineStyleAnnotation
                    )
                    lineAnnotationController.updateStyleAnnotation(line)
                    break
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
                    break
                }
            }
            result(nil)

        case "line#removeAll":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let ids = arguments["ids"] as? [String] else { return }

            removeAllForController(controller: lineAnnotationController, ids: ids)
            result(nil)

        case "symbolLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            addSymbolLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                properties: properties
            )
            result(nil)

        case "lineLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            addLineLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                properties: properties
            )
            result(nil)

        case "fillLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            addFillLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                properties: properties
            )
            result(nil)

        case "circleLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            addCircleLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                properties: properties
            )
            result(nil)

        case "hillshadeLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            addHillshadeLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                properties: properties
            )
            result(nil)

        case "rasterLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            addRasterLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                properties: properties
            )
            result(nil)

        case "line#getGeometry":
            guard let lineAnnotationController = lineAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let lineId = arguments["line"] as? String else { return }

            var reply: [Any]?
            for line in lineAnnotationController.styleAnnotations() {
                if line.identifier == lineId {
                    if let geometry = line.geoJSONDictionary["geometry"] as? [String: Any],
                       let coordinates = geometry["coordinates"] as? [[Double]]
                    {
                        reply = coordinates.map { ["latitude": $0[1], "longitude": $0[0]] }
                    }
                    break
                }
            }
            result(reply)
        case "fill#add":
            guard let fillAnnotationController = fillAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            var identifier: String?
            if let options = arguments["options"] as? [String: Any],
               let geometry = options["geometry"] as? [[[Double]]]
            {
                guard geometry.count > 0 else { break }
                // Convert geometry to coordinate and interior polygonc.
                var fillCoordinates: [CLLocationCoordinate2D] = []
                for coordinate in geometry[0] {
                    fillCoordinates.append(CLLocationCoordinate2DMake(coordinate[0], coordinate[1]))
                }
                let polygons = Convert.toPolygons(geometry: geometry.tail)
                let fill = MGLPolygonStyleAnnotation(
                    coordinates: fillCoordinates,
                    count: UInt(fillCoordinates.count),
                    interiorPolygons: polygons
                )
                Convert.interpretFillOptions(options: arguments["options"], delegate: fill)
                fillAnnotationController.addStyleAnnotation(fill)
                fillAnnotationController.annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.fill")
                identifier = fill.identifier
            }

            result(identifier)

        case "fill#addAll":
            guard let fillAnnotationController = fillAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            // Parse geometry
            var identifier: String?
            if let allOptions = arguments["options"] as? [[String: Any]] {
                var fills: [MGLPolygonStyleAnnotation] = []

                for options in allOptions {
                    if let geometry = options["geometry"] as? [[[Double]]] {
                        guard geometry.count > 0 else { break }
                        // Convert geometry to coordinate and interior polygonc.
                        var fillCoordinates: [CLLocationCoordinate2D] = []
                        for coordinate in geometry[0] {
                            fillCoordinates
                                .append(CLLocationCoordinate2DMake(coordinate[0], coordinate[1]))
                        }
                        let polygons = Convert.toPolygons(geometry: geometry.tail)
                        let fill = MGLPolygonStyleAnnotation(
                            coordinates: fillCoordinates,
                            count: UInt(fillCoordinates.count),
                            interiorPolygons: polygons
                        )
                        Convert.interpretFillOptions(options: options, delegate: fill)
                        fills.append(fill)
                    }
                }
                if !fills.isEmpty {
                    fillAnnotationController.addStyleAnnotations(fills)
                }
                result(fills.map { $0.identifier })
            } else {
                result(nil)
            }

        case "fill#update":
            guard let fillAnnotationController = fillAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let fillId = arguments["fill"] as? String else { return }

            for fill in fillAnnotationController.styleAnnotations() {
                if fill.identifier == fillId {
                    Convert.interpretFillOptions(
                        options: arguments["options"],
                        delegate: fill as! MGLPolygonStyleAnnotation
                    )
                    fillAnnotationController.updateStyleAnnotation(fill)
                    break
                }
            }

            result(nil)
        case "fill#remove":
            guard let fillAnnotationController = fillAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let fillId = arguments["fill"] as? String else { return }

            for fill in fillAnnotationController.styleAnnotations() {
                if fill.identifier == fillId {
                    fillAnnotationController.removeStyleAnnotation(fill)
                    break
                }
            }
            result(nil)

        case "fill#removeAll":
            guard let fillAnnotationController = fillAnnotationController else { return }
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let ids = arguments["ids"] as? [String] else { return }

            removeAllForController(controller: fillAnnotationController, ids: ids)
            result(nil)

        case "style#addImage":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let name = arguments["name"] as? String else { return }
            // guard let length = arguments["length"] as? NSNumber else { return }
            guard let bytes = arguments["bytes"] as? FlutterStandardTypedData else { return }
            guard let sdf = arguments["sdf"] as? Bool else { return }
            guard let data = bytes.data as? Data else { return }
            guard let image = UIImage(data: data, scale: UIScreen.main.scale) else { return }
            if sdf {
                mapView.style?.setImage(image.withRenderingMode(.alwaysTemplate), forName: name)
            } else {
                mapView.style?.setImage(image, forName: name)
            }
            result(nil)

        case "style#addImageSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            guard let bytes = arguments["bytes"] as? FlutterStandardTypedData else { return }
            guard let data = bytes.data as? Data else { return }
            guard let image = UIImage(data: data) else { return }

            guard let coordinates = arguments["coordinates"] as? [[Double]] else { return }
            let quad = MGLCoordinateQuad(
                topLeft: CLLocationCoordinate2D(
                    latitude: coordinates[0][0],
                    longitude: coordinates[0][1]
                ),
                bottomLeft: CLLocationCoordinate2D(
                    latitude: coordinates[3][0],
                    longitude: coordinates[3][1]
                ),
                bottomRight: CLLocationCoordinate2D(
                    latitude: coordinates[2][0],
                    longitude: coordinates[2][1]
                ),
                topRight: CLLocationCoordinate2D(
                    latitude: coordinates[1][0],
                    longitude: coordinates[1][1]
                )
            )

            // Check for duplicateSource error
            if mapView.style?.source(withIdentifier: imageSourceId) != nil {
                result(FlutterError(
                    code: "duplicateSource",
                    message: "Source with imageSourceId \(imageSourceId) already exists",
                    details: "Can't add duplicate source with imageSourceId: \(imageSourceId)"
                ))
                return
            }

            let source = MGLImageSource(
                identifier: imageSourceId,
                coordinateQuad: quad,
                image: image
            )
            mapView.style?.addSource(source)

            result(nil)
        case "style#removeSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let source = mapView.style?.source(withIdentifier: sourceId) else { return }
            mapView.style?.removeSource(source)
            result(nil)
        case "style#addLayer":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageLayerId = arguments["imageLayerId"] as? String else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }

            // Check for duplicateLayer error
            if (mapView.style?.layer(withIdentifier: imageLayerId)) != nil {
                result(FlutterError(
                    code: "duplicateLayer",
                    message: "Layer already exists",
                    details: "Can't add duplicate layer with imageLayerId: \(imageLayerId)"
                ))
                return
            }
            // Check for noSuchSource error
            guard let source = mapView.style?.source(withIdentifier: imageSourceId) else {
                result(FlutterError(
                    code: "noSuchSource",
                    message: "No source found with imageSourceId \(imageSourceId)",
                    details: "Can't add add layer for imageSourceId \(imageLayerId), as the source does not exist."
                ))
                return
            }

            let layer = MGLRasterStyleLayer(identifier: imageLayerId, source: source)
            mapView.style?.addLayer(layer)
            result(nil)
        case "style#addLayerBelow":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageLayerId = arguments["imageLayerId"] as? String else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            guard let belowLayerId = arguments["belowLayerId"] as? String else { return }

            // Check for duplicateLayer error
            if (mapView.style?.layer(withIdentifier: imageLayerId)) != nil {
                result(FlutterError(
                    code: "duplicateLayer",
                    message: "Layer already exists",
                    details: "Can't add duplicate layer with imageLayerId: \(imageLayerId)"
                ))
                return
            }
            // Check for noSuchSource error
            guard let source = mapView.style?.source(withIdentifier: imageSourceId) else {
                result(FlutterError(
                    code: "noSuchSource",
                    message: "No source found with imageSourceId \(imageSourceId)",
                    details: "Can't add add layer for imageSourceId \(imageLayerId), as the source does not exist."
                ))
                return
            }
            // Check for noSuchLayer error
            guard let belowLayer = mapView.style?.layer(withIdentifier: belowLayerId) else {
                result(FlutterError(
                    code: "noSuchLayer",
                    message: "No layer found with layerId \(belowLayerId)",
                    details: "Can't insert layer below layer with id \(belowLayerId), as no such layer exists."
                ))
                return
            }
            let layer = MGLRasterStyleLayer(identifier: imageLayerId, source: source)
            mapView.style?.insertLayer(layer, below: belowLayer)
            result(nil)

        case "style#removeLayer":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let layer = mapView.style?.layer(withIdentifier: layerId) else { return }
            featureLayerIdentifiers.remove(layerId)
            mapView.style?.removeLayer(layer)
            result(nil)

        case "source#addGeoJson":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let geojson = arguments["geojson"] as? String else { return }
            addSourceGeojson(sourceId: sourceId, geojson: geojson)
            result(nil)

        case "style#addSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: Any] else { return }
            addSource(sourceId: sourceId, properties: properties)
            result(nil)

        case "source#setGeoJson":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let geojson = arguments["geojson"] as? String else { return }
            setSource(sourceId: sourceId, geojson: geojson)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getSymbolForOptions(options: [String: Any]) -> MGLSymbolStyleAnnotation? {
        // Parse geometry
        if let geometry = options["geometry"] as? [Double] {
            // Convert geometry to coordinate and create symbol.
            let coordinate = CLLocationCoordinate2DMake(geometry[0], geometry[1])
            let symbol = MGLSymbolStyleAnnotation(coordinate: coordinate)
            Convert.interpretSymbolOptions(options: options, delegate: symbol)
            // Load icon image from asset if an icon name is supplied.
            if let iconImage = options["iconImage"] as? String {
                addIconImageToMap(iconImageName: iconImage)
            }
            return symbol
        }
        return nil
    }

    private func addIconImageToMap(iconImageName: String) {
        // Check if the image has already been added to the map.
        if mapView.style?.image(forName: iconImageName) == nil {
            // Build up the full path of the asset.
            // First find the last '/' ans split the image name in the asset directory and the image file name.
            if let range = iconImageName.range(of: "/", options: [.backwards]) {
                let directory = String(iconImageName[..<range.lowerBound])
                let assetPath = registrar.lookupKey(forAsset: "\(directory)/")
                let fileName = String(iconImageName[range.upperBound...])
                // If we can load the image from file then add it to the map.
                if let imageFromAsset = UIImage.loadFromFile(
                    imagePath: assetPath,
                    imageName: fileName
                ) {
                    mapView.style?.setImage(imageFromAsset, forName: iconImageName)
                }
            }
        }
    }

    private func updateMyLocationEnabled() {
        mapView.showsUserLocation = myLocationEnabled
    }

    private func getCamera() -> MGLMapCamera? {
        return trackCameraPosition ? mapView.camera : nil
    }

    /*
     *  Scan layers from top to bottom and return the first matching feature
     */
    private func firstFeatureOnLayers(at: CGPoint) -> MGLFeature? {
        guard let style = mapView.style else { return nil }

        // get layers in order (featureLayerIdentifiers is unordered)
        let clickableLayers = style.layers.filter { layer in
            featureLayerIdentifiers.contains(layer.identifier)
        }

        for layer in clickableLayers.reversed() {
            let features = mapView.visibleFeatures(
                at: at,
                styleLayerIdentifiers: [layer.identifier]
            )
            if let feature = features.first {
                return feature
            }
        }
        return nil
    }

    /*
     *  UITapGestureRecognizer
     *  On tap invoke the map#onMapClick callback.
     */
    @IBAction func handleMapTap(sender: UITapGestureRecognizer) {
        // Get the CGPoint where the user tapped.
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        if let feature = firstFeatureOnLayers(at: point), let id = feature.identifier {
            channel?.invokeMethod("feature#onTap", arguments: [
                "id": id,
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        } else {
            channel?.invokeMethod("map#onMapClick", arguments: [
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        }
    }

    /*
     *  UILongPressGestureRecognizer
     *  After a long press invoke the map#onMapLongClick callback.
     */
    @IBAction func handleMapLongPress(sender: UILongPressGestureRecognizer) {
        // Fire when the long press starts
        if sender.state == .began {
            // Get the CGPoint where the user tapped.
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            channel?.invokeMethod("map#onMapLongClick", arguments: [
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        }
    }

    /*
     *  MGLAnnotationControllerDelegate
     */
    func annotationController(
        _ annotationController: MGLAnnotationController,
        didSelect styleAnnotation: MGLStyleAnnotation
    ) {
        DispatchQueue.main.async {
            // Remove tint color overlay from selected annotation by
            // deselecting. This is not handled correctly if requested
            // synchronously from the callback.
            annotationController.deselectStyleAnnotation(styleAnnotation)
        }

        guard let channel = channel else {
            return
        }

        if let symbol = styleAnnotation as? MGLSymbolStyleAnnotation {
            channel.invokeMethod("symbol#onTap", arguments: ["symbol": "\(symbol.identifier)"])
        } else if let circle = styleAnnotation as? MGLCircleStyleAnnotation {
            channel.invokeMethod("circle#onTap", arguments: ["circle": "\(circle.identifier)"])
        } else if let line = styleAnnotation as? MGLLineStyleAnnotation {
            channel.invokeMethod("line#onTap", arguments: ["line": "\(line.identifier)"])
        } else if let fill = styleAnnotation as? MGLPolygonStyleAnnotation {
            channel.invokeMethod("fill#onTap", arguments: ["fill": "\(fill.identifier)"])
        }
    }

    // This is required in order to hide the default Maps SDK pin
    func mapView(_: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation {
            return nil
        }
        return MGLAnnotationView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    }

    /*
     * Override the attribution button's click target to handle the event locally.
     * Called if the application supplies an onAttributionClick handler.
     */
    func setupAttribution(_ mapView: MGLMapView) {
        mapView.attributionButton.removeTarget(
            mapView,
            action: #selector(mapView.showAttribution),
            for: .touchUpInside
        )
        mapView.attributionButton.addTarget(
            self,
            action: #selector(showAttribution),
            for: UIControl.Event.touchUpInside
        )
    }

    /*
     * Custom click handler for the attribution button. This callback is bound when
     * the application specifies an onAttributionClick handler.
     */
    @objc func showAttribution() {
        channel?.invokeMethod("map#onAttributionClick", arguments: [])
    }

    /*
     *  MGLMapViewDelegate
     */
    func mapView(_ mapView: MGLMapView, didFinishLoading _: MGLStyle) {
        isMapReady = true
        updateMyLocationEnabled()

        if let initialTilt = initialTilt {
            let camera = mapView.camera
            camera.pitch = initialTilt
            mapView.setCamera(camera, animated: false)
        }

        for annotationType in annotationOrder {
            switch annotationType {
            case "AnnotationType.fill":
                fillAnnotationController = MGLPolygonAnnotationController(mapView: self.mapView)
                fillAnnotationController!.annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.fill")
                fillAnnotationController?.delegate = self
            case "AnnotationType.line":
                lineAnnotationController = MGLLineAnnotationController(mapView: self.mapView)
                lineAnnotationController!.annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.line")

                lineAnnotationController?.delegate = self
            case "AnnotationType.circle":
                circleAnnotationController = MGLCircleAnnotationController(mapView: self.mapView)
                circleAnnotationController!
                    .annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.circle")
                circleAnnotationController?.delegate = self
            case "AnnotationType.symbol":
                symbolAnnotationController = MGLSymbolAnnotationController(mapView: self.mapView)
                symbolAnnotationController!
                    .annotationsInteractionEnabled = annotationConsumeTapEvents
                    .contains("AnnotationType.symbol")
                symbolAnnotationController?.delegate = self
            default:
                print(
                    "Unknown annotation type: \(annotationType), must be either 'fill', 'line', 'circle' or 'symbol'"
                )
            }
        }

        mapReadyResult?(nil)

        // On first launch we only call map#onStyleLoaded if map#waitForMap has already been called
        if !isFirstStyleLoad || mapReadyResult != nil {
            isFirstStyleLoad = false

            if let channel = channel {
                channel.invokeMethod("map#onStyleLoaded", arguments: nil)
            }
        }
    }

    func mapView(_ mapView: MGLMapView, shouldChangeFrom _: MGLMapCamera,
                 to newCamera: MGLMapCamera) -> Bool
    {
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
        let intersects = MGLCoordinateInCoordinateBounds(newVisibleCoordinates.ne, bbox) &&
            MGLCoordinateInCoordinateBounds(newVisibleCoordinates.sw, bbox)

        return inside && intersects
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Only for Symbols images should loaded.
        guard let symbol = annotation as? Symbol,
              let iconImageFullPath = symbol.iconImage
        else {
            return nil
        }
        // Reuse existing annotations for better performance.
        var annotationImage = mapView
            .dequeueReusableAnnotationImage(withIdentifier: iconImageFullPath)
        if annotationImage == nil {
            // Initialize the annotation image (from predefined assets symbol folder).
            if let range = iconImageFullPath.range(of: "/", options: [.backwards]) {
                let directory = String(iconImageFullPath[..<range.lowerBound])
                let assetPath = registrar.lookupKey(forAsset: "\(directory)/")
                let iconImageName = String(iconImageFullPath[range.upperBound...])
                let image = UIImage.loadFromFile(imagePath: assetPath, imageName: iconImageName)
                if let image = image {
                    annotationImage = MGLAnnotationImage(
                        image: image,
                        reuseIdentifier: iconImageFullPath
                    )
                }
            }
        }
        return annotationImage
    }

    // On tap invoke the symbol#onTap callback.
    func mapView(_: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let symbol = annotation as? Symbol {
            channel?.invokeMethod("symbol#onTap", arguments: ["symbol": "\(symbol.id)"])
        }
    }

    // Allow callout view to appear when an annotation is tapped.
    func mapView(_: MGLMapView, annotationCanShowCallout _: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let channel = channel, let userLocation = userLocation,
           let location = userLocation.location
        {
            channel.invokeMethod("map#onUserLocationUpdated", arguments: [
                "userLocation": location.toDict(),
                "heading": userLocation.heading?.toDict(),
            ])
        }
    }

    func mapView(_: MGLMapView, didChange mode: MGLUserTrackingMode, animated _: Bool) {
        if let channel = channel {
            channel.invokeMethod("map#onCameraTrackingChanged", arguments: ["mode": mode.rawValue])
            if mode == .none {
                channel.invokeMethod("map#onCameraTrackingDismissed", arguments: [])
            }
        }
    }

    func addSymbolLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLSymbolStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addSymbolProperties(
                    symbolLayer: layer,
                    properties: properties
                )
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addLineLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLLineStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addLineProperties(lineLayer: layer, properties: properties)
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addFillLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLFillStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addFillProperties(fillLayer: layer, properties: properties)
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addCircleLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLCircleStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addCircleProperties(
                    circleLayer: layer,
                    properties: properties
                )
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addHillshadeLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLHillshadeStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addHillshadeProperties(
                    hillshadeLayer: layer,
                    properties: properties
                )
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addRasterLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLRasterStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addRasterProperties(
                    rasterLayer: layer,
                    properties: properties
                )
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                featureLayerIdentifiers.insert(layerId)
            }
        }
    }

    func addSource(sourceId: String, properties: [String: Any]) {
        if let style = mapView.style, let type = properties["type"] as? String {
            var source: MGLSource?

            switch type {
            case "vector":
                source = SourcePropertyConverter.buildVectorTileSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "raster":
                source = SourcePropertyConverter.buildRasterTileSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "raster-dem":
                source = SourcePropertyConverter.buildRasterDemSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "image":
                source = SourcePropertyConverter.buildImageSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "geojson":
                source = SourcePropertyConverter.buildShapeSource(
                    identifier: sourceId,
                    properties: properties
                )
            default:
                // unsupported source type
                source = nil
            }
            if let source = source {
                style.addSource(source)
            }
        }
    }

    func mapViewDidBecomeIdle(_: MGLMapView) {
        if let channel = channel {
            channel.invokeMethod("map#onIdle", arguments: [])
        }
    }

    func mapView(_: MGLMapView, regionWillChangeAnimated _: Bool) {
        if let channel = channel {
            channel.invokeMethod("camera#onMoveStarted", arguments: [])
        }
    }

    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if !trackCameraPosition { return }
        if let channel = channel {
            channel.invokeMethod("camera#onMove", arguments: [
                "position": getCamera()?.toDict(mapView: mapView),
            ])
        }
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated _: Bool) {
        let arguments = trackCameraPosition ? [
            "position": getCamera()?.toDict(mapView: mapView)
        ] : [:]
        if let channel = channel {
            channel.invokeMethod("camera#onIdle", arguments: arguments)
        }
    }

    func addSourceGeojson(sourceId: String, geojson: String) {
        do {
            let parsed = try MGLShape(
                data: geojson.data(using: .utf8)!,
                encoding: String.Encoding.utf8.rawValue
            )
            let source = MGLShapeSource(identifier: sourceId, shape: parsed, options: [:])
            mapView.style?.addSource(source)
        } catch {}
    }

    func setSource(sourceId: String, geojson: String) {
        do {
            let parsed = try MGLShape(
                data: geojson.data(using: .utf8)!,
                encoding: String.Encoding.utf8.rawValue
            )
            if let source = mapView.style?.source(withIdentifier: sourceId) as? MGLShapeSource {
                source.shape = parsed
            }
        } catch {}
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
        // Check if json, url, absolute path or asset path:
        if styleString.isEmpty {
            NSLog("setStyleString - string empty")
        } else if styleString.hasPrefix("{") || styleString.hasPrefix("[") {
            // Currently the iOS Mapbox SDK does not have a builder for json.
            NSLog("setStyleString - JSON style currently not supported")
        } else if styleString.hasPrefix("/") {
            // Absolute path
            mapView.styleURL = URL(fileURLWithPath: styleString, isDirectory: false)
        } else if
            !styleString.hasPrefix("http://"),
            !styleString.hasPrefix("https://"),
            !styleString.hasPrefix("mapbox://")
        {
            // We are assuming that the style will be loaded from an asset here.
            let assetPath = registrar.lookupKey(forAsset: styleString)
            mapView.styleURL = URL(string: assetPath, relativeTo: Bundle.main.resourceURL)

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
        if self.myLocationEnabled == myLocationEnabled {
            return
        }
        self.myLocationEnabled = myLocationEnabled
        updateMyLocationEnabled()
    }

    func setMyLocationTrackingMode(myLocationTrackingMode: MGLUserTrackingMode) {
        mapView.userTrackingMode = myLocationTrackingMode
    }

    func setMyLocationRenderMode(myLocationRenderMode: MyLocationRenderMode) {
        switch myLocationRenderMode {
        case .Normal:
            mapView.showsUserHeadingIndicator = false
        case .Compass:
            mapView.showsUserHeadingIndicator = true
        case .Gps:
            NSLog("RenderMode.GPS currently not supported")
        }
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

    func setAttributionButtonPosition(position: MGLOrnamentPosition) {
        mapView.attributionButtonPosition = position
    }
}
