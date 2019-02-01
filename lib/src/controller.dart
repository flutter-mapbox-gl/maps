part of mapbox_gl;

typedef OnMapTapCallback(ScreenPoint point, LatLng coordinates);

class MapViewController extends ChangeNotifier {
  final MethodChannel _channel;
  // MapViewControllerListener _listener;
  OnMapTapCallback onTap;

  MapViewController(int id, {this.onTap}) : _channel = new MethodChannel('com.mapbox/mapboxgl_$id') {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTap':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        if (onTap != null) onTap(ScreenPoint(x, y), LatLng(lng: lng, lat: lat));
        break;

      default:
        print("unknown methpd called");
    }
  }


  Future<Null> showUserLocation() async {
    try {
      await _channel.invokeMethod('showUserLocation');
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<Null> setStyleUrl(String styleUrl) async {
    try {
      await _channel.invokeMethod('setStyleUrl', styleUrl);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<String> getStyleUrl() async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'getStyleUrl',
        // <String, Object>{'textureId': _textureId},
      );
      return reply['styleUrl'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  //
  // Camera API
  //

  Future<Null> easeTo(Camera camera, int duration) async {
    try {
      await _channel.invokeMethod(
        'easeTo',
        <String, Object>{
          'camera': camera.toMap(),
          'duration': duration,
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<Null> flyTo(Camera camera, int duration) async {
    try {
      await _channel.invokeMethod(
        'flyTo',
        <String, Object>{
          'camera': camera.toMap(),
          'duration': duration,
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<Null> jumpTo(Camera camera) async {
    try {
      await _channel.invokeMethod(
        'jumpTo',
        <String, Object>{'camera': camera.toMap()},
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<Null> zoom(double zoom, int duration) async {
    try {
      await _channel.invokeMethod(
        'zoom',
        <String, Object>{'zoom': zoom, 'duration': duration},
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future<List> queryRenderedFeatures(
      ScreenPoint point, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'queryRenderedFeatures',
        <String, Object>{
          'x': point.x,
          'y': point.y,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// see https://www.mapbox.com/mapbox-gl-js/api/#map#setlayoutproperty
  /// example for a layeout property: https://www.mapbox.com/mapbox-gl-js/example/toggle-layers/
  /// example with setPaintProperty: https://www.mapbox.com/mapbox-gl-js/example/adjust-layer-opacity/
  Future<Null> setLayerProperty(String layer, String propertyName, dynamic value,
      {Map options}) async {
    try {
      await _channel.invokeMethod(
        'setLayerProperty',
         <String, Object>{
          'layer': layer,
          'propertyName': propertyName,
          'value': value,
          'options': options, 
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// see https://www.mapbox.com/mapbox-gl-js/api/#map#setlayoutproperty
  /// I am still working on it (don't have an example yet)
  Future<Null> setFilter(String layer, {List<Map> filter}) async {
    try {
      await _channel.invokeMethod(
        'setFilter',
        <String, Object>{
          'layer': layer,
          'filter': filter, 
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// see https://www.mapbox.com/mapbox-gl-js/api/#map#setlayoutproperty
  /// No example yet
  Future<Null> addLayer(Layer layer, {String before}) async {
    try {
      await _channel.invokeMethod(
        'addLayer',
        <String, Object>{
          'layer': layer, //this should be converted to a map, or a JSON or something.
          'before': before,
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// see https://www.mapbox.com/mapbox-gl-js/api/#map#setlayoutproperty
  /// No example yet
  Future<Null> setSourceGeoJson(String sourceName, Map<String, dynamic> geoJson) async {
    try {
      String geoJsonString = json.encode(geoJson);
      await _channel.invokeMethod(
        'setSourceGeoJson',
        <String, Object>{
          'sourceName': sourceName,
          'geoJson': geoJsonString,
        },
      );
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  // Future<double> getZoom() async {
  //   try {
  //     final Map<Object, Object> reply = await _channel.invokeMethod('getZoom');
  //     return reply['zoom'];
  //   } on PlatformException catch (e) {
  //     return new Future.error(e);
  //   }
  // }

}
