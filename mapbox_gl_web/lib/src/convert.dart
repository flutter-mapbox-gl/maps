part of mapbox_gl_web;

class Convert {
  static void interpretMapboxMapOptions(
      Map<String, dynamic> options, MapboxMapOptionsSink sink) {
    if (options.containsKey('cameraTargetBounds')) {
      final bounds = options['cameraTargetBounds'][0];
      if (bounds == null) {
        sink.setCameraTargetBounds(null);
      } else {
        sink.setCameraTargetBounds(
          LatLngBounds(
            southwest: LatLng(bounds[0][0], bounds[0][1]),
            northeast: LatLng(bounds[1][0], bounds[1][1]),
          ),
        );
      }
    }
    if (options.containsKey('compassEnabled')) {
      sink.setCompassEnabled(options['compassEnabled']);
    }
    if (options.containsKey('styleString')) {
      sink.setStyleString(options['styleString']);
    }
    if (options.containsKey('minMaxZoomPreference')) {
      sink.setMinMaxZoomPreference(options['minMaxZoomPreference'][0],
          options['minMaxZoomPreference'][1]);
    }
    if (options.containsKey('rotateGesturesEnabled')) {
      sink.setRotateGesturesEnabled(options['rotateGesturesEnabled']);
    }
    if (options.containsKey('scrollGesturesEnabled')) {
      sink.setScrollGesturesEnabled(options['scrollGesturesEnabled']);
    }
    if (options.containsKey('tiltGesturesEnabled')) {
      sink.setTiltGesturesEnabled(options['tiltGesturesEnabled']);
    }
    if (options.containsKey('trackCameraPosition')) {
      sink.setTrackCameraPosition(options['trackCameraPosition']);
    }
    if (options.containsKey('zoomGesturesEnabled')) {
      sink.setZoomGesturesEnabled(options['zoomGesturesEnabled']);
    }
    if (options.containsKey('myLocationEnabled')) {
      sink.setMyLocationEnabled(options['myLocationEnabled']);
    }
    if (options.containsKey('myLocationTrackingMode')) {
      sink.setMyLocationTrackingMode(options['myLocationTrackingMode']);
    }
    if (options.containsKey('myLocationRenderMode')) {
      sink.setMyLocationRenderMode(options['myLocationRenderMode']);
    }
    if (options.containsKey('logoViewMargins')) {
      sink.setLogoViewMargins(
          options['logoViewMargins'][0], options['logoViewMargins'][1]);
    }
    if (options.containsKey('compassViewPosition')) {
      sink.setCompassGravity(options['compassViewPosition']);
    }
    if (options.containsKey('compassViewMargins')) {
      sink.setCompassViewMargins(
          options['compassViewMargins'][0], options['compassViewMargins'][1]);
    }
    if (options.containsKey('attributionButtonMargins')) {
      sink.setAttributionButtonMargins(options['attributionButtonMargins'][0],
          options['attributionButtonMargins'][1]);
    }
  }

  static CameraOptions toCameraOptions(
      CameraUpdate cameraUpdate, MapboxMap mapboxMap) {
    final List<dynamic> json = cameraUpdate.toJson();
    final type = json[0];
    switch (type) {
      case 'newCameraPosition':
        final camera = json[1];
        return CameraOptions(
          center: LngLat(camera['target'][1], camera['target'][0]),
          zoom: camera['zoom'],
          pitch: camera['tilt'],
          bearing: camera['bearing'],
        );
      case 'newLatLng':
        final target = json[1];
        return CameraOptions(
          center: LngLat(target[1], target[0]),
          zoom: mapboxMap.getZoom(),
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'newLatLngBounds':
        final bounds = json[1];
        final padding = json[2];
        final camera = mapboxMap.cameraForBounds(
            LngLatBounds(
              LngLat(bounds[0][1], bounds[0][0]),
              LngLat(bounds[1][1], bounds[1][0]),
            ),
            {
              'padding': {
                'top': padding,
                'bottom': padding,
                'left': padding,
                'right': padding
              }
            });
        return camera;
      case 'newLatLngZoom':
        final target = json[1];
        final zoom = json[2];
        return CameraOptions(
          center: LngLat(target[1], target[0]),
          zoom: zoom,
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'scrollBy':
        final x = json[1];
        final y = json[2];
        final mapbox.Point point = mapboxMap.project(mapboxMap.getCenter());
        return CameraOptions(
          center: mapboxMap.unproject(mapbox.Point(point.x + x, point.y + y)),
          zoom: mapboxMap.getZoom(),
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );

      case 'zoomBy':
        final zoom = json[1];
        if (json.length == 2) {
          return CameraOptions(
            center: mapboxMap.getCenter(),
            zoom: mapboxMap.getZoom() + zoom,
            pitch: mapboxMap.getPitch(),
            bearing: mapboxMap.getBearing(),
          );
        }
        final point = json[2];
        return CameraOptions(
          center: mapboxMap.unproject(mapbox.Point(point[0], point[1])),
          zoom: mapboxMap.getZoom() + zoom,
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'zoomIn':
        return CameraOptions(
          center: mapboxMap.getCenter(),
          zoom: mapboxMap.getZoom() + 1,
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'zoomOut':
        return CameraOptions(
          center: mapboxMap.getCenter(),
          zoom: mapboxMap.getZoom() - 1,
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'zoomTo':
        final zoom = json[1];
        return CameraOptions(
          center: mapboxMap.getCenter(),
          zoom: zoom,
          pitch: mapboxMap.getPitch(),
          bearing: mapboxMap.getBearing(),
        );
      case 'bearingTo':
        final bearing = json[1];
        return CameraOptions(
          center: mapboxMap.getCenter(),
          zoom: mapboxMap.getZoom(),
          pitch: mapboxMap.getPitch(),
          bearing: bearing,
        );
      case 'tiltTo':
        final tilt = json[1];
        return CameraOptions(
          center: mapboxMap.getCenter(),
          zoom: mapboxMap.getZoom(),
          pitch: tilt,
          bearing: mapboxMap.getBearing(),
        );
      default:
        throw UnimplementedError('Cannot interpret $type as CameraUpdate');
    }
  }

  static void interpretSymbolOptions(
      Map<String, dynamic> options, MapboxMapOptionsSink sink) {}

  static void interpretCircleOptions(
      Map<String, dynamic> options, MapboxMapOptionsSink sink) {}

  static void interpretLineOptions(
      Map<String, dynamic> options, MapboxMapOptionsSink sink) {}
}
