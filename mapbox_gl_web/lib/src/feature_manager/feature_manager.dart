part of mapbox_gl_web;

/// Signature for when a tap has occurred.
typedef FeatureTapCallback = void Function(String id);

abstract class FeatureManager<T> {
  final String sourceId;
  final String layerId;
  final MapboxMap map;
  final FeatureTapCallback onTap;
  @protected
  LatLng dragOrigin;

  final Map<String, Feature> _features = {};
  num featureCounter = 1;
  String _draggableFeatureId;

  FeatureManager({
    @required this.sourceId,
    @required this.layerId,
    @required this.map,
    this.onTap,
  }) {
    var featureSource = GeoJsonSource(data: FeatureCollection(features: []));
    map.addSource(sourceId, featureSource);
    initLayer();
    _initClickHandler();
    _initDragHandler();
  }

  void initLayer();

  void update(String featureId, T changes);

  void onDrag(String featureId, LatLng latLng);

  String add(Feature feature) {
    feature.id = featureCounter++;
    _features['${feature.id}'] = feature;
    _updateSource();
    return '${feature.id}';
  }

  void updateFeature(Feature feature) {
    updateFeatures([feature]);
  }

  void updateFeatures(Iterable<Feature> features) {
    features.forEach((feature) => _features['${feature.id}'] = feature);
    _updateSource();
  }

  void remove(String featureId) {
    removeAll([featureId]);
  }

  void removeAll(Iterable<String> featuresIds) {
    featuresIds.forEach((featureId) => _features.remove(featureId));
    _updateSource();
  }

  Feature getFeature(String featureId) {
    return _features[featureId];
  }

  void _initClickHandler() {
    map.on('click', (e) {
      if (e is Event) {
        final features = map.queryRenderedFeatures([e.point.x, e.point.y]);
        if (features.length > 0 && features[0].source == sourceId) {
          if (onTap != null) {
            onTap('${features[0].id}');
          }
        }
      }
    });

    map.on('mouseenter', layerId, (_) {
      map.getCanvas().style.cursor = 'pointer';
    });

    map.on('mouseleave', layerId, (_) {
      map.getCanvas().style.cursor = '';
    });
  }

  void _initDragHandler() {
    map.on('mousedown', layerId, (e) {
      var isDraggable = e.features[0].properties['draggable'];
      if (isDraggable != null && isDraggable) {
        // Prevent the default map drag behavior.
        e.preventDefault();
        _draggableFeatureId = '${e.features[0].id}';
        map.getCanvas().style.cursor = 'grabbing';
        var coords = e.lngLat;
        dragOrigin = LatLng(coords.lat, coords.lng);
      }
    });

    map.on('mousemove', (e) {
      if (_draggableFeatureId != null) {
        var coords = e.lngLat;
        onDrag(_draggableFeatureId, LatLng(coords.lat, coords.lng));
      }
    });

    map.on('mouseup', (_) {
      _draggableFeatureId = null;
      map.getCanvas().style.cursor = '';
    });
  }

  void _updateSource() {
    GeoJsonSource featureSource = map.getSource(sourceId);
    featureSource
        .setData(FeatureCollection(features: _features.values.toList()));
  }
}
