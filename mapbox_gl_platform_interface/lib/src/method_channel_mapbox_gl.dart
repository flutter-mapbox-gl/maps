part of mapbox_gl_platform_interface;

class MethodChannelMapboxGl extends MapboxGlPlatform {
  late MethodChannel _channel;
  static bool useHybridComposition = false;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'infoWindow#onTap':
        final String? symbolId = call.arguments['symbol'];
        if (symbolId != null) {
          onInfoWindowTappedPlatform(symbolId);
        }
        break;

      case 'feature#onTap':
        final id = call.arguments['id'];
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        onFeatureTappedPlatform({
          'id': id,
          'point': Point<double>(x, y),
          'latLng': LatLng(lat, lng)
        });
        break;
      case 'feature#onDrag':
        final id = call.arguments['id'];
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double originLat = call.arguments['originLat'];
        final double originLng = call.arguments['originLng'];

        final double currentLat = call.arguments['currentLat'];
        final double currentLng = call.arguments['currentLng'];

        final double deltaLat = call.arguments['deltaLat'];
        final double deltaLng = call.arguments['deltaLng'];

        onFeatureDraggedPlatform({
          'id': id,
          'point': Point<double>(x, y),
          'origin': LatLng(originLat, originLng),
          'current': LatLng(currentLat, currentLng),
          'delta': LatLng(deltaLat, deltaLng),
        });
        break;

      case 'camera#onMoveStarted':
        onCameraMoveStartedPlatform(null);
        break;
      case 'camera#onMove':
        final cameraPosition =
            CameraPosition.fromMap(call.arguments['position'])!;
        onCameraMovePlatform(cameraPosition);
        break;
      case 'camera#onIdle':
        final cameraPosition =
            CameraPosition.fromMap(call.arguments['position']);
        onCameraIdlePlatform(cameraPosition);
        break;
      case 'map#onStyleLoaded':
        onMapStyleLoadedPlatform(null);
        break;
      case 'map#onMapClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        onMapClickPlatform(
            {'point': Point<double>(x, y), 'latLng': LatLng(lat, lng)});
        break;
      case 'map#onMapLongClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        onMapLongClickPlatform(
            {'point': Point<double>(x, y), 'latLng': LatLng(lat, lng)});

        break;
      case 'map#onAttributionClick':
        onAttributionClickPlatform(null);
        break;
      case 'map#onCameraTrackingChanged':
        final int mode = call.arguments['mode'];
        onCameraTrackingChangedPlatform(MyLocationTrackingMode.values[mode]);
        break;
      case 'map#onCameraTrackingDismissed':
        onCameraTrackingDismissedPlatform(null);
        break;
      case 'map#onIdle':
        onMapIdlePlatform(null);
        break;
      case 'map#onUserLocationUpdated':
        final dynamic userLocation = call.arguments['userLocation'];
        final dynamic heading = call.arguments['heading'];
        onUserLocationUpdatedPlatform(UserLocation(
            position: LatLng(
              userLocation['position'][0],
              userLocation['position'][1],
            ),
            altitude: userLocation['altitude'],
            bearing: userLocation['bearing'],
            speed: userLocation['speed'],
            horizontalAccuracy: userLocation['horizontalAccuracy'],
            verticalAccuracy: userLocation['verticalAccuracy'],
            heading: heading == null
                ? null
                : UserHeading(
                    magneticHeading: heading['magneticHeading'],
                    trueHeading: heading['trueHeading'],
                    headingAccuracy: heading['headingAccuracy'],
                    x: heading['x'],
                    y: heading['y'],
                    z: heading['x'],
                    timestamp: DateTime.fromMillisecondsSinceEpoch(
                        heading['timestamp']),
                  ),
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                userLocation['timestamp'])));
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<void> initPlatform(int id) async {
    _channel = MethodChannel('plugins.flutter.io/mapbox_maps_$id');
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('map#waitForMap');
  }

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (useHybridComposition) {
        return PlatformViewLink(
          viewType: 'plugins.flutter.io/mapbox_gl',
          surfaceFactory: (
            BuildContext context,
            PlatformViewController controller,
          ) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: gestureRecognizers ??
                  const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            final SurfaceAndroidViewController controller =
                PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'plugins.flutter.io/mapbox_gl',
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );
            controller.addOnPlatformViewCreatedListener(
              onPlatformViewCreated,
            );

            controller.create();
            return controller;
          },
        );
      } else {
        return AndroidView(
          viewType: 'plugins.flutter.io/mapbox_gl',
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: gestureRecognizers,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/mapbox_gl',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  @override
  Future<CameraPosition?> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
    return CameraPosition.fromMap(json);
  }

  @override
  Future<bool?> animateCamera(cameraUpdate) async {
    return await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    return await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    await _channel
        .invokeMethod('map#updateMyLocationTrackingMode', <String, dynamic>{
      'mode': myLocationTrackingMode.index,
    });
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() async {
    await _channel.invokeMethod('map#matchMapLanguageWithDeviceDefault');
  }

  @override
  Future<void> updateContentInsets(EdgeInsets insets, bool animated) async {
    await _channel.invokeMethod('map#updateContentInsets', <String, dynamic>{
      'bounds': <String, double>{
        'top': insets.top,
        'left': insets.left,
        'bottom': insets.bottom,
        'right': insets.right,
      },
      'animated': animated,
    });
  }

  @override
  Future<void> setMapLanguage(String language) async {
    await _channel.invokeMethod('map#setMapLanguage', <String, dynamic>{
      'language': language,
    });
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) async {
    await _channel.invokeMethod('map#setTelemetryEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  @override
  Future<bool> getTelemetryEnabled() async {
    return await _channel.invokeMethod('map#getTelemetryEnabled');
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    try {
      final Map<dynamic, dynamic> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object?>{
          'x': point.x,
          'y': point.y,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'].map((feature) => jsonDecode(feature)).toList();
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    try {
      final Map<dynamic, dynamic> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object?>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'].map((feature) => jsonDecode(feature)).toList();
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future invalidateAmbientCache() async {
    try {
      await _channel.invokeMethod('map#invalidateAmbientCache');
      return null;
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<LatLng> requestMyLocationLatLng() async {
    try {
      final Map<dynamic, dynamic> reply = await _channel.invokeMethod(
          'locationComponent#getLastLocation', null);
      double latitude = 0.0, longitude = 0.0;
      if (reply.containsKey('latitude') && reply['latitude'] != null) {
        latitude = double.parse(reply['latitude'].toString());
      }
      if (reply.containsKey('longitude') && reply['longitude'] != null) {
        longitude = double.parse(reply['longitude'].toString());
      }
      return LatLng(latitude, longitude);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async {
    try {
      final Map<dynamic, dynamic> reply =
          await _channel.invokeMethod('map#getVisibleRegion', null);
      final southwest = reply['sw'] as List<dynamic>;
      final northeast = reply['ne'] as List<dynamic>;
      return LatLngBounds(
        southwest: LatLng(southwest[0], southwest[1]),
        northeast: LatLng(northeast[0], northeast[1]),
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    try {
      return await _channel.invokeMethod('style#addImage', <String, Object>{
        'name': name,
        'bytes': bytes,
        'length': bytes.length,
        'sdf': sdf
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) async {
    try {
      return await _channel
          .invokeMethod('style#addImageSource', <String, Object>{
        'imageSourceId': imageSourceId,
        'bytes': bytes,
        'length': bytes.length,
        'coordinates': coordinates.toList()
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<Point> toScreenLocation(LatLng latLng) async {
    try {
      var screenPosMap =
          await _channel.invokeMethod('map#toScreenLocation', <String, dynamic>{
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      });
      return Point(screenPosMap['x'], screenPosMap['y']);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    try {
      var coordinates = Float64List.fromList(latLngs
          .map((e) => [e.latitude, e.longitude])
          .expand((e) => e)
          .toList());
      Float64List result = await _channel.invokeMethod(
          'map#toScreenLocationBatch', {"coordinates": coordinates});

      var points = <Point>[];
      for (int i = 0; i < result.length; i += 2) {
        points.add(Point(result[i], result[i + 1]));
      }

      return points;
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> removeSource(String sourceId) async {
    try {
      return await _channel.invokeMethod(
        'style#removeSource',
        <String, Object>{'sourceId': sourceId},
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addLayer(String imageLayerId, String imageSourceId,
      double? minzoom, double? maxzoom) async {
    try {
      return await _channel.invokeMethod('style#addLayer', <String, dynamic>{
        'imageLayerId': imageLayerId,
        'imageSourceId': imageSourceId,
        'minzoom': minzoom,
        'maxzoom': maxzoom
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addLayerBelow(String imageLayerId, String imageSourceId,
      String belowLayerId, double? minzoom, double? maxzoom) async {
    try {
      return await _channel
          .invokeMethod('style#addLayerBelow', <String, dynamic>{
        'imageLayerId': imageLayerId,
        'imageSourceId': imageSourceId,
        'belowLayerId': belowLayerId,
        'minzoom': minzoom,
        'maxzoom': maxzoom
      });
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> removeLayer(String layerId) async {
    try {
      return await _channel.invokeMethod(
          'style#removeLayer', <String, Object>{'layerId': layerId});
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> setFilter(String layerId, dynamic filter) async {
    try {
      return await _channel.invokeMethod('style#setFilter',
          <String, Object>{'layerId': layerId, 'filter': jsonEncode(filter)});
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<LatLng> toLatLng(Point screenLocation) async {
    try {
      var latLngMap =
          await _channel.invokeMethod('map#toLatLng', <String, dynamic>{
        'x': screenLocation.x,
        'y': screenLocation.y,
      });
      return LatLng(latLngMap['latitude'], latLngMap['longitude']);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    try {
      var latLngMap = await _channel
          .invokeMethod('map#getMetersPerPixelAtLatitude', <String, dynamic>{
        'latitude': latitude,
      });
      return latLngMap['metersperpixel'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  @override
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId}) async {
    await _channel.invokeMethod('source#addGeoJson', <String, dynamic>{
      'sourceId': sourceId,
      'geojson': jsonEncode(geojson),
    });
  }

  @override
  Future<void> setGeoJsonSource(
      String sourceId, Map<String, dynamic> geojson) async {
    await _channel.invokeMethod('source#setGeoJson', <String, dynamic>{
      'sourceId': sourceId,
      'geojson': jsonEncode(geojson),
    });
  }

  @override
  Future<void> addSymbolLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      required bool enableInteraction}) async {
    await _channel.invokeMethod('symbolLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'sourceLayer': sourceLayer,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'enableInteraction': enableInteraction,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  @override
  Future<void> addLineLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      required bool enableInteraction}) async {
    await _channel.invokeMethod('lineLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'sourceLayer': sourceLayer,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'enableInteraction': enableInteraction,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  @override
  Future<void> addCircleLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      required bool enableInteraction}) async {
    await _channel.invokeMethod('circleLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'sourceLayer': sourceLayer,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'enableInteraction': enableInteraction,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  @override
  Future<void> addFillLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      required bool enableInteraction}) async {
    await _channel.invokeMethod('fillLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'sourceLayer': sourceLayer,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'enableInteraction': enableInteraction,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  @override
  void dispose() {
    super.dispose();
    _channel.setMethodCallHandler(null);
  }

  @override
  Future<void> addSource(String sourceId, SourceProperties properties) async {
    await _channel.invokeMethod('style#addSource', <String, dynamic>{
      'sourceId': sourceId,
      'properties': properties.toJson(),
    });
  }

  @override
  Future<void> addRasterLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) async {
    await _channel.invokeMethod('rasterLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  @override
  Future<void> addHillshadeLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) async {
    await _channel.invokeMethod('hillshadeLayer#add', <String, dynamic>{
      'sourceId': sourceId,
      'layerId': layerId,
      'belowLayerId': belowLayerId,
      'minzoom': minzoom,
      'maxzoom': maxzoom,
      'properties': properties
          .map((key, value) => MapEntry<String, String>(key, jsonEncode(value)))
    });
  }

  Future<void> setFeatureForGeoJsonSource(
      String sourceId, Map<String, dynamic> geojsonFeature) async {
    await _channel.invokeMethod('source#setFeature', <String, dynamic>{
      'sourceId': sourceId,
      'geojsonFeature': jsonEncode(geojsonFeature)
    });
  }
}
