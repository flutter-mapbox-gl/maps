part of mapbox_gl;

abstract class _AnnotationManager<T extends Annotation> {
  final MapboxMapController controller;
  final void Function(T)? onTap;
  final _idToAnnotation = <String, T>{};
  final id;
  LatLng? _dragOrigin;
  LayerProperties get properties;

  T? byId(String id) => _idToAnnotation[id];

  _AnnotationManager(this.controller, {this.onTap}) : id = getRandomString(10) {
    controller.addGeoJsonSource(id, buildFeatureCollection([]));
    controller.addLayer(id, id, properties);
    if (onTap != null) {
      controller.onFeatureTapped.add(_onFeatureTapped);
    }
  }
  _onFeatureTapped(dynamic id, Point<double> point, LatLng coordinates) {
    final annotation = _idToAnnotation[id];
    if (annotation != null) {
      onTap!(annotation);
    }
  }

  Future<void> _setAll() async {
    return controller.setGeoJsonSource(
        id,
        buildFeatureCollection(
            [for (final l in _idToAnnotation.values) l.toGeoJson()]));
  }

  Future<void> addAll(Iterable<T> annotations) async {
    for (var a in annotations) {
      _idToAnnotation[a.id] = a;
    }
    await _setAll();
  }

  Future<void> add(T annotation) async {
    _idToAnnotation[annotation.id] = annotation;
    await _setAll();
  }

  Future<void> remove(T annotation) async {
    _idToAnnotation.remove(annotation.id);
    await _setAll();
  }

  Future<void> clear() async {
    _idToAnnotation.clear();

    await _setAll();
  }

  // TODO this requires a new call back
  onPointerDown(String id, LatLng position) {
    final annotation = byId(id);
    if (annotation != null && annotation.draggable) {
      if (_dragOrigin == null) {
        // TODO missing from native !!
        //controller.lockCamera();
        _dragOrigin = position;
      } else {
        final moved = annotation.translate(position - _dragOrigin!) as T;
        set(moved);
      }
    }
  }

  // TODO this requires a new call back
  onPointerUp(String id, LatLng position) {
    final annotation = byId(id);
    if (annotation != null) {
      final moved = annotation.translate(position - _dragOrigin!) as T;
      set(moved);
    }
    _dragOrigin = null;
  }

  Future<void> set(T annoation) async {
    _idToAnnotation[annoation.id] = annoation;
    //Todo: send only the changed line to plugin
    await _setAll();
  }
}

class LineManager extends _AnnotationManager<Line> {
  LineManager(MapboxMapController controller, {void Function(Line)? onTap})
      : super(controller, onTap: onTap);
  @override
  LayerProperties get properties => const LineLayerProperties(
        lineOpacity: [Expressions.get, 'lineOpacity'],
        lineColor: [Expressions.get, 'lineColor'],
        lineWidth: [Expressions.get, 'lineWidth'],
        lineGapWidth: [Expressions.get, 'lineGapWidth'],
        lineOffset: [Expressions.get, 'lineOffset'],
        lineBlur: [Expressions.get, 'lineBlur'],
      );
}
