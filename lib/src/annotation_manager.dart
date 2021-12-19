part of mapbox_gl;

int _getFirst(Annotation _) => 0;

abstract class AnnotationManager<T extends Annotation> {
  final MapboxMapController controller;
  final void Function(T)? onTap;
  final _idToAnnotation = <String, T>{};
  final String id;
  List<LayerProperties> get allLayerProperties;
  final int Function(T)? selectLayer;

  T? byId(String id) => _idToAnnotation[id];

  Set<T> get annotations => _idToAnnotation.values.toSet();

  AnnotationManager(this.controller, {this.onTap, this.selectLayer})
      : id = getRandomString(10) {
    for (var i = 0; i < allLayerProperties.length; i++) {
      final layerId = _makeLayerId(i);
      controller.addGeoJsonSource(layerId, buildFeatureCollection([]),
          promoteId: "id");
      controller.addLayer(layerId, layerId, allLayerProperties[i]);
    }

    if (onTap != null) {
      controller.onFeatureTapped.add(_onFeatureTapped);
    }
    controller.onFeatureDrag.add(_onDrag);
  }

  Future<void> rebuildLayers() async {
    for (var i = 0; i < allLayerProperties.length; i++) {
      final layerId = _makeLayerId(i);
      await controller.removeLayer(layerId);
      await controller.addLayer(layerId, layerId, allLayerProperties[i]);
    }
  }

  _onFeatureTapped(dynamic id, Point<double> point, LatLng coordinates) {
    final annotation = _idToAnnotation[id];
    if (annotation != null) {
      onTap!(annotation);
    }
  }

  String _makeLayerId(int layerIndex) => "${id}_$layerIndex";

  Future<void> _setAll() async {
    if (selectLayer != null) {
      final featureBuckets = [for (final _ in allLayerProperties) <T>[]];

      for (final annotation in _idToAnnotation.values) {
        featureBuckets[selectLayer!(annotation)].add(annotation);
      }

      for (var i = 0; i < featureBuckets.length; i++) {
        await controller.setGeoJsonSource(
            _makeLayerId(i),
            buildFeatureCollection(
                [for (final l in featureBuckets[i]) l.toGeoJson()]));
      }
    } else {
      await controller.setGeoJsonSource(
          _makeLayerId(0),
          buildFeatureCollection(
              [for (final l in _idToAnnotation.values) l.toGeoJson()]));
    }
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

  Future<void> dispose() async {
    _idToAnnotation.clear();
    await _setAll();
    for (var i = 0; i < allLayerProperties.length; i++) {
      await controller.removeLayer(_makeLayerId(i));
      await controller.removeSource(_makeLayerId(i));
    }
  }

  _onDrag(dynamic id,
      {required Point<double> point,
      required LatLng origin,
      required LatLng current,
      required LatLng delta}) {
    final annotation = byId(id);
    if (annotation != null) {
      annotation.translate(delta);
      set(annotation);
    }
  }

  Future<void> set(T annoation) async {
    _idToAnnotation[annoation.id] = annoation;
    //Todo: send only the changed line to plugin
    await _setAll();
  }
}

class LineManager extends AnnotationManager<Line> {
  LineManager(MapboxMapController controller, {void Function(Line)? onTap})
      : super(controller, onTap: onTap);
  @override
  List<LayerProperties> get allLayerProperties => const [
        LineLayerProperties(
          lineOpacity: [Expressions.get, 'lineOpacity'],
          lineColor: [Expressions.get, 'lineColor'],
          lineWidth: [Expressions.get, 'lineWidth'],
          lineGapWidth: [Expressions.get, 'lineGapWidth'],
          lineOffset: [Expressions.get, 'lineOffset'],
          lineBlur: [Expressions.get, 'lineBlur'],
        )
      ];
}

class FillManager extends AnnotationManager<Fill> {
  FillManager(MapboxMapController controller, {void Function(Fill)? onTap})
      : super(controller,
            onTap: onTap,
            selectLayer: (Fill fill) =>
                fill.options.fillPattern == null ? 0 : 1);
  @override
  List<LayerProperties> get allLayerProperties => const [
        FillLayerProperties(
          fillOpacity: [Expressions.get, 'fillOpacity'],
          fillColor: [Expressions.get, 'fillColor'],
          fillOutlineColor: [Expressions.get, 'fillOutlineColor'],
        ),
        FillLayerProperties(
          fillOpacity: [Expressions.get, 'fillOpacity'],
          fillColor: [Expressions.get, 'fillColor'],
          fillOutlineColor: [Expressions.get, 'fillOutlineColor'],
          fillPattern: [Expressions.get, 'fillPattern'],
        )
      ];
}

class CircleManager extends AnnotationManager<Circle> {
  CircleManager(MapboxMapController controller, {void Function(Circle)? onTap})
      : super(controller, onTap: onTap);
  @override
  List<LayerProperties> get allLayerProperties => const [
        CircleLayerProperties(
          circleRadius: [Expressions.get, 'circleRadius'],
          circleColor: [Expressions.get, 'circleColor'],
          circleBlur: [Expressions.get, 'circleBlur'],
          circleOpacity: [Expressions.get, 'circleOpacity'],
          circleStrokeWidth: [Expressions.get, 'circleStrokeWidth'],
          circleStrokeColor: [Expressions.get, 'circleStrokeColor'],
          circleStrokeOpacity: [Expressions.get, 'circleStrokeOpacity'],
        )
      ];
}

class SymbolManager extends AnnotationManager<Symbol> {
  SymbolManager(
    MapboxMapController controller, {
    void Function(Symbol)? onTap,
    bool iconAllowOverlap = false,
    bool textAllowOverlap = false,
    bool iconIgnorePlacement = false,
    bool textIgnorePlacement = false,
  })  : _iconAllowOverlap = iconAllowOverlap,
        _textAllowOverlap = textAllowOverlap,
        _iconIgnorePlacement = iconIgnorePlacement,
        _textIgnorePlacement = textIgnorePlacement,
        super(controller, onTap: onTap);

  bool _iconAllowOverlap;
  bool _textAllowOverlap;
  bool _iconIgnorePlacement;
  bool _textIgnorePlacement;

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setIconAllowOverlap(bool value) async {
    _iconAllowOverlap = value;
    await rebuildLayers();
  }

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setTextAllowOverlap(bool value) async {
    _textAllowOverlap = value;
    await rebuildLayers();
  }

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setIconIgnorePlacement(bool value) async {
    _iconIgnorePlacement = value;
    await rebuildLayers();
  }

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setTextIgnorePlacement(bool value) async {
    _textIgnorePlacement = value;
    await rebuildLayers();
  }

  @override
  List<LayerProperties> get allLayerProperties => [
        SymbolLayerProperties(
          iconSize: [Expressions.get, 'iconSize'],
          iconImage: [Expressions.get, 'iconImage'],
          iconRotate: [Expressions.get, 'iconRotate'],
          iconOffset: [Expressions.get, 'iconOffset'],
          iconAnchor: [Expressions.get, 'iconAnchor'],
          textFont: [
            Expressions.caseExpression,
            [Expressions.has, 'fontNames'],
            [Expressions.get, 'fontNames'],
            ["Open Sans Regular", "Arial Unicode MS Regular"],
          ],
          textField: [Expressions.get, 'textField'],
          textSize: [Expressions.get, 'textSize'],
          textMaxWidth: [Expressions.get, 'textMaxWidth'],
          textLetterSpacing: [Expressions.get, 'textLetterSpacing'],
          textJustify: [Expressions.get, 'textJustify'],
          textAnchor: [Expressions.get, 'textAnchor'],
          textRotate: [Expressions.get, 'textRotate'],
          textTransform: [Expressions.get, 'textTransform'],
          textOffset: [Expressions.get, 'textOffset'],
          iconAllowOverlap: _iconAllowOverlap,
          iconIgnorePlacement: _iconIgnorePlacement,
          iconOpacity: [Expressions.get, 'iconOpacity'],
          iconColor: [Expressions.get, 'iconColor'],
          iconHaloColor: [Expressions.get, 'iconHaloColor'],
          iconHaloWidth: [Expressions.get, 'iconHaloWidth'],
          iconHaloBlur: [Expressions.get, 'iconHaloBlur'],
          textOpacity: [Expressions.get, 'textOpacity'],
          textColor: [Expressions.get, 'textColor'],
          textHaloColor: [Expressions.get, 'textHaloColor'],
          textHaloWidth: [Expressions.get, 'textHaloWidth'],
          textHaloBlur: [Expressions.get, 'textHaloBlur'],
          textAllowOverlap: _textAllowOverlap,
          textIgnorePlacement: _textIgnorePlacement,
          symbolSortKey: [Expressions.get, 'zIndex'],
        )
      ];
}
