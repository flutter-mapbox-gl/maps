// ignore_for_file: unnecessary_getters_setters

part of mapbox_gl_platform_interface;

typedef OnPlatformViewCreatedCallback = void Function(int);

abstract class MapboxGlPlatform {
  /// The default instance of [MapboxGlPlatform] to use.
  ///
  /// Defaults to [MethodChannelMapboxGl].
  ///
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MapboxGlPlatform] when they register themselves.
  static MapboxGlPlatform Function() createInstance =
      () => MethodChannelMapboxGl();

  final onInfoWindowTappedPlatform = ArgumentCallbacks<String>();

  final onFeatureTappedPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onFeatureDraggedPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onCameraMoveStartedPlatform = ArgumentCallbacks<void>();

  final onCameraMovePlatform = ArgumentCallbacks<CameraPosition>();

  final onCameraIdlePlatform = ArgumentCallbacks<CameraPosition?>();

  final onMapStyleLoadedPlatform = ArgumentCallbacks<void>();

  final onMapClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onMapLongClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final ArgumentCallbacks<void> onAttributionClickPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<MyLocationTrackingMode>
      onCameraTrackingChangedPlatform =
      ArgumentCallbacks<MyLocationTrackingMode>();

  final onCameraTrackingDismissedPlatform = ArgumentCallbacks<void>();

  final onMapIdlePlatform = ArgumentCallbacks<void>();

  final onUserLocationUpdatedPlatform = ArgumentCallbacks<UserLocation>();

  Future<void> initPlatform(int id) async {
    throw UnimplementedError('initPlatform() has not been implemented.');
  }

  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  Future<CameraPosition?> updateMapOptions(
      Map<String, dynamic> optionsUpdate) async {
    throw UnimplementedError('updateMapOptions() has not been implemented.');
  }

  Future<bool?> animateCamera(CameraUpdate cameraUpdate) async {
    throw UnimplementedError('animateCamera() has not been implemented.');
  }

  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
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

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    throw UnimplementedError(
        'queryRenderedFeatures() has not been implemented.');
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    throw UnimplementedError(
        'queryRenderedFeaturesInRect() has not been implemented.');
  }

  Future invalidateAmbientCache() async {
    throw UnimplementedError(
        'invalidateAmbientCache() has not been implemented.');
  }

  Future<LatLng?> requestMyLocationLatLng() async {
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

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) async {
    throw UnimplementedError('addImageSource() has not been implemented.');
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

  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId}) async {
    throw UnimplementedError('addGeoJsonSource() has not been implemented.');
  }

  Future<void> setGeoJsonSource(
      String sourceId, Map<String, dynamic> geojson) async {
    throw UnimplementedError('setGeoJsonSource() has not been implemented.');
  }

  Future<void> removeSource(String sourceId) async {
    throw UnimplementedError('removeSource() has not been implemented.');
  }

  Future<void> addSymbolLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    throw UnimplementedError('addSymbolLayer() has not been implemented.');
  }

  Future<void> addLineLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    throw UnimplementedError('addLineLayer() has not been implemented.');
  }

  Future<void> addCircleLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    throw UnimplementedError('addCircleLayer() has not been implemented.');
  }

  Future<void> addFillLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer}) async {
    throw UnimplementedError('addFillLayer() has not been implemented.');
  }

  Future<void> addRasterLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer});

  Future<void> addHillshadeLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId, String? sourceLayer});

  Future<void> addSource(String sourceId, SourceProperties properties);

  void dispose() {}
}
