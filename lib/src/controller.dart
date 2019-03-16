// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

typedef void OnMapClickCallback(Point<double> point, LatLng coordinates);

typedef void OnCameraTrackingDismissedCallback();

/// Controller for a single MapboxMap instance running on the host platform.
///
/// Change listeners are notified upon changes to any of
///
/// * the [options] property
/// * the collection of [Symbol]s added to this map
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
///
/// Symbol tap events can be received by adding callbacks to [onSymbolTapped].
/// Circle tap events can be received by adding callbacks to [onCircleTapped].
class MapboxMapController extends ChangeNotifier {
  MapboxMapController._(
      this._id, MethodChannel channel, CameraPosition initialCameraPosition,
      {this.onMapClick, this.onCameraTrackingDismissed})
      : assert(_id != null),
        assert(channel != null),
        _channel = channel {
    _cameraPosition = initialCameraPosition;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<MapboxMapController> init(
      int id, CameraPosition initialCameraPosition,
      {OnMapClickCallback onMapClick,
      OnCameraTrackingDismissedCallback onCameraTrackingDismissed}) async {
    assert(id != null);
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/mapbox_maps_$id');
    await channel.invokeMethod('map#waitForMap');
    return MapboxMapController._(id, channel, initialCameraPosition,
        onMapClick: onMapClick,
        onCameraTrackingDismissed: onCameraTrackingDismissed);
  }

  final MethodChannel _channel;

  final OnMapClickCallback onMapClick;

  final OnCameraTrackingDismissedCallback onCameraTrackingDismissed;

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

  final int _id;

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
      case 'map#onMapClick':
        final double x = call.arguments['x'];
        final double y = call.arguments['y'];
        final double lng = call.arguments['lng'];
        final double lat = call.arguments['lat'];
        if (onMapClick != null) {
          onMapClick(Point<double>(x, y), LatLng(lat, lng));
        }
        break;
      case 'map#onCameraTrackingDismissed':
        if (onCameraTrackingDismissed != null) {
          onCameraTrackingDismissed();
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
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _channel.invokeMethod('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _channel.invokeMethod('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Adds a symbol to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the symbol has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added symbol once listeners have
  /// been notified.
  Future<Symbol> addSymbol(SymbolOptions options) async {
    final SymbolOptions effectiveOptions =
        SymbolOptions.defaultOptions.copyWith(options);
    final String symbolId = await _channel.invokeMethod(
      'symbol#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Symbol symbol = Symbol(symbolId, effectiveOptions);
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

  /// Adds a circle to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the circle has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added circle once listeners have
  /// been notified.
  Future<Circle> addCircle(CircleOptions options) async {
    final CircleOptions effectiveOptions =
    CircleOptions.defaultOptions.copyWith(options);
    final String circleId = await _channel.invokeMethod(
      'circle#add',
      <String, dynamic>{
        'options': effectiveOptions._toJson(),
      },
    );
    final Circle circle = Circle(circleId, effectiveOptions);
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
}
