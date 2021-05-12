part of mapbox_gl_web;

class FillManager extends FeatureManager<FillOptions> {
  FillManager({
    required MapboxMap map,
    ArgumentCallbacks<String>? onTap,
  }) : super(
          sourceId: 'fill_source',
          layerId: 'fill_layer',
          map: map,
          onTap: onTap,
        );

  @override
  void initLayer() {
    map.addLayer({
      'id': layerId,
      'type': 'fill',
      'source': sourceId,
      'paint': {
        'fill-color': ['get', 'fillColor'],
        'fill-opacity': ['get', 'fillOpacity'],
        'fill-outline-color': ['get', 'fillOutlineColor'],
      }
    });
  }

  @override
  void onDrag(String featureId, LatLng latLng) {
    Feature oldFeature = getFeature(featureId)!;
    final geometry =
        Convert.featureGeometryToFillGeometry(oldFeature.geometry.coordinates);
    update(
        featureId,
        translateFillOptions(
            FillOptions(geometry: geometry), latLng - dragOrigin));
    dragOrigin = latLng;
  }

  @override
  void update(String featureId, FillOptions changes) {
    Feature oldFeature = getFeature(featureId)!;
    Feature newFeature = Convert.intepretFillOptions(changes, oldFeature);
    updateFeature(newFeature);
  }
}
