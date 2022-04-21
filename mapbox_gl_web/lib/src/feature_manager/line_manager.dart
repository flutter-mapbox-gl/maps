part of mapbox_gl_web;

class LineManager extends FeatureManager<LineOptions> {
  LineManager({
    required MapboxMap map,
    ArgumentCallbacks<String>? onTap,
  }) : super(
          sourceId: 'line_source',
          layerId: 'line_layer',
          map: map,
          onTap: onTap,
        );

  @override
  void initLayer() {
    // NOTE: line-pattern disable line-color
    map.addLayer({
      'id': layerId,
      'type': 'line',
      'source': sourceId,
      'layout': {
        'line-join': ['get', 'lineJoin'],
      },
      'paint': {
        'line-opacity': ['get', 'lineOpacity'],
        'line-color': ['get', 'lineColor'],
        'line-width': ['get', 'lineWidth'],
        'line-gap-width': ['get', 'lineGapWidth'],
        'line-offset': ['get', 'lineOffset'],
        'line-blur': ['get', 'lineBlur'],
        //'line-pattern': ['get', 'linePattern'],
      }
    });
  }

  void update(String lineId, LineOptions changes) {
    Feature olfFeature = getFeature(lineId)!;
    Feature newFeature = Convert.interpretLineOptions(changes, olfFeature);
    updateFeature(newFeature);
  }

  @override
  void onDrag(String featureId, LatLng latLng) {
    // TODO: implement onDrag
    print('onDrag is not already implemented');
  }
}
