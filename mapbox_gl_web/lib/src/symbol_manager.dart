part of mapbox_gl_web;

/// Signature for when a tap has occurred.
typedef SymbolTapCallback = void Function(String id);

class SymbolManager {
  final String sourceId = 'symbol_source';
  final String layerId = 'symbol_layer';
  final MapboxMap map;
  final SymbolTapCallback onTap;

  final Map<String, Feature> _symbolFeatures = {};
  num symbolCounter = 1;
  String draggableSymbolId;

  SymbolManager({
    @required this.map,
    this.onTap,
  }) {
    var symbolSource = GeoJsonSource(data: FeatureCollection(features: []));
    map.addSource(sourceId, symbolSource);

    map.addLayer({
      'id': layerId,
      'type': 'symbol',
      'source': sourceId,
      'layout': {
        'icon-image': '{iconImage}',
        'icon-size': ['get', 'iconSize'],
        'icon-rotate': ['get', 'iconRotate'],
        'icon-offset': ['get', 'iconOffset'],
        'icon-anchor': ['get', 'iconAnchor'],
        'text-field': ['get', 'textField'],
        'text-size': ['get', 'textSize'],
        'text-max-width': ['get', 'textMaxWidth'],
        'text-letter-spacing': ['get', 'textLetterSpacing'],
        'text-justify': ['get', 'textJustify'],
        'text-anchor': ['get', 'textAnchor'],
        'text-rotate': ['get', 'textRotate'],
        'text-transform': ['get', 'textTransform'],
        'text-offset': ['get', 'textOffset'],
        'symbol-sort-key': ['get', 'symbolSortKey'],
        'icon-allow-overlap': true,
        'icon-ignore-placement': true,
        'text-allow-overlap': true,
        'text-ignore-placement': true,
      },
      'paint': {
        'icon-opacity': ['get', 'iconOpacity'],
        'icon-color': ['get', 'iconColor'],
        'icon-halo-color': ['get', 'iconHaloColor'],
        'icon-halo-width': ['get', 'iconHaloWidth'],
        'icon-halo-blur': ['get', 'iconHaloBlur'],
        'text-opacity': ['get', 'textOpacity'],
        'text-color': ['get', 'textColor'],
        'text-halo-color': ['get', 'textHaloColor'],
        'text-halo-width': ['get', 'textHaloWidth'],
        'text-halo-blur': ['get', 'textHaloBlur'],
      }
    });

    map.on('click', layerId, (e) {
      if (onTap != null) {
        onTap('${e.features[0].id}');
      }
    });

    map.on('mouseenter', layerId, (_) {
      map.getCanvas().style.cursor = 'pointer';
    });

    map.on('mouseleave', layerId, (_) {
      map.getCanvas().style.cursor = '';
    });

    map.on('styleimagemissing', (event) {
      var density = context['window'].devicePixelRatio ?? 1;
      var imagePath = density == 1
          ? '/assets/assets/symbols/custom-icon.png'
          : '/assets/assets/symbols/$density.0x/custom-icon.png';
      map.loadImage(imagePath, (error, image) {
        if (error != null) throw error;
        if (!map.hasImage(event.id))
          map.addImage(event.id, image, {'pixelRatio': density});
      });
    });

    map.on('mousedown', layerId, (e) {
      var isDraggable = e.features[0].properties['draggable'];
      if (isDraggable != null && isDraggable) {
        // Prevent the default map drag behavior.
        e.preventDefault();
        draggableSymbolId = '${e.features[0].id}';
        map.getCanvas().style.cursor = 'grabbing';
      }
    });

    map.on('mousemove', (e) {
      if (draggableSymbolId != null) {
        var coords = e.lngLat;
        update(draggableSymbolId,
            SymbolOptions(geometry: LatLng(coords.lat, coords.lng)));
      }
    });
    map.on('mouseup', (_) {
      draggableSymbolId = null;
      map.getCanvas().style.cursor = '';
    });
  }

  String add(Feature feature) {
    feature.id = symbolCounter++;
    _symbolFeatures['${feature.id}'] = feature;
    _updateSource();
    return '${feature.id}';
  }

  void update(String symbolId, SymbolOptions changes) {
    Feature olfFeature = _symbolFeatures[symbolId];
    Feature newFeature = Convert.interpretSymbolOptions(changes, olfFeature);
    _symbolFeatures[symbolId] = newFeature;
    _updateSource();
  }

  void remove(String symbolId) {
    _symbolFeatures.remove(symbolId);
    _updateSource();
  }

  void _updateSource() {
    var symbolSource = map.getSource(sourceId);
    symbolSource.setData(
        FeatureCollection(features: _symbolFeatures.values.toList()).jsObject);
  }
}
