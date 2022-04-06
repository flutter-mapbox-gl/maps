import Mapbox
import MapboxAnnotationExtension

class Convert {
    class func interpretMapboxMapOptions(options: Any?, delegate: MapboxMapOptionsSink) {
        guard let options = options as? [String: Any] else { return }
        if let cameraTargetBounds = options["cameraTargetBounds"] as? [[[Double]]] {
            delegate
                .setCameraTargetBounds(bounds: MGLCoordinateBounds.fromArray(cameraTargetBounds[0]))
        }
        if let compassEnabled = options["compassEnabled"] as? Bool {
            delegate.setCompassEnabled(compassEnabled: compassEnabled)
        }
        if let minMaxZoomPreference = options["minMaxZoomPreference"] as? [Double] {
            delegate.setMinMaxZoomPreference(
                min: minMaxZoomPreference[0],
                max: minMaxZoomPreference[1]
            )
        }
        if let styleString = options["styleString"] as? String {
            delegate.setStyleString(styleString: styleString)
        }
        if let rotateGesturesEnabled = options["rotateGesturesEnabled"] as? Bool {
            delegate.setRotateGesturesEnabled(rotateGesturesEnabled: rotateGesturesEnabled)
        }
        if let scrollGesturesEnabled = options["scrollGesturesEnabled"] as? Bool {
            delegate.setScrollGesturesEnabled(scrollGesturesEnabled: scrollGesturesEnabled)
        }
        if let tiltGesturesEnabled = options["tiltGesturesEnabled"] as? Bool {
            delegate.setTiltGesturesEnabled(tiltGesturesEnabled: tiltGesturesEnabled)
        }
        if let trackCameraPosition = options["trackCameraPosition"] as? Bool {
            delegate.setTrackCameraPosition(trackCameraPosition: trackCameraPosition)
        }
        if let zoomGesturesEnabled = options["zoomGesturesEnabled"] as? Bool {
            delegate.setZoomGesturesEnabled(zoomGesturesEnabled: zoomGesturesEnabled)
        }
        if let myLocationEnabled = options["myLocationEnabled"] as? Bool {
            delegate.setMyLocationEnabled(myLocationEnabled: myLocationEnabled)
        }
        if let myLocationTrackingMode = options["myLocationTrackingMode"] as? UInt,
           let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode)
        {
            delegate.setMyLocationTrackingMode(myLocationTrackingMode: trackingMode)
        }
        if let myLocationRenderMode = options["myLocationRenderMode"] as? Int,
           let renderMode = MyLocationRenderMode(rawValue: myLocationRenderMode)
        {
            delegate.setMyLocationRenderMode(myLocationRenderMode: renderMode)
        }
        if let logoViewMargins = options["logoViewMargins"] as? [Double] {
            delegate.setLogoViewMargins(x: logoViewMargins[0], y: logoViewMargins[1])
        }
        if let compassViewPosition = options["compassViewPosition"] as? UInt,
           let position = MGLOrnamentPosition(rawValue: compassViewPosition)
        {
            delegate.setCompassViewPosition(position: position)
        }
        if let compassViewMargins = options["compassViewMargins"] as? [Double] {
            delegate.setCompassViewMargins(x: compassViewMargins[0], y: compassViewMargins[1])
        }
        if let attributionButtonMargins = options["attributionButtonMargins"] as? [Double] {
            delegate.setAttributionButtonMargins(
                x: attributionButtonMargins[0],
                y: attributionButtonMargins[1]
            )
        }
        if let attributionButtonPosition = options["attributionButtonPosition"] as? UInt,
           let position = MGLOrnamentPosition(rawValue: attributionButtonPosition)
        {
            delegate.setAttributionButtonPosition(position: position)
        }
    }

    class func parseCameraUpdate(cameraUpdate: [Any], mapView: MGLMapView) -> MGLMapCamera? {
        guard let type = cameraUpdate[0] as? String else { return nil }
        switch type {
        case "newCameraPosition":
            guard let cameraPosition = cameraUpdate[1] as? [String: Any] else { return nil }
            return MGLMapCamera.fromDict(cameraPosition, mapView: mapView)
        case "newLatLng":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            return camera
        case "newLatLngBounds":
            guard let bounds = cameraUpdate[1] as? [[Double]] else { return nil }
            guard let paddingLeft = cameraUpdate[2] as? CGFloat else { return nil }
            guard let paddingTop = cameraUpdate[3] as? CGFloat else { return nil }
            guard let paddingRight = cameraUpdate[4] as? CGFloat else { return nil }
            guard let paddingBottom = cameraUpdate[5] as? CGFloat else { return nil }
            return mapView.cameraThatFitsCoordinateBounds(
                MGLCoordinateBounds.fromArray(bounds),
                edgePadding: UIEdgeInsets(
                    top: paddingTop,
                    left: paddingLeft,
                    bottom: paddingBottom,
                    right: paddingRight
                )
            )
        case "newLatLngZoom":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            guard let zoom = cameraUpdate[2] as? Double else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            return MGLMapCamera(
                lookingAtCenter: camera.centerCoordinate,
                altitude: altitude,
                pitch: camera.pitch,
                heading: camera.heading
            )
        case "scrollBy":
            guard let x = cameraUpdate[1] as? CGFloat else { return nil }
            guard let y = cameraUpdate[2] as? CGFloat else { return nil }
            let camera = mapView.camera
            let mapPoint = mapView.convert(camera.centerCoordinate, toPointTo: mapView)
            let movedPoint = CGPoint(x: mapPoint.x + x, y: mapPoint.y + y)
            camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
            return camera
        case "zoomBy":
            guard let zoomBy = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom + zoomBy, mapView: mapView)
            camera.altitude = altitude
            if cameraUpdate.count == 2 {
                return camera
            } else {
                guard let point = cameraUpdate[2] as? [CGFloat],
                      point.count == 2 else { return nil }
                let movedPoint = CGPoint(x: point[0], y: point[1])
                camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
                return camera
            }
        case "zoomIn":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom + 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomOut":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom - 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomTo":
            guard let zoom = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "bearingTo":
            guard let bearing = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            camera.heading = bearing
            return camera
        case "tiltTo":
            guard let tilt = cameraUpdate[1] as? CGFloat else { return nil }
            let camera = mapView.camera
            camera.pitch = tilt
            return camera
        default:
            print("\(type) not implemented!")
        }
        return nil
    }

    class func getZoom(mapView: MGLMapView) -> Double {
        return MGLZoomLevelForAltitude(
            mapView.camera.altitude,
            mapView.camera.pitch,
            mapView.camera.centerCoordinate.latitude,
            mapView.frame.size
        )
    }

    class func getAltitude(zoom: Double, mapView: MGLMapView) -> Double {
        return MGLAltitudeForZoomLevel(
            zoom,
            mapView.camera.pitch,
            mapView.camera.centerCoordinate.latitude,
            mapView.frame.size
        )
    }

    class func getCoordinates(options: Any?) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []

        if let options = options as? [String: Any],
           let geometry = options["geometry"] as? [[Double]], geometry.count > 0
        {
            for coordinate in geometry {
                coordinates.append(CLLocationCoordinate2DMake(coordinate[0], coordinate[1]))
            }
        }
        return coordinates
    }
}
