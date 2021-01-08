part of mapbox_gl_web;

/// Signature for when a tap has occurred.
typedef FillTapCallback = void Function(String id);

class FillManager extends FeatureManager<FillOptions> {
  final MapboxMap map;
  final FillTapCallback onTap;

  FillManager({
    @required this.map,
    this.onTap,
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
    Feature oldFeature = getFeature(featureId);
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
    Feature oldFeature = getFeature(featureId);
    Feature newFeature = Convert.intepretFillOptions(changes, oldFeature);
    updateFeature(newFeature);
  }
}
