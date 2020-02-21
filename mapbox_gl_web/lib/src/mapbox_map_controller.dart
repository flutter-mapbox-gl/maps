part of mapbox_gl_web;

class MapboxMapController extends MapboxGlPlatform
    implements MapboxMapOptionsSink {
  final List<DivElement> _mapElements = [];
  final List<Function> _callbacks = [];

  Map<String, dynamic> _creationParams;
  MapboxMap _map;

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
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    // TODO: implement method
    print('TODO: updateMyLocationTrackingMode $myLocationTrackingMode');
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() async {
    // TODO: implement method
    print('TODO: matchMapLanguageWithDeviceDefault');
  }

  @override
  Future<void> setMapLanguage(String language) async {
    // TODO: implement method
    print('TODO: setMapLanguage $language');
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
    // TODO: implement method
    print('TODO: addSymbol $options $data');
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    // TODO: implement method
    print('TODO: updateSymbol $symbol $changes');
  }

  @override
  Future<void> removeSymbol(String symbolId) async {
    // TODO: implement method
    print('TODO: removeSymbol $symbolId');
  }

  @override
  Future<Line> addLine(LineOptions options, [Map data]) async {
    // TODO: implement method
    print('TODO: addLine $options $data');
  }

  @override
  Future<void> updateLine(Line line, LineOptions changes) async {
    // TODO: implement method
    print('TODO: updateLine $line $changes');
  }

  @override
  Future<void> removeLine(String lineId) async {
    // TODO: implement method
    print('TODO: removeLine $lineId');
  }

  @override
  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    // TODO: implement method
    print('TODO: addCircle $options $data');
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    // TODO: implement method
    print('TODO: updateCircle $circle $changes');
  }

  @override
  Future<LatLng> getCircleLatLng(Circle circle) async {
    // TODO: implement method
    print('TODO: getCircleLatLng $circle');
  }

  @override
  Future<void> removeCircle(String circleId) async {
    // TODO: implement method
    print('TODO: removeCircle $circleId');
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
