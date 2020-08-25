part of mapbox_gl_web;

/// Signature for when a tap has occurred.
typedef CircleTapCallback = void Function(String id);

class CircleManager extends FeatureManager<CircleOptions> {
  final MapboxMap map;
  final CircleTapCallback onTap;

  CircleManager({
    @required this.map,
    this.onTap,
  }) : super(
          sourceId: 'circle_source',
          layerId: 'circle_layer',
          map: map,
          onTap: onTap,
        );

  @override
  void initLayer() {
    map.addLayer({
      'id': layerId,
      'type': 'circle',
      'source': sourceId,
      'paint': {
        'circle-radius': ['get', 'circleRadius'],
        'circle-color': ['get', 'circleColor'],
        'circle-blur': ['get', 'circleBlur'],
        'circle-opacity': ['get', 'circleOpacity'],
        'circle-stroke-width': ['get', 'circleStrokeWidth'],
        'circle-stroke-color': ['get', 'circleStrokeColor'],
        'circle-stroke-opacity': ['get', 'circleStrokeOpacity'],
      }
    });
  }

  @override
  void onDrag(String featureId, LatLng latLng) {
    update(featureId, CircleOptions(geometry: latLng));
  }

  @override
  void update(String lineId, CircleOptions changes) {
    Feature olfFeature = getFeature(lineId);
    Feature newFeature = Convert.interpretCircleOptions(changes, olfFeature);
    updateFeature(newFeature);
  }
}
