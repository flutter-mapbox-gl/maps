// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

typedef void OnMapClickCallback(Point<double> point, LatLng coordinates);

typedef void OnStyleLoadedCallback();

typedef void OnCameraTrackingDismissedCallback();
typedef void OnCameraTrackingChangedCallback(MyLocationTrackingMode mode);

typedef void OnMapIdleCallback();

/// Controller for a single MapboxMap instance running on the host platform.
///
/// Change listeners are notified upon changes to any of
///
/// * the [options] property
/// * the collection of [Symbol]s added to this map
/// * the collection of [Line]s added to this map
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
///
/// Symbol tap events can be received by adding callbacks to [onSymbolTapped].
/// Line tap events can be received by adding callbacks to [onLineTapped].
/// Circle tap events can be received by adding callbacks to [onCircleTapped].
class MapboxMapController extends ChangeNotifier {
  MapboxMapController._(
      this._id, MethodChannel channel, CameraPosition initialCameraPosition,
      {this.onStyleLoadedCallback,
      this.onMapClick,
      this.onCameraTrackingDismissed,
      this.onCameraTrackingChanged,
      this.onMapIdle})
      : assert(_id != null),
        assert(channel != null),
        _channel = channel {
    _cameraPosition = initialCameraPosition;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<MapboxMapController> init(
      int id, CameraPosition initialCameraPosition,
      {OnStyleLoadedCallback onStyleLoadedCallback,
      OnMapClickCallback onMapClick,
      OnCameraTrackingDismissedCallback onCameraTrackingDismissed,
      OnCameraTrackingChangedCallback onCameraTrackingChanged,
      OnMapIdleCallback onMapIdle}) async {
    assert(id != null);
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/mapbox_maps_$id');
    await channel.invokeMethod('map#waitForMap');
    return MapboxMapController._(id, channel, initialCameraPosition,
        onStyleLoadedCallback: onStyleLoadedCallback,
        onMapClick: onMapClick,
        onCameraTrackingDismissed: onCameraTrackingDismissed,
        onCameraTrackingChanged: onCameraTrackingChanged,
        onMapIdle: onMapIdle);
  }

  final MethodChannel _channel;

  final OnStyleLoadedCallback onStyleLoadedCallback;

  final OnMapClickCallback onMapClick;

  final OnCameraTrackingDismissedCallback onCameraTrackingDismissed;
  final OnCameraTrackingChangedCallback onCameraTrackingChanged;

  final OnMapIdleCallback onMapIdle;

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Symbol> onSymbolTapped = ArgumentCallbacks<Symbol>();

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Circle> onCircleTapped = ArgumentCallbacks<Circle>();

  /// Callbacks to receive tap events for info windows on symbols
  final ArgumentCallbacks<Symbol> onInfoWindowTapped =
      ArgumentCallbacks<Symbol>();

  /// The current set of symbols on this map.
  ///
  /// The returned set will be a detached snapshot of the symbols collection.
  Set<Symbol> get symbols => Set<Symbol>.from(_symbols.values);
  final Map<String, Symbol> _symbols = <String, Symbol>{};

  /// Callbacks to receive tap events for lines placed on this map.
  final ArgumentCallbacks<Line> onLineTapped = ArgumentCallbacks<Line>();

  /// The current set of lines on this map.
  ///
  /// The returned set will be a detached snapshot of the lines collection.
  Set<Line> get lines => Set<Line>.from(_lines.values);
  final Map<String, Line> _lines = <String, Line>{};

  /// The current set of circles on this map.
  ///
  /// The returned set will be a detached snapshot of the symbols collection.
  Set<Circle> get circles => Set<Circle>.from(_circles.values);
  final Map<String, Circle> _circles = <String, Circle>{};

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [MapboxMap.trackCameraPosition] is false.
  CameraPosition get cameraPosition => _cameraPosition;
  CameraPosition _cameraPosition;

  final int _id; //ignore: unused_field

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'infoWindow#onTap':
        final String symbolId = call.arguments['symbol'];
        final Symbol symbol = _symbols[symbolId];
        if (symbol != null) {
          onInfoWindowTapped(symbol);
        }
        break;
      case 'symbol#onTap':
        final String symbolId = call.arguments['symbol'];
        final Symbol symbol = _symbols[symbolId];
        if (symbol != null) {
          onSymbolTapped(symbol);
        }
        break;
      case 'line#onTap':
        final String lineId = call.arguments['line'];
        final Line line = _lines[lineId];
        if (line != null) {
          onLineTapped(line);
        }
        break;
      case 'circle#onTap':
        final String circleId = call.arguments['circle'];
        final Circle circle = _circles[circleId];
        if (circle != null) {
          onCircleTapped(circle);
        }
        break;
      case 'camera#onMoveStarted':
        _isCameraMoving = true;
        notifyListeners();
        break;
      case 'camera#onMove':
        _cameraPosition = CameraPosition.fromMap(call.arguments['position']);
        notifyListeners();
        break;
      case 'camera#onIdle':
        _isCameraMoving = false;
        notifyListeners();
        break;
      case 'map#onStyleLoaded':
        if (onStyleLoadedCallback != null) {
          onStyleLoadedCallback();
        }
        break;
      case 'map#onMapClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        if (onMapClick != null) {
          onMapClick(Point<double>(x, y), LatLng(lat, lng));
        }
        break;
      case 'map#onCameraTrackingChanged':
        if (onCameraTrackingChanged != null) {
          final int mode = call.arguments['mode'];
          onCameraTrackingChanged(MyLocationTrackingMode.values[mode]);
        }
        break;
      case 'map#onCameraTrackingDismissed':
        if (onCameraTrackingDismissed != null) {
          onCameraTrackingDismissed();
        }
        break;
      case 'map#onIdle':
        if (onMapIdle != null) {
          onMapIdle();
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
    final dynamic json = await _channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
    _cameraPosition = CameraPosition.fromMap(json);
    notifyListeners();
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool> animateCamera(CameraUpdate cameraUpdate,
      {Duration duration}) async {
    return await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
      'duration': duration != null ? duration.inMilliseconds : null
    });
  }

  /// Instantaneously re-position the camera.
  /// Note: moveCamera() quickly moves the camera, which can be visually jarring for a user. Strongly consider using the animateCamera() methods instead because it's less abrupt.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    return await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Updates user location tracking mode.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    await _channel
        .invokeMethod('map#updateMyLocationTrackingMode', <String, dynamic>{
      'mode': myLocationTrackingMode.index,
    });
  }

  /// Updates the language of the map labels to match the device's language.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> matchMapLanguageWithDeviceDefault() async {
    await _channel.invokeMethod('map#matchMapLanguageWithDeviceDefault');
  }

  /// Updates the distance from the edges of the map view’s frame to the edges
  /// of the map view’s logical viewport, optionally animating the change.
  ///
  /// When the value of this property is equal to `EdgeInsets.zero`, viewport
  /// properties such as centerCoordinate assume a viewport that matches the map
  /// view’s frame. Otherwise, those properties are inset, excluding part of the
  /// frame from the viewport. For instance, if the only the top edge is inset,
  /// the map center is effectively shifted downward.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> updateContentInsets(EdgeInsets insets,
      [bool animated = false]) async {
    await _channel.invokeMethod('map#updateContentInsets', <String, dynamic>{
      'bounds': <String, double>{
        'top': insets.top,
        'left': insets.left,
        'bottom': insets.bottom,
        'right': insets.right,
      },
      'animated': animated,
    });
  }

  /// Updates the language of the map labels to match the specified language.
  /// Supported language strings are available here: https://github.com/mapbox/mapbox-plugins-android/blob/e29c18d25098eb023a831796ff807e30d8207c36/plugin-localization/src/main/java/com/mapbox/mapboxsdk/plugins/localization/MapLocale.java#L39-L87
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setMapLanguage(String language) async {
    await _channel.invokeMethod('map#setMapLanguage', <String, dynamic>{
      'language': language,
    });
  }

  /// Enables or disables the collection of anonymized telemetry data.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setTelemetryEnabled(bool enabled) async {
    await _channel.invokeMethod('map#setTelemetryEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  /// Retrieves whether collection of anonymized telemetry data is enabled.
  ///
  /// The returned [Future] completes after the query has been made on the
  /// platform side.
  Future<bool> getTelemetryEnabled() async {
    return await _channel.invokeMethod('map#getTelemetryEnabled');
  }

  /// Adds a symbol to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the symbol has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added symbol once listeners have
  /// been notified.
  Future<Symbol> addSymbol(SymbolOptions options, [Map data]) async {
    final SymbolOptions effectiveOptions =
        SymbolOptions.defaultOptions.copyWith(options);
    final String symbolId = await _channel.invokeMethod(
      'symbol#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Symbol symbol = Symbol(symbolId, effectiveOptions, data);
    _symbols[symbolId] = symbol;
    notifyListeners();
    return symbol;
  }

  /// Updates the specified [symbol] with the given [changes]. The symbol must
  /// be a current member of the [symbols] set.
  ///
  /// Change listeners are notified once the symbol has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    assert(symbol != null);
    assert(_symbols[symbol._id] == symbol);
    assert(changes != null);
    await _channel.invokeMethod('symbol#update', <String, dynamic>{
      'symbol': symbol._id,
      'options': changes._toJson(),
    });
    symbol._options = symbol._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [symbol] from the map. The symbol must be a current
  /// member of the [symbols] set.
  ///
  /// Change listeners are notified once the symbol has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeSymbol(Symbol symbol) async {
    assert(symbol != null);
    assert(_symbols[symbol._id] == symbol);
    await _removeSymbol(symbol._id);
    notifyListeners();
  }

  /// Removes all [symbols] from the map.
  ///
  /// Change listeners are notified once all symbols have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearSymbols() async {
    assert(_symbols != null);
    final List<String> symbolIds = List<String>.from(_symbols.keys);
    for (String id in symbolIds) {
      await _removeSymbol(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single symbol from the map. Consumed by
  /// [removeSymbol] and [clearSymbols].
  ///
  /// The returned [Future] completes once the symbol has been removed from
  /// [_symbols].
  Future<void> _removeSymbol(String id) async {
    await _channel.invokeMethod('symbol#remove', <String, dynamic>{
      'symbol': id,
    });
    _symbols.remove(id);
  }

  /// Adds a line to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the line has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added line once listeners have
  /// been notified.
  Future<Line> addLine(LineOptions options, [Map data]) async {
    final LineOptions effectiveOptions =
        LineOptions.defaultOptions.copyWith(options);
    final String lineId = await _channel.invokeMethod(
      'line#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Line line = Line(lineId, effectiveOptions, data);
    _lines[lineId] = line;
    notifyListeners();
    return line;
  }

  /// Updates the specified [line] with the given [changes]. The line must
  /// be a current member of the [lines] set.
  ///
  /// Change listeners are notified once the line has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateLine(Line line, LineOptions changes) async {
    assert(line != null);
    assert(_lines[line._id] == line);
    assert(changes != null);
    await _channel.invokeMethod('line#update', <String, dynamic>{
      'line': line._id,
      'options': changes._toJson(),
    });
    line._options = line._options.copyWith(changes);
    notifyListeners();
  }

  /// Removes the specified [line] from the map. The line must be a current
  /// member of the [lines] set.
  ///
  /// Change listeners are notified once the line has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeLine(Line line) async {
    assert(line != null);
    assert(_lines[line._id] == line);
    await _removeLine(line._id);
    notifyListeners();
  }

  /// Removes all [lines] from the map.
  ///
  /// Change listeners are notified once all lines have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearLines() async {
    assert(_lines != null);
    final List<String> lineIds = List<String>.from(_lines.keys);
    for (String id in lineIds) {
      await _removeLine(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single line from the map. Consumed by
  /// [removeLine] and [clearLines].
  ///
  /// The returned [Future] completes once the line has been removed from
  /// [_lines].
  Future<void> _removeLine(String id) async {
    await _channel.invokeMethod('line#remove', <String, dynamic>{
      'line': id,
    });
    _lines.remove(id);
  }

  /// Adds a circle to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the circle has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added circle once listeners have
  /// been notified.
  Future<Circle> addCircle(CircleOptions options, [Map data]) async {
    final CircleOptions effectiveOptions =
        CircleOptions.defaultOptions.copyWith(options);
    final String circleId = await _channel.invokeMethod(
      'circle#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Circle circle = Circle(circleId, effectiveOptions, data);
    _circles[circleId] = circle;
    notifyListeners();
    return circle;
  }

  /// Updates the specified [circle] with the given [changes]. The circle must
  /// be a current member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    assert(changes != null);
    await _channel.invokeMethod('circle#update', <String, dynamic>{
      'circle': circle._id,
      'options': changes._toJson(),
    });
    circle._options = circle._options.copyWith(changes);
    notifyListeners();
  }

  /// `circle.options.geometry` can't get real-time location.For example, when you
  /// set circle `draggable` is true,and you dragged circle.At this time you
  /// should use `getCircleLatLng()`
  Future<LatLng> getCircleLatLng(Circle circle) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    Map mapLatLng =
        await _channel.invokeMethod('circle#getGeometry', <String, dynamic>{
      'circle': circle._id,
    });
    LatLng circleLatLng =
        new LatLng(mapLatLng['latitude'], mapLatLng['longitude']);
    notifyListeners();
    return circleLatLng;
  }

  /// Removes the specified [circle] from the map. The circle must be a current
  /// member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeCircle(Circle circle) async {
    assert(circle != null);
    assert(_circles[circle._id] == circle);
    await _removeCircle(circle._id);
    notifyListeners();
  }

  /// Removes all [circles] from the map.
  ///
  /// Change listeners are notified once all circles have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearCircles() async {
    assert(_circles != null);
    final List<String> circleIds = List<String>.from(_circles.keys);
    for (String id in circleIds) {
      await _removeCircle(id);
    }
    notifyListeners();
  }

  /// Helper method to remove a single circle from the map. Consumed by
  /// [removeCircle] and [clearCircles].
  ///
  /// The returned [Future] completes once the circle has been removed from
  /// [_circles].
  Future<void> _removeCircle(String id) async {
    await _channel.invokeMethod('circle#remove', <String, dynamic>{
      'circle': id,
    });
    _circles.remove(id);
  }

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
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

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
        'map#queryRenderedFeatures',
        <String, Object>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'layerIds': layerIds,
          'filter': filter,
        },
      );
      return reply['features'];
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  Future invalidateAmbientCache() async {
    try {
      await _channel.invokeMethod('map#invalidateAmbientCache');
      return null;
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  /// Get last my location
  ///
  /// Return last latlng, nullable

  Future<LatLng> requestMyLocationLatLng() async {
    try {
      final Map<Object, Object> reply = await _channel.invokeMethod(
          'locationComponent#getLastLocation', null);
      double latitude = 0.0, longitude = 0.0;
      if (reply.containsKey("latitude") && reply["latitude"] != null) {
        latitude = double.parse(reply["latitude"].toString());
      }
      if (reply.containsKey("longitude") && reply["longitude"] != null) {
        longitude = double.parse(reply["longitude"].toString());
      }
      return LatLng(latitude, longitude);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }

  ///This method returns the boundaries of the region currently displayed in the map.
  Future<LatLngBounds> getVisibleRegion() async {
    try {
      final Map<Object, Object> reply =
          await _channel.invokeMethod('map#getVisibleRegion', null);
      LatLng southwest, northeast;
      if (reply.containsKey("sw")) {
        List<dynamic> coordinates = reply["sw"];
        southwest = LatLng(coordinates[0], coordinates[1]);
      }
      if (reply.containsKey("ne")) {
        List<dynamic> coordinates = reply["ne"];
        northeast = LatLng(coordinates[0], coordinates[1]);
      }
      return LatLngBounds(southwest: southwest, northeast: northeast);
    } on PlatformException catch (e) {
      return new Future.error(e);
    }
  }
}
