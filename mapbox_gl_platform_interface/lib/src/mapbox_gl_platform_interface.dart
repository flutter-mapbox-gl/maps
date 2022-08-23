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

  Future<void> initPlatform(int id);
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers);
  Future<CameraPosition?> updateMapOptions(Map<String, dynamic> optionsUpdate);
  Future<bool?> animateCamera(CameraUpdate cameraUpdate, {Duration? duration});
  Future<bool?> moveCamera(CameraUpdate cameraUpdate);
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode);

  Future<void> matchMapLanguageWithDeviceDefault();

  void resizeWebMap();
  void forceResizeWebMap();

  Future<void> updateContentInsets(EdgeInsets insets, bool animated);
  Future<void> setMapLanguage(String language);
  Future<void> setTelemetryEnabled(bool enabled);

  Future<bool> getTelemetryEnabled();
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter);

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter);
  Future invalidateAmbientCache();
  Future<LatLng?> requestMyLocationLatLng();

  Future<LatLngBounds> getVisibleRegion();

  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]);

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates);

  Future<void> addLayer(String imageLayerId, String imageSourceId,
      double? minzoom, double? maxzoom);

  Future<void> addLayerBelow(String imageLayerId, String imageSourceId,
      String belowLayerId, double? minzoom, double? maxzoom);

  Future<void> removeLayer(String imageLayerId);

  Future<void> setFilter(String layerId, dynamic filter);

  Future<Point> toScreenLocation(LatLng latLng);

  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs);

  Future<LatLng> toLatLng(Point screenLocation);

  Future<double> getMetersPerPixelAtLatitude(double latitude);

  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId});

  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson);

  Future<void> setFeatureForGeoJsonSource(
      String sourceId, Map<String, dynamic> geojsonFeature);

  Future<void> removeSource(String sourceId);

  Future<void> addSymbolLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      required bool enableInteraction});

  Future<void> addLineLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      required bool enableInteraction});

  Future<void> addCircleLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      required bool enableInteraction});

  Future<void> addFillLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      required bool enableInteraction});

  Future<void> addRasterLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  Future<void> addHillshadeLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  Future<void> addSource(String sourceId, SourceProperties properties);

  Future<String> takeSnapshot(SnapshotOptions snapshotOptions);

  @mustCallSuper
  void dispose() {
    // clear all callbacks to avoid cyclic refs
    onInfoWindowTappedPlatform.clear();
    onFeatureTappedPlatform.clear();
    onFeatureDraggedPlatform.clear();
    onCameraMoveStartedPlatform.clear();
    onCameraMovePlatform.clear();
    onCameraIdlePlatform.clear();
    onMapStyleLoadedPlatform.clear();

    onMapClickPlatform.clear();
    onMapLongClickPlatform.clear();
    onAttributionClickPlatform.clear();
    onCameraTrackingChangedPlatform.clear();
    onCameraTrackingDismissedPlatform.clear();
    onMapIdlePlatform.clear();
    onUserLocationUpdatedPlatform.clear();
  }
}
