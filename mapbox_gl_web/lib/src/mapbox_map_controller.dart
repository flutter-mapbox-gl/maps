part of mapbox_gl_web;

class MapboxMapController extends MapboxGlPlatform
    implements MapboxMapOptionsSink {
  final List<DivElement> _mapElements = [];
  final List<Function> _callbacks = [];

  Map<String, dynamic> _creationParams;
  MapboxMap _map;

  SymbolManager symbolManager;
  LineManager lineManager;
  CircleManager circleManager;

  bool _trackCameraPosition = false;

  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Function onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers) {
    _creationParams = creationParams;
    _callbacks.add(onPlatformViewCreated);
    _registerViewFactory();
    return HtmlElementView(viewType: 'plugins.flutter.io/mapbox_gl');
  }

  void _registerViewFactory() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('plugins.flutter.io/mapbox_gl',
        (int viewId) {
      _callbacks[viewId](viewId);
      final mapElement = DivElement();
      _mapElements.add(mapElement);
      return mapElement;
    });
  }

  @override
  Future<void> initPlatform(int id) async {
    await _addStylesheetToShadowRoot();
    if (_creationParams.containsKey('initialCameraPosition')) {
      var camera = _creationParams['initialCameraPosition'];
      _map = MapboxMap(
        MapOptions(
          container: _mapElements[id],
          style: 'mapbox://styles/mapbox/streets-v11',
          center: LngLat(camera['target'][1], camera['target'][0]),
          zoom: camera['zoom'],
          bearing: camera['bearing'],
          pitch: camera['tilt'],
        ),
      );
      _map.on('load', _onStyleLoaded);
    }
    Convert.interpretMapboxMapOptions(_creationParams['options'], this);
  }

  Future<void> _addStylesheetToShadowRoot() async {
    int index = -1;
    while (index == -1) {
      index = document.getElementsByTagName('flt-platform-view').length - 1;
      await Future.delayed(Duration(milliseconds: 10));
    }
    HtmlElement e = document.getElementsByTagName('flt-platform-view')[index]
        as HtmlElement;

    LinkElement link = LinkElement();
    link.href =
        'https://api.tiles.mapbox.com/mapbox-gl-js/v1.6.1/mapbox-gl.css';
    link.rel = 'stylesheet';
    e.shadowRoot.append(link);

    await link.onLoad.first;
  }

  @override
  Future<CameraPosition> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    // FIX: why is called indefinitely? (map_ui page)
    Convert.interpretMapboxMapOptions(optionsUpdate, this);
    return _getCameraPosition();
  }

  @override
  Future<bool> animateCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    if (cameraOptions != null) {
      _map.flyTo(cameraOptions);
    }
    return true;
  }

  @override
  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    final cameraOptions = Convert.toCameraOptions(cameraUpdate, _map);
    if (cameraOptions != null) {
      _map.jumpTo(cameraOptions);
    }
    return true;
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    // TODO: implement method
    print('TODO: updateMyLocationTrackingMode $myLocationTrackingMode');
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
  Future<Symbol> addSymbol(SymbolOptions options, [Map data]) async {
    String symbolId = symbolManager.add(Feature(
      geometry: Geometry(
        type: 'Point',
        coordinates: [options.geometry.longitude, options.geometry.latitude],
      ),
    ));
    symbolManager.update(symbolId, options);
    return Symbol(symbolId, options, data);
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    symbolManager.update(symbol.id, changes);
  }

  @override
  Future<void> removeSymbol(String symbolId) async {
    symbolManager.remove(symbolId);
  }

  @override
  Future<Line> addLine(LineOptions options, [Map data]) async {
    String lineId = lineManager.add(Feature(
      geometry: Geometry(
        type: 'LineString',
        coordinates: options.geometry
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
  Future<void> removeLine(String lineId) async {
    lineManager.remove(lineId);
  }

  @override
  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    String circleId = circleManager.add(Feature(
      geometry: Geometry(
        type: 'Point',
        coordinates: [options.geometry.longitude, options.geometry.latitude],
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
    var coordinates = circleManager.getFeature(circle.id).geometry.coordinates;
    return LatLng(coordinates[1], coordinates[0]);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    circleManager.remove(circleId);
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, String filter) async {
    // TODO: implement method
    print('TODO: queryRenderedFeatures $point $layerIds $filter');
  }

  @override
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    // TODO: implement method
    print('TODO: queryRenderedFeaturesInRect $rect $layerIds $filter');
  }

  @override
  Future invalidateAmbientCache() async {
    // TODO: implement method
    print('TODO: invalidateAmbientCache');
  }

  @override
  Future<LatLng> requestMyLocationLatLng() async {
    // TODO: implement method
    print('TODO: requestMyLocationLatLng');
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async {
    final bounds = _map.getBounds();
    return LatLngBounds(
      southwest: LatLng(bounds.getSouthWest().lat, bounds.getSouthWest().lng),
      northeast: LatLng(bounds.getNorthEast().lat, bounds.getNorthEast().lng),
    );
  }

  CameraPosition _getCameraPosition() {
    if (_trackCameraPosition) {
      final center = _map.getCenter();
      return CameraPosition(
        bearing: _map.getBearing(),
        target: LatLng(center.lat, center.lng),
        tilt: _map.getPitch(),
        zoom: _map.getZoom(),
      );
    }
    return null;
  }

  void _onStyleLoaded(_) {
    symbolManager = SymbolManager(map: _map, onTap: onSymbolTappedPlatform);
    lineManager = LineManager(map: _map, onTap: onLineTappedPlatform);
    circleManager = CircleManager(map: _map, onTap: onCircleTappedPlatform);
    onMapStyleLoadedPlatform(null);
  }

  /*
   *  MapboxMapOptionsSink
   */
  @override
  void setAttributionButtonMargins(int x, int y) {
    // TODO: AttributionControl not implemented
    // https://github.com/andrea689/mapbox-gl-dart/issues/2
  }

  @override
  void setCameraTargetBounds(LatLngBounds bounds) {
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
    // TODO: NavigationControl not implemented
    // https://github.com/andrea689/mapbox-gl-dart/issues/1
    print('TODO: setCompassEnabled $compassEnabled');
  }

  @override
  void setCompassGravity(int gravity) {
    // TODO: NavigationControl not implemented
    // https://github.com/andrea689/mapbox-gl-dart/issues/1
    print('TODO: setCompassGravity $gravity');
  }

  @override
  void setCompassViewMargins(int x, int y) {
    // TODO: NavigationControl not implemented
    // https://github.com/andrea689/mapbox-gl-dart/issues/1
    print('TODO: setCompassViewMargins $x $y');
  }

  @override
  void setLogoViewMargins(int x, int y) {
    // TODO: LogoControl not implemented
    // https://github.com/andrea689/mapbox-gl-dart/issues/3
    print('TODO: setLogoViewMargins $x $y');
  }

  @override
  void setMinMaxZoomPreference(num min, num max) {
    // FIX: why is called indefinitely? (map_ui page)
    _map.setMinZoom(min);
    _map.setMaxZoom(max);
  }

  @override
  void setMyLocationEnabled(bool myLocationEnabled) {
    // TODO: implement setMyLocationEnabled
    print('TODO: setMyLocationEnabled $myLocationEnabled');
  }

  @override
  void setMyLocationRenderMode(int myLocationRenderMode) {
    // TODO: implement setMyLocationRenderMode
    print('TODO: setMyLocationRenderMode $myLocationRenderMode');
  }

  @override
  void setMyLocationTrackingMode(int myLocationTrackingMode) {
    // TODO: implement setMyLocationTrackingMode
    print('TODO: setMyLocationTrackingMode $myLocationTrackingMode');
  }

  @override
  void setRotateGesturesEnabled(bool rotateGesturesEnabled) {
    if (rotateGesturesEnabled) {
      _map.dragRotate.enable();
      _map.touchZoomRotate.enableRotation();
      _map.keyboard.enable();
    } else {
      _map.dragRotate.disable();
      _map.touchZoomRotate.disableRotation();
      _map.keyboard.disable();
    }
  }

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
  void setStyleString(String styleString) {
    _map.setStyle(styleString);
  }

  @override
  void setTiltGesturesEnabled(bool tiltGesturesEnabled) {
    if (tiltGesturesEnabled) {
      _map.dragRotate.enable();
      _map.keyboard.enable();
    } else {
      _map.dragRotate.disable();
      _map.keyboard.disable();
    }
  }

  @override
  void setTrackCameraPosition(bool trackCameraPosition) {
    _trackCameraPosition = trackCameraPosition;
  }

  @override
  void setZoomGesturesEnabled(bool zoomGesturesEnabled) {
    if (zoomGesturesEnabled) {
      _map.doubleClickZoom.enable();
      _map.boxZoom.enable();
      _map.scrollZoom.enable();
      _map.touchZoomRotate.enable();
      _map.keyboard.enable();
    } else {
      _map.doubleClickZoom.disable();
      _map.boxZoom.disable();
      _map.scrollZoom.disable();
      _map.touchZoomRotate.disable();
      _map.keyboard.disable();
    }
  }
}
