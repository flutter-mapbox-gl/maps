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
      //Should not be invoked before sink.setMyLocationEnabled()
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
      final position =
          CompassViewPosition.values[options['compassViewPosition']];
      sink.setCompassAlignment(position);
    }
    if (options.containsKey('compassViewMargins')) {
      sink.setCompassViewMargins(
          options['compassViewMargins'][0], options['compassViewMargins'][1]);
    }
    if (options.containsKey('attributionButtonPosition')) {
      final position = AttributionButtonPosition
          .values[options['attributionButtonPosition']];
      sink.setAttributionButtonAlignment(position);
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
        final left = json[2];
        final top = json[3];
        final right = json[4];
        final bottom = json[5];
        final camera = mapboxMap.cameraForBounds(
            LngLatBounds(
              LngLat(bounds[0][1], bounds[0][0]),
              LngLat(bounds[1][1], bounds[1][0]),
            ),
            {
              'padding': {
                'top': top,
                'bottom': bottom,
                'left': left,
                'right': right,
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

  static Feature interpretSymbolOptions(
      SymbolOptions options, Feature feature) {
    var properties = feature.properties;
    var geometry = feature.geometry;
    if (options.iconSize != null) {
      properties['iconSize'] = options.iconSize;
    }
    if (options.iconImage != null) {
      properties['iconImage'] = options.iconImage;
    }
    if (options.iconRotate != null) {
      properties['iconRotate'] = options.iconRotate;
    }
    if (options.iconOffset != null) {
      properties['iconOffset'] = [
        options.iconOffset!.dx,
        options.iconOffset!.dy
      ];
    }
    if (options.iconAnchor != null) {
      properties['iconAnchor'] = options.iconAnchor;
    }
    if (options.textField != null) {
      properties['textField'] = options.textField;
    }
    if (options.textSize != null) {
      properties['textSize'] = options.textSize;
    }
    if (options.textMaxWidth != null) {
      properties['textMaxWidth'] = options.textMaxWidth;
    }
    if (options.textLetterSpacing != null) {
      properties['textLetterSpacing'] = options.textLetterSpacing;
    }
    if (options.textJustify != null) {
      properties['textJustify'] = options.textJustify;
    }
    if (options.textAnchor != null) {
      properties['textAnchor'] = options.textAnchor;
    }
    if (options.textRotate != null) {
      properties['textRotate'] = options.textRotate;
    }
    if (options.textTransform != null) {
      properties['textTransform'] = options.textTransform;
    }
    if (options.textOffset != null) {
      properties['textOffset'] = [
        options.textOffset!.dx,
        options.textOffset!.dy
      ];
    }
    if (options.iconOpacity != null) {
      properties['iconOpacity'] = options.iconOpacity;
    }
    if (options.iconColor != null) {
      properties['iconColor'] = options.iconColor;
    }
    if (options.iconHaloColor != null) {
      properties['iconHaloColor'] = options.iconHaloColor;
    }
    if (options.iconHaloWidth != null) {
      properties['iconHaloWidth'] = options.iconHaloWidth;
    }
    if (options.iconHaloBlur != null) {
      properties['iconHaloBlur'] = options.iconHaloBlur;
    }
    if (options.textOpacity != null) {
      properties['textOpacity'] = options.textOpacity;
    }
    if (options.textColor != null) {
      properties['textColor'] = options.textColor;
    }
    if (options.textHaloColor != null) {
      properties['textHaloColor'] = options.textHaloColor;
    }
    if (options.textHaloWidth != null) {
      properties['textHaloWidth'] = options.textHaloWidth;
    }
    if (options.textHaloBlur != null) {
      properties['textHaloBlur'] = options.textHaloBlur;
    }
    if (options.geometry != null) {
      geometry = Geometry(
        type: geometry.type,
        coordinates: [options.geometry!.longitude, options.geometry!.latitude],
      );
    }
    if (options.zIndex != null) {
      properties['symbolSortKey'] = options.zIndex;
    }
    if (options.draggable != null) {
      properties['draggable'] = options.draggable;
    }
    return feature.copyWith(properties: properties, geometry: geometry);
  }

  static Feature interpretLineOptions(LineOptions options, Feature feature) {
    var properties = feature.properties;
    var geometry = feature.geometry;
    if (options.lineJoin != null) {
      properties['lineJoin'] = options.lineJoin;
    }
    if (options.lineOpacity != null) {
      properties['lineOpacity'] = options.lineOpacity;
    }
    if (options.lineColor != null) {
      properties['lineColor'] = options.lineColor;
    }
    if (options.lineWidth != null) {
      properties['lineWidth'] = options.lineWidth;
    }
    if (options.lineGapWidth != null) {
      properties['lineGapWidth'] = options.lineGapWidth;
    }
    if (options.lineOffset != null) {
      properties['lineOffset'] = options.lineOffset;
    }
    if (options.lineBlur != null) {
      properties['lineBlur'] = options.lineBlur;
    }
    if (options.linePattern != null) {
      properties['linePattern'] = options.linePattern;
    }
    if (options.geometry != null) {
      geometry = Geometry(
        type: geometry.type,
        coordinates: options.geometry!
            .map((latLng) => [latLng.longitude, latLng.latitude])
            .toList(),
      );
    }
    if (options.draggable != null) {
      properties['draggable'] = options.draggable;
    }
    return feature.copyWith(properties: properties, geometry: geometry);
  }

  static Feature interpretCircleOptions(
      CircleOptions options, Feature feature) {
    var properties = feature.properties;
    var geometry = feature.geometry;
    if (options.circleRadius != null) {
      properties['circleRadius'] = options.circleRadius;
    }
    if (options.circleColor != null) {
      properties['circleColor'] = options.circleColor;
    }
    if (options.circleBlur != null) {
      properties['circleBlur'] = options.circleBlur;
    }
    if (options.circleOpacity != null) {
      properties['circleOpacity'] = options.circleOpacity;
    }
    if (options.circleStrokeWidth != null) {
      properties['circleStrokeWidth'] = options.circleStrokeWidth;
    }
    if (options.circleStrokeColor != null) {
      properties['circleStrokeColor'] = options.circleStrokeColor;
    }
    if (options.circleStrokeOpacity != null) {
      properties['circleStrokeOpacity'] = options.circleStrokeOpacity;
    }
    if (options.geometry != null) {
      geometry = Geometry(
        type: geometry.type,
        coordinates: [options.geometry!.longitude, options.geometry!.latitude],
      );
    }
    if (options.draggable != null) {
      properties['draggable'] = options.draggable;
    }
    return feature.copyWith(properties: properties, geometry: geometry);
  }

  static List<List<List<double>>> fillGeometryToFeatureGeometry(
      List<List<LatLng>> geom) {
    List<List<List<double>>> convertedFill = [];
    for (final ring in geom) {
      List<List<double>> convertedRing = [];
      for (final coords in ring) {
        convertedRing.add([coords.longitude, coords.latitude]);
      }
      convertedFill.add(convertedRing);
    }
    return convertedFill;
  }

  static List<List<LatLng>> featureGeometryToFillGeometry(
      List<List<List<double>>> geom) {
    List<List<LatLng>> convertedFill = [];
    for (final ring in geom) {
      List<LatLng> convertedRing = [];
      for (final coords in ring) {
        convertedRing.add(LatLng(coords[1], coords[0]));
      }
      convertedFill.add(convertedRing);
    }
    return convertedFill;
  }

  static Feature intepretFillOptions(FillOptions options, Feature feature) {
    var properties = feature.properties;
    var geometry = feature.geometry;
    if (options.draggable != null) {
      properties['draggable'] = options.draggable;
    }
    if (options.fillColor != null) {
      properties['fillColor'] = options.fillColor;
    }
    if (options.fillOpacity != null) {
      properties['fillOpacity'] = options.fillOpacity;
    }
    if (options.fillOutlineColor != null) {
      properties['fillOutlineColor'] = options.fillOutlineColor;
    }
    if (options.fillPattern != null) {
      properties['fillPattern'] = options.fillPattern;
    }

    if (options.geometry != null) {
      geometry = Geometry(
        type: geometry.type,
        coordinates: fillGeometryToFeatureGeometry(options.geometry!),
      );
    }
    return feature.copyWith(properties: properties, geometry: geometry);
  }
}
