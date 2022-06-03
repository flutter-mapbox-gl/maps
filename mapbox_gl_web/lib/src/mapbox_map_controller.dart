part of mapbox_gl_web;

const _mapboxGlCssUrl =
    'https://api.mapbox.com/mapbox-gl-js/v2.6.1/mapbox-gl.css';

class MapboxMapController extends MapboxGlPlatform
    implements MapboxMapOptionsSink {
  late DivElement _mapElement;

  late Map<String, dynamic> _creationParams;
  late MapboxMap _map;
  bool _mapReady = false;

  List<String> annotationOrder = [];
  final _featureLayerIdentifiers = Set<String>();
  late SymbolManager symbolManager;
  late LineManager lineManager;
  late CircleManager circleManager;
  late FillManager fillManager;

  bool _trackCameraPosition = false;
  GeolocateControl? _geolocateControl;
  LatLng? _myLastLocation;

  String? _navigationControlPosition;
  NavigationControl? _navigationControl;

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers) {
    _creationParams = creationParams;
    _registerViewFactory(onPlatformViewCreated, this.hashCode);
    return HtmlElementView(
        viewType: 'plugins.flutter.io/mapbox_gl_${this.hashCode}');
  }

  void _registerViewFactory(Function(int) callback, int identifier) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        'plugins.flutter.io/mapbox_gl_$identifier', (int viewId) {
      _mapElement = DivElement()
        ..style.width = '100%'
        ..style.height = '100%';
      callback(viewId);
      return _mapElement;
    });
  }

  @override
  Future<void> initPlatform(int id) async {
    await _addStylesheetToShadowRoot(_mapElement);
    if (_creationParams.containsKey('initialCameraPosition')) {
      var camera = _creationParams['initialCameraPosition'];
      if (_creationParams.containsKey('accessToken')) {
        Mapbox.accessToken = _creationParams['accessToken'];
      }
      _map = MapboxMap(
        MapOptions(
          container: _mapElement,
          style: 'mapbox://styles/mapbox/streets-v11',
          center: LngLat(camera['target'][1], camera['target'][0]),
          zoom: camera['zoom'],
          bearing: camera['bearing'],
          pitch: camera['tilt'],
        ),
      );
      _map.on('load', _onStyleLoaded);
      _map.on('click', _onMapClick);
      // long click not available in web, so it is mapped to double click
      _map.on('dblclick', _onMapLongClick);
      _map.on('movestart', _onCameraMoveStarted);
      _map.on('move', _onCameraMove);
      _map.on('moveend', _onCameraIdle);
      _map.on('resize', _onMapResize);
    }
    Convert.interpretMapboxMapOptions(_creationParams['options'], this);

    if (_creationParams.containsKey('annotationOrder')) {
      annotationOrder = _creationParams['annotationOrder'];
    }
  }

  Future<void> _addStylesheetToShadowRoot(HtmlElement e) async {
    LinkElement link = LinkElement()
      ..href = _mapboxGlCssUrl
      ..rel = 'stylesheet';
    e.append(link);

    await link.onLoad.first;
  }

  CameraPosition _getCurrentCameraPosition() {
    final center = _map.getCenter();
    var camera = CameraPosition(
      bearing: _map.getBearing().toDouble(),
      target: LatLng(center.lat.toDouble(), center.lng.toDouble()),
      tilt: _map.getPitch().toDouble(),
      zoom: _map.getZoom().toDouble(),
    );

    return camera;
  }

  @override
  Future<CameraPosition?> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    // FIX: why is called indefinitely? (map_ui page)
    Convert.interpretMapboxMapOptions(optionsUpdate, this);
    return _getCameraPosition();
  }

  @override
  Future<bool?> animateCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    _map.flyTo(cameraOptions);
    return true;
  }

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    _map.jumpTo(cameraOptions);
    return true;
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    setMyLocationTrackingMode(myLocationTrackingMode.index);
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() async {
    setMapLanguage(ui.window.locale.languageCode);
  }

  @override
  Future<void> setMapLanguage(String language) async {
    _map.setLayoutProperty(
      'country-label',
      'text-field',
      ['get', 'name_' + language],
    );
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) async {
    print('Telemetry not available in web');
    return;
  }

  @override
  Future<bool> getTelemetryEnabled() async {
    print('Telemetry not available in web');
    return false;
  }

  @override
  Future<List<Symbol>> addSymbols(List<SymbolOptions> options,
      [List<Map>? data]) async {
    Map<String, SymbolOptions> optionsById = {
      for (final o in options)
        symbolManager.add(Feature(
          geometry: Geometry(
            type: 'Point',
            coordinates: [o.geometry!.longitude, o.geometry!.latitude],
          ),
        )): o,
    };
    symbolManager.updateAll(optionsById);

    return optionsById
        .map((id, singleOptions) {
          int dataIndex = options.indexOf(singleOptions);
          Map? singleData = data != null && data.length >= dataIndex + 1
              ? data[dataIndex]
              : null;
          return MapEntry(id, Symbol(id, singleOptions, singleData));
        })
        .values
        .toList();
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    symbolManager.update(symbol.id, changes);
  }

  @override
  Future<LatLng> getSymbolLatLng(Symbol symbol) async {
    var coordinates = symbolManager.getFeature(symbol.id)!.geometry.coordinates;
    return LatLng(coordinates[1], coordinates[0]);
  }

  @override
  Future<void> removeSymbols(Iterable<String> symbolsIds) async {
    symbolManager.removeAll(symbolsIds);
  }

  @override
  Future<Line> addLine(LineOptions options, [Map? data]) async {
    String lineId = lineManager.add(Feature(
      geometry: Geometry(
        type: 'LineString',
        coordinates: options.geometry!
            .map((latLng) => [latLng.longitude, latLng.latitude])
            .toList(),
      ),
    ));
    lineManager.update(lineId, options);
    return Line(lineId, options, data);
  }

  @override
  Future<void> updateLine(Line line, LineOptions changes) async {
    lineManager.update(line.id, changes);
  }

  @override
  Future<List<LatLng>> getLineLatLngs(Line line) async {
    List<dynamic> coordinates =
        lineManager.getFeature(line.id)!.geometry.coordinates;
    return coordinates.map((c) => LatLng(c[1], c[0])).toList();
  }

  @override
  Future<void> removeLine(String lineId) async {
    lineManager.remove(lineId);
  }

  @override
  Future<void> removeLines(Iterable<String> ids) async {
    lineManager.removeAll(ids);
  }

  @override
  Future<Circle> addCircle(CircleOptions options, [Map? data]) async {
    String circleId = circleManager.add(Feature(
      geometry: Geometry(
        type: 'Point',
        coordinates: [options.geometry!.longitude, options.geometry!.latitude],
      ),
    ));
    circleManager.update(circleId, options);
    return Circle(circleId, options, data);
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    circleManager.update(circle.id, changes);
  }

  @override
  Future<LatLng> getCircleLatLng(Circle circle) async {
    var coordinates = circleManager.getFeature(circle.id)!.geometry.coordinates;
    return LatLng(coordinates[1], coordinates[0]);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    circleManager.remove(circleId);
  }

  @override
  Future<void> removeCircles(Iterable<String> ids) async {
    circleManager.removeAll(ids);
  }

  Future<Fill> addFill(FillOptions options, [Map? data]) async {
    String fillId = fillManager.add(Feature(
      geometry: Geometry(
        type: 'Polygon',
        coordinates: Convert.fillGeometryToFeatureGeometry(options.geometry!),
      ),
    ));

    fillManager.update(fillId, options);
    return Fill(fillId, options, data);
  }

  Future<void> updateFill(Fill fill, FillOptions changes) async {
    fillManager.update(fill.id, changes);
  }

  Future<void> removeFill(String fillId) async {
    fillManager.remove(fillId);
  }

  @override
  Future<void> removeFills(Iterable<String> ids) async {
    fillManager.removeAll(ids);
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    Map<String, dynamic> options = {};
    if (layerIds.length > 0) {
      options['layers'] = layerIds;
    }
    if (filter != null) {
      options['filter'] = filter;
    }

    // avoid issues with the js point type
    final pointAsList = [point.x, point.y];
    return _map
        .queryRenderedFeatures([pointAsList, pointAsList], options)
        .map((feature) => {
              'type': 'Feature',
              'id': feature.id,
              'geometry': {
                'type': feature.geometry.type,
                'coordinates': feature.geometry.coordinates,
              },
              'properties': feature.properties,
              'source': feature.source,
            })
        .toList();
  }

  @override
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    Map<String, dynamic> options = {};
    if (layerIds.length > 0) {
      options['layers'] = layerIds;
    }
    if (filter != null) {
      options['filter'] = filter;
    }
    return _map
        .queryRenderedFeatures([
          [rect.left, rect.bottom],
          [rect.right, rect.top],
        ], options)
        .map((feature) => {
              'type': 'Feature',
              'id': feature.id as int?,
              'geometry': {
                'type': feature.geometry.type,
                'coordinates': feature.geometry.coordinates,
              },
              'properties': feature.properties,
              'source': feature.source,
            })
        .toList();
  }

  @override
  Future invalidateAmbientCache() async {
    print('Offline storage not available in web');
  }

  @override
  Future<LatLng?> requestMyLocationLatLng() async {
    return _myLastLocation;
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async {
    final bounds = _map.getBounds();
    return LatLngBounds(
      southwest: LatLng(
        bounds.getSouthWest().lat as double,
        bounds.getSouthWest().lng as double,
      ),
      northeast: LatLng(
        bounds.getNorthEast().lat as double,
        bounds.getNorthEast().lng as double,
      ),
    );
  }

  @override
  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    final photo = decodeImage(bytes)!;
    if (!_map.hasImage(name)) {
      _map.addImage(
        name,
        {
          'width': photo.width,
          'height': photo.height,
          'data': photo.getBytes(),
        },
        {'sdf': sdf},
      );
    }
  }

  @override
  Future<void> removeSource(String sourceId) async {
    _map.removeSource(sourceId);
  }

  @override
  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    //TODO: to implement
    print('setSymbolIconAllowOverlap not implemented yet');
  }

  @override
  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    //TODO: to implement
    print('setSymbolIconIgnorePlacement not implemented yet');
  }

  @override
  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    //TODO: to implement
    print('setSymbolTextAllowOverlap not implemented yet');
  }

  @override
  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    //TODO: to implement
    print('setSymbolTextIgnorePlacement not implemented yet');
  }

  CameraPosition? _getCameraPosition() {
    if (_trackCameraPosition) {
      final center = _map.getCenter();
      return CameraPosition(
        bearing: _map.getBearing() as double,
        target: LatLng(center.lat as double, center.lng as double),
        tilt: _map.getPitch() as double,
        zoom: _map.getZoom() as double,
      );
    }
    return null;
  }

  void _onStyleLoaded(_) {
    _mapReady = true;
    for (final annotationType in annotationOrder) {
      switch (annotationType) {
        case 'AnnotationType.symbol':
          symbolManager =
              SymbolManager(map: _map, onTap: onSymbolTappedPlatform);
          break;
        case 'AnnotationType.line':
          lineManager = LineManager(map: _map, onTap: onLineTappedPlatform);
          break;
        case 'AnnotationType.circle':
          circleManager =
              CircleManager(map: _map, onTap: onCircleTappedPlatform);
          break;
        case 'AnnotationType.fill':
          fillManager = FillManager(map: _map, onTap: onFillTappedPlatform);
          break;
        default:
          print(
              "Unknown annotation type: \(annotationType), must be either 'fill', 'line', 'circle' or 'symbol'");
      }
    }
    onMapStyleLoadedPlatform(null);
    _map.on('click', _onMapClick);
    // long click not available in web, so it is mapped to double click
    _map.on('dblclick', _onMapLongClick);
    _map.on('movestart', _onCameraMoveStarted);
    _map.on('move', _onCameraMove);
    _map.on('moveend', _onCameraIdle);
    _map.on('scale', _onScale);
    _map.on('rotate', _onRotate);
    _map.on('fling', _onFling);
    _map.on('rotatebegin', _onRotateBegin);
    _map.on('rotateend', _onRotateEnd);
    _map.on('scalebegin', _onScaleBegin);
    _map.on('scaleend', _onScaleEnd);
    _map.on('shove', _onShove);
    _map.on('shovebegin', _onShoveBegin);
    _map.on('shoveend', _onShoveEnd);
    _map.on('resize', _onMapResize);
    _map.on('mapmove', _onMapMove);
    _map.on('mapmovebegin', _onMapMoveBegin);
    _map.on('mapmoveend', _onMapMoveEnd);
  }

  void _onMapResize(Event e) {
    Timer(Duration(microseconds: 10), () {
      var container = _map.getContainer();
      var canvas = _map.getCanvas();
      var widthMismatch = canvas.clientWidth != container.clientWidth;
      var heightMismatch = canvas.clientHeight != container.clientHeight;
      if (widthMismatch || heightMismatch) {
        _map.resize();
      }
    });
  }

  void _onMapClick(Event e) {
    final features = _map.queryRenderedFeatures(
        [e.point.x, e.point.y], {"layers": _featureLayerIdentifiers.toList()});
    final payload = {
      'point': Point<double>(e.point.x.toDouble(), e.point.y.toDouble()),
      'latLng': LatLng(e.lngLat.lat.toDouble(), e.lngLat.lng.toDouble()),
      if (features.isNotEmpty) "id": features.first.id,
    };
    if (features.isNotEmpty) {
      onFeatureTappedPlatform(payload);
    } else {
      onMapClickPlatform(payload);
    }
  }

  void _onMapLongClick(e) {
    onMapLongClickPlatform({
      'point': Point<double>(e.point.x, e.point.y),
      'latLng': LatLng(e.lngLat.lat, e.lngLat.lng),
    });
  }

  void _onCameraMoveStarted(_) {
    onCameraMoveStartedPlatform(null);
  }

  void _onCameraMove(_) {
    final center = _map.getCenter();
    var camera = CameraPosition(
      bearing: _map.getBearing() as double,
      target: LatLng(center.lat as double, center.lng as double),
      tilt: _map.getPitch() as double,
      zoom: _map.getZoom() as double,
    );
    onCameraMovePlatform(camera);
  }

  void _onCameraIdle(_) {
    final center = _map.getCenter();
    var camera = CameraPosition(
      bearing: _map.getBearing() as double,
      target: LatLng(center.lat as double, center.lng as double),
      tilt: _map.getPitch() as double,
      zoom: _map.getZoom() as double,
    );
    onCameraIdlePlatform(camera);
  }

  void _onRotateBegin() {
    onRotateBeginPlatform(_getCurrentCameraPosition());
  }

  void _onRotate() {
    onRotatePlatform(_getCurrentCameraPosition());
  }

  void _onRotateEnd() {
    onRotateEndPlatform(_getCurrentCameraPosition());
  }

  void _onScaleBegin() {
    onScaleBeginPlatform(_getCurrentCameraPosition());
  }

  void _onScale() {
    onScalePlatform(_getCurrentCameraPosition());
  }

  void _onScaleEnd() {
    onScaleEndPlatform(_getCurrentCameraPosition());
  }

  void _onShoveBegin() {
    onShoveBeginPlatform(_getCurrentCameraPosition());
  }

  void _onShove() {
    onShovePlatform(_getCurrentCameraPosition());
  }

  void _onShoveEnd() {
    onShoveEndPlatform(_getCurrentCameraPosition());
  }

  void _onMapMoveBegin() {
    onMapMoveBeginPlatform(_getCurrentCameraPosition());
  }

  void _onMapMove() {
    onMapMovePlatform(_getCurrentCameraPosition());
  }

  void _onMapMoveEnd() {
    onMapMoveEndPlatform(_getCurrentCameraPosition());
  }

  void _onFling() {
    onFlingPlatform(_getCurrentCameraPosition());
  }

  void _onCameraTrackingChanged(bool isTracking) {
    if (isTracking) {
      onCameraTrackingChangedPlatform(MyLocationTrackingMode.Tracking);
    } else {
      onCameraTrackingChangedPlatform(MyLocationTrackingMode.None);
    }
  }

  void _onCameraTrackingDismissed() {
    onCameraTrackingDismissedPlatform(null);
  }

  void _addGeolocateControl({bool trackUserLocation = false}) {
    _removeGeolocateControl();
    _geolocateControl = GeolocateControl(
      GeolocateControlOptions(
        positionOptions: PositionOptions(enableHighAccuracy: true),
        trackUserLocation: trackUserLocation,
        showAccuracyCircle: true,
        showUserLocation: true,
      ),
    );
    _geolocateControl!.on('geolocate', (e) {
      _myLastLocation = LatLng(e.coords.latitude, e.coords.longitude);
      onUserLocationUpdatedPlatform(UserLocation(
          position: LatLng(e.coords.latitude, e.coords.longitude),
          altitude: e.coords.altitude,
          bearing: e.coords.heading,
          speed: e.coords.speed,
          horizontalAccuracy: e.coords.accuracy,
          verticalAccuracy: e.coords.altitudeAccuracy,
          heading: null,
          timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp)));
    });
    _geolocateControl!.on('trackuserlocationstart', (_) {
      _onCameraTrackingChanged(true);
    });
    _geolocateControl!.on('trackuserlocationend', (_) {
      _onCameraTrackingChanged(false);
      _onCameraTrackingDismissed();
    });
    _map.addControl(_geolocateControl, 'bottom-right');
  }

  void _removeGeolocateControl() {
    if (_geolocateControl != null) {
      _map.removeControl(_geolocateControl);
      _geolocateControl = null;
    }
  }

  void _updateNavigationControl({
    bool? compassEnabled,
    CompassViewPosition? position,
  }) {
    bool? prevShowCompass;
    if (_navigationControl != null) {
      prevShowCompass = _navigationControl!.options.showCompass;
    }
    String? prevPosition = _navigationControlPosition;

    String? positionString;
    switch (position) {
      case CompassViewPosition.TopRight:
        positionString = 'top-right';
        break;
      case CompassViewPosition.TopLeft:
        positionString = 'top-left';
        break;
      case CompassViewPosition.BottomRight:
        positionString = 'bottom-right';
        break;
      case CompassViewPosition.BottomLeft:
        positionString = 'bottom-left';
        break;
      default:
        positionString = null;
    }

    bool newShowComapss = compassEnabled ?? prevShowCompass ?? false;
    String? newPosition = positionString ?? prevPosition ?? null;

    _removeNavigationControl();
    _navigationControl = NavigationControl(NavigationControlOptions(
      showCompass: newShowComapss,
      showZoom: false,
      visualizePitch: false,
    ));

    if (newPosition == null) {
      _map.addControl(_navigationControl);
    } else {
      _map.addControl(_navigationControl, newPosition);
      _navigationControlPosition = newPosition;
    }
  }

  void _removeNavigationControl() {
    if (_navigationControl != null) {
      _map.removeControl(_navigationControl);
      _navigationControl = null;
    }
  }

  /*
   *  MapboxMapOptionsSink
   */
  @override
  void setAttributionButtonMargins(int x, int y) {
    print('setAttributionButtonMargins not available in web');
  }

  @override
  void setCameraTargetBounds(LatLngBounds? bounds) {
    if (bounds == null) {
      _map.setMaxBounds(null);
    } else {
      _map.setMaxBounds(
        LngLatBounds(
          LngLat(
            bounds.southwest.longitude,
            bounds.southwest.latitude,
          ),
          LngLat(
            bounds.northeast.longitude,
            bounds.northeast.latitude,
          ),
        ),
      );
    }
  }

  @override
  void setCompassEnabled(bool compassEnabled) {
    _updateNavigationControl(compassEnabled: compassEnabled);
  }

  @override
  void setCompassAlignment(CompassViewPosition position) {
    _updateNavigationControl(position: position);
  }

  @override
  void setAttributionButtonAlignment(AttributionButtonPosition position) {
    print('setAttributionButtonAlignment not available in web');
  }

  @override
  void setCompassViewMargins(int x, int y) {
    print('setCompassViewMargins not available in web');
  }

  @override
  void setLogoViewMargins(int x, int y) {
    print('setLogoViewMargins not available in web');
  }

  @override
  void setMinMaxZoomPreference(num? min, num? max) {
    // FIX: why is called indefinitely? (map_ui page)
    _map.setMinZoom(min);
    _map.setMaxZoom(max);
  }

  @override
  void setMyLocationEnabled(bool myLocationEnabled) {
    if (myLocationEnabled) {
      _addGeolocateControl(trackUserLocation: false);
    } else {
      _removeGeolocateControl();
    }
  }

  @override
  void setMyLocationRenderMode(int myLocationRenderMode) {
    print('myLocationRenderMode not available in web');
  }

  @override
  void setMyLocationTrackingMode(int myLocationTrackingMode) {
    if (_geolocateControl == null) {
      //myLocationEnabled is false, ignore myLocationTrackingMode
      return;
    }
    if (myLocationTrackingMode == 0) {
      _addGeolocateControl(trackUserLocation: false);
    } else {
      print('Only one tracking mode available in web');
      _addGeolocateControl(trackUserLocation: true);
    }
  }

  void _onMouseEnterFeature(_) {
    _map.getCanvas().style.cursor = 'pointer';
  }

  void _onMouseLeaveFeature(_) {
    _map.getCanvas().style.cursor = '';
  }

  // @override
  // Future<void> setStyleString(String? styleString) async {
  //   //remove old mouseenter callbacks to avoid multicalling
  //   for (var layerId in _featureLayerIdentifiers) {
  //     _map.off('mouseenter', layerId, _onMouseEnterFeature);
  //     _map.off('mousemouve', layerId, _onMouseEnterFeature);
  //     _map.off('mouseleave', layerId, _onMouseLeaveFeature);
  //   }
  //   _featureLayerIdentifiers.clear();
  // }

  @override
  void setScrollGesturesEnabled(bool scrollGesturesEnabled) {
    if (scrollGesturesEnabled) {
      _map.dragPan.enable();
      _map.keyboard.enable();
    } else {
      _map.dragPan.disable();
      _map.keyboard.disable();
    }
  }

  @override
  Future<void> setStyleString(String? styleString) async {
    _map.setStyle(styleString);
    // catch style loaded for later style changes
    if (_mapReady) {
      _map.once("styledata", _onStyleLoaded);
    }
  }

  @override
  void setTrackCameraPosition(bool trackCameraPosition) {
    _trackCameraPosition = trackCameraPosition;
  }

  @override
  Future<Point> toScreenLocation(LatLng latLng) async {
    var screenPosition =
        _map.project(LngLat(latLng.longitude, latLng.latitude));
    return Point(screenPosition.x.round(), screenPosition.y.round());
  }

  @override
  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    return latLngs.map((latLng) {
      var screenPosition =
          _map.project(LngLat(latLng.longitude, latLng.latitude));
      return Point(screenPosition.x.round(), screenPosition.y.round());
    }).toList(growable: false);
  }

  @override
  Future<LatLng> toLatLng(Point screenLocation) async {
    var lngLat =
        _map.unproject(mapbox.Point(screenLocation.x, screenLocation.y));
    return LatLng(lngLat.lat as double, lngLat.lng as double);
  }

  @override
  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    //https://wiki.openstreetmap.org/wiki/Zoom_levels
    var circumference = 40075017.686;
    var zoom = _map.getZoom();
    return circumference * cos(latitude * (pi / 180)) / pow(2, zoom + 9);
  }

  @override
  Future<void> removeLayer(String layerId) async {
    _featureLayerIdentifiers.remove(layerId);
    _map.removeLayer(layerId);
  }

  @override
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId}) async {
    _map.addSource(sourceId, {
      "type": 'geojson',
      "data": geojson,
      if (promoteId != null) "promoteId": promoteId
    });
  }

  @override
  Future<void> setGeoJsonSource(
      String sourceId, Map<String, dynamic> geojson) async {
    final source = _map.getSource(sourceId) as GeoJsonSource;
    final data = FeatureCollection(features: [
      for (final f in geojson["features"] ?? [])
        Feature(
            geometry: Geometry(
                type: f["geometry"]["type"],
                coordinates: f["geometry"]["coordinates"]),
            properties: f["properties"],
            id: f["id"])
    ]);
    source.setData(data);
  }

  Future<void> _addLayer(String sourceId, String layerId,
      Map<String, dynamic> properties, String layerType,
      {String? belowLayerId, String? sourceLayer}) async {
    final layout = Map.fromEntries(
        properties.entries.where((entry) => isLayoutProperty(entry.key)));
    final paint = Map.fromEntries(
        properties.entries.where((entry) => !isLayoutProperty(entry.key)));

    _map.addLayer({
      'id': layerId,
      'type': layerType,
      'source': sourceId,
      'layout': layout,
      'paint': paint,
      if (sourceLayer != null) 'source-layer': sourceLayer
    }, belowLayerId);

    _featureLayerIdentifiers.add(layerId);
    if (layerType == "fill") {
      _map.on('mousemove', layerId, _onMouseEnterFeature);
    } else {
      _map.on('mouseenter', layerId, _onMouseEnterFeature);
    }
    _map.on('mouseleave', layerId, _onMouseLeaveFeature);
  }

  @override
  Future<void> addCircleLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    return _addLayer(sourceId, layerId, properties, "circle",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }

  @override
  Future<void> addFillLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    return _addLayer(sourceId, layerId, properties, "fill",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }

  @override
  Future<void> addLineLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    return _addLayer(sourceId, layerId, properties, "line",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }

  @override
  Future<void> addSymbolLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    return _addLayer(sourceId, layerId, properties, "symbol",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }

  @override
  Future<void> addHillshadeLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    return _addLayer(sourceId, layerId, properties, "hillshade",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }

  @override
  void setGestures(
      {required bool rotateGesturesEnabled,
      required bool scrollGesturesEnabled,
      required bool tiltGesturesEnabled,
      required bool zoomGesturesEnabled,
      required bool doubleClickZoomEnabled}) {
    if (rotateGesturesEnabled &&
        scrollGesturesEnabled &&
        tiltGesturesEnabled &&
        zoomGesturesEnabled) {
      _map.keyboard.enable();
    } else {
      _map.keyboard.disable();
    }

    if (scrollGesturesEnabled) {
      _map.dragPan.enable();
    } else {
      _map.dragPan.disable();
    }

    if (zoomGesturesEnabled) {
      _map.doubleClickZoom.enable();
      _map.boxZoom.enable();
      _map.scrollZoom.enable();
      _map.touchZoomRotate.enable();
    } else {
      _map.doubleClickZoom.disable();
      _map.boxZoom.disable();
      _map.scrollZoom.disable();
      _map.touchZoomRotate.disable();
    }

    if (doubleClickZoomEnabled) {
      _map.doubleClickZoom.enable();
    } else {
      _map.doubleClickZoom.disable();
    }

    if (rotateGesturesEnabled) {
      _map.touchZoomRotate.enableRotation();
    } else {
      _map.touchZoomRotate.disableRotation();
    }

    // dragRotate is shared by both gestures
    if (tiltGesturesEnabled && rotateGesturesEnabled) {
      _map.dragRotate.enable();
    } else {
      _map.dragRotate.disable();
    }
  }

  @override
  Future<void> addSource(String sourceId, SourceProperties source) async {
    _map.addSource(sourceId, source.toJson());
  }

  @override
  Future<void> addRasterLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    await _addLayer(sourceId, layerId, properties, "raster",
        belowLayerId: belowLayerId, sourceLayer: sourceLayer);
  }
}
