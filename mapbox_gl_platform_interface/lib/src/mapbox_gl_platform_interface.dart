// ignore_for_file: unnecessary_getters_setters

part of mapbox_gl_platform_interface;

abstract class MapboxGlPlatform {
  /// The default instance of [MapboxGlPlatform] to use.
  ///
  /// Defaults to [MethodChannelMapboxGl].
  ///
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MapboxGlPlatform] when they register themselves.
  static MapboxGlPlatform Function() createInstance =
      () => MethodChannelMapboxGl();

  static Map<int, MapboxGlPlatform> _instances = {};

  static void addInstance(int id, MapboxGlPlatform platform) {
    _instances[id] = platform;
  }

  static MapboxGlPlatform getInstance(int id) {
    return _instances[id];
  }

  final ArgumentCallbacks<String> onInfoWindowTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onSymbolTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onLineTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onCircleTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<String> onFillTappedPlatform =
      ArgumentCallbacks<String>();

  final ArgumentCallbacks<void> onCameraMoveStartedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<CameraPosition> onCameraMovePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onCameraIdlePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onRotateBeginPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onRotatePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onRotateEndPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onFlingPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onShoveBeginPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onShovePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onMapMovePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onMapMoveEndPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onMapMoveBeginPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onScalePlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onScaleBeginPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onScaleEndPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<CameraPosition> onShoveEndPlatform =
      ArgumentCallbacks<CameraPosition>();

  final ArgumentCallbacks<void> onMapStyleLoadedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<Map<String, dynamic>> onMapClickPlatform =
      ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<Map<String, dynamic>> onMapLongClickPlatform =
      ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<MyLocationTrackingMode>
      onCameraTrackingChangedPlatform =
      ArgumentCallbacks<MyLocationTrackingMode>();

  final ArgumentCallbacks<void> onCameraTrackingDismissedPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<void> onMapIdlePlatform = ArgumentCallbacks<void>();

  final ArgumentCallbacks<UserLocation> onUserLocationUpdatedPlatform =
      ArgumentCallbacks<UserLocation>();

  Future<void> initPlatform(int id) async {
    throw UnimplementedError('initPlatform() has not been implemented.');
  }

  Widget buildView(
      Map<String, dynamic> creationParams,
      Function onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  Future<CameraPosition> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  Future<bool> animateCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    throw UnimplementedError(
        'updateMyLocationTrackingMode() has not been implemented.');
  }

  Future<void> matchMapLanguageWithDeviceDefault() async {
    throw UnimplementedError(
        'matchMapLanguageWithDeviceDefault() has not been implemented.');
  }

  Future<void> updateContentInsets(EdgeInsets insets, bool animated) async {
    throw UnimplementedError('updateContentInsets() has not been implemented.');
  }

  Future<void> setMapLanguage(String language) async {
    throw UnimplementedError('setMapLanguage() has not been implemented.');
  }

  Future<void> setTelemetryEnabled(bool enabled) async {
    throw UnimplementedError('setTelemetryEnabled() has not been implemented.');
  }

  Future<bool> getTelemetryEnabled() async {
    throw UnimplementedError('getTelemetryEnabled() has not been implemented.');
  }

  Future<List<Symbol>> addSymbols(List<SymbolOptions> options,
      [List<Map> data]) async {
    throw UnimplementedError('addSymbols() has not been implemented.');
  }

  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    throw UnimplementedError('updateSymbol() has not been implemented.');
  }

  Future<void> removeSymbols(Iterable<String> symbolsIds) async {
    throw UnimplementedError('removeSymbol() has not been implemented.');
  }

  Future<Line> addLine(LineOptions options, [Map data]) async {
    throw UnimplementedError('addLine() has not been implemented.');
  }

  Future<void> updateLine(Line line, LineOptions changes) async {
    throw UnimplementedError('updateLine() has not been implemented.');
  }

  Future<void> removeLine(String lineId) async {
    throw UnimplementedError('removeLine() has not been implemented.');
  }

  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    throw UnimplementedError('addCircle() has not been implemented.');
  }

  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    throw UnimplementedError('updateCircle() has not been implemented.');
  }

  Future<LatLng> getCircleLatLng(Circle circle) async {
    throw UnimplementedError('getCircleLatLng() has not been implemented.');
  }

  Future<LatLng> getSymbolLatLng(Symbol symbol) async {
    throw UnimplementedError('getSymbolLatLng() has not been implemented.');
  }

  Future<List<LatLng>> getLineLatLngs(Line line) async {
    throw UnimplementedError('getLineLatLngs() has not been implemented.');
  }

  Future<void> removeCircle(String circleId) async {
    throw UnimplementedError('removeCircle() has not been implemented.');
  }

  Future<Fill> addFill(FillOptions options, [Map data]) async {
    throw UnimplementedError('addFill() has not been implemented.');
  }

  Future<void> updateFill(Fill fill, FillOptions changes) async {
    throw UnimplementedError('updateFill() has not been implemented.');
  }

  Future<void> removeFill(String fillId) async {
    throw UnimplementedError('removeFill() has not been implemented.');
  }

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object> filter) async {
    throw UnimplementedError(
        'queryRenderedFeatures() has not been implemented.');
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    throw UnimplementedError(
        'queryRenderedFeaturesInRect() has not been implemented.');
  }

  Future invalidateAmbientCache() async {
    throw UnimplementedError(
        'invalidateAmbientCache() has not been implemented.');
  }

  Future<LatLng> requestMyLocationLatLng() async {
    throw UnimplementedError(
        'requestMyLocationLatLng() has not been implemented.');
  }

  Future<LatLngBounds> getVisibleRegion() async {
    throw UnimplementedError('getVisibleRegion() has not been implemented.');
  }

  Future<void> addImage(String name, Uint8List bytes,
      [bool sdf = false]) async {
    throw UnimplementedError('addImage() has not been implemented.');
  }

  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    throw UnimplementedError(
        'setSymbolIconAllowOverlap() has not been implemented.');
  }

  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    throw UnimplementedError(
        'setSymbolIconIgnorePlacement() has not been implemented.');
  }

  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    throw UnimplementedError(
        'setSymbolTextAllowOverlap() has not been implemented.');
  }

  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    throw UnimplementedError(
        'setSymbolTextIgnorePlacement() has not been implemented.');
  }

  Future<void> addSource(String sourceId, String geojson) async {
    throw UnimplementedError('addSource() has not been implemented.');
  }

  Future<void> addLayerProperties(
      String layerId, Map<String, dynamic> properties) async {
    throw UnimplementedError('addLayerProperties() has not been implemented.');
  }

  Future<void> addSourceFeaturesCustom(String sourceId, String features) async {
    throw UnimplementedError(
        'addSourceFeaturesCustom() has not been implemented.');
  }

  Future<void> addSymbolLayerCustom(
    String sourceId,
    String layerId,
    Map<String, String> properties,
    String filter,
    String placeBelowLayerId,
    String placeAboveLayerId,
  ) async {
    throw UnimplementedError(
        'addSymbolLayerCustom() has not been implemented.');
  }

  Future<void> addLineLayerCustom(
    String sourceId,
    String layerId,
    Map<String, String> properties,
    String filter,
    String placeBelowLayerId,
    String placeAboveLayerId,
  ) async {
    throw UnimplementedError('addLineLayerCustom() has not been implemented.');
  }

  Future<void> addFillLayerCustom(
    String sourceId,
    String layerId,
    Map<String, String> properties,
    String filter,
    String placeBelowLayerId,
    String placeAboveLayerId,
  ) async {
    throw UnimplementedError('addFillLayerCustom() has not been implemented.');
  }

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) async {
    throw UnimplementedError('addImageSource() has not been implemented.');
  }

  Future<void> removeImageSource(String imageSourceId) async {
    throw UnimplementedError('removeImageSource() has not been implemented.');
  }

  Future<void> addLayer(String imageLayerId, String imageSourceId) async {
    throw UnimplementedError('addLayer() has not been implemented.');
  }

  Future<void> addLayerBelow(
      String imageLayerId, String imageSourceId, String belowLayerId) async {
    throw UnimplementedError('addLayerBelow() has not been implemented.');
  }

  Future<void> removeLayer(String imageLayerId) async {
    throw UnimplementedError('removeLayer() has not been implemented.');
  }

  Future<Point> toScreenLocation(LatLng latLng) async {
    throw UnimplementedError('toScreenLocation() has not been implemented.');
  }

  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    throw UnimplementedError(
        'toScreenLocationList() has not been implemented.');
  }

  Future<LatLng> toLatLng(Point screenLocation) async {
    throw UnimplementedError('toLatLng() has not been implemented.');
  }

  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    throw UnimplementedError(
        'getMetersPerPixelAtLatitude() has not been implemented.');
  }

  Future<void> toggleLayerVisibility(
      List<String> layerIds, bool isVisible) async {
    throw UnimplementedError(
        'toggleLayerVisibility() has not been implemented.');
  }

  Future<void> setStyleString(String styleString) async {
    throw UnimplementedError('setStyleString() has not been implemented.');
  }

  Future<void> setFilter(List<String> layerIds, String filterString) async {
    throw UnimplementedError('setFilter() has not been implemented.');
  }
}
