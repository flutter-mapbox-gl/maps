// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

typedef void OnMapClickCallback(Point<double> point, LatLng coordinates);
typedef void OnMapLongClickCallback(Point<double> point, LatLng coordinates);

typedef void OnStyleLoadedCallback();

typedef void OnCameraTrackingDismissedCallback();
typedef void OnCameraTrackingChangedCallback(MyLocationTrackingMode mode);

typedef void OnCameraIdleCallback();

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
  MapboxMapController._(this._id, CameraPosition initialCameraPosition,
      {this.onStyleLoadedCallback,
      this.onMapClick,
      this.onMapLongClick,
      this.onCameraTrackingDismissed,
      this.onCameraTrackingChanged,
      this.onCameraIdle,
      this.onMapIdle})
      : assert(_id != null) {
    _cameraPosition = initialCameraPosition;

    MapboxGlPlatform.instance.onInfoWindowTappedPlatform.add((symbolId) {
      final Symbol symbol = _symbols[symbolId];
      if (symbol != null) {
        onInfoWindowTapped(symbol);
      }
    });

    MapboxGlPlatform.instance.onSymbolTappedPlatform.add((symbolId) {
      final Symbol symbol = _symbols[symbolId];
      if (symbol != null) {
        onSymbolTapped(symbol);
      }
    });

    MapboxGlPlatform.instance.onLineTappedPlatform.add((lineId) {
      final Line line = _lines[lineId];
      if (line != null) {
        onLineTapped(line);
      }
    });

    MapboxGlPlatform.instance.onCircleTappedPlatform.add((circleId) {
      final Circle circle = _circles[circleId];
      if (circle != null) {
        onCircleTapped(circle);
      }
    });

    MapboxGlPlatform.instance.onCameraMoveStartedPlatform.add((_) {
      _isCameraMoving = true;
      notifyListeners();
    });

    MapboxGlPlatform.instance.onCameraMovePlatform.add((cameraPosition) {
      _cameraPosition = cameraPosition;
      notifyListeners();
    });

    MapboxGlPlatform.instance.onCameraIdlePlatform.add((_) {
      _isCameraMoving = false;
      notifyListeners();
    });

    MapboxGlPlatform.instance.onMapStyleLoadedPlatform.add((_) {
      if (onStyleLoadedCallback != null) {
        onStyleLoadedCallback();
      }
    });

    MapboxGlPlatform.instance.onMapClickPlatform.add((dict) {
      if (onMapClick != null) {
        onMapClick(dict['point'], dict['latLng']);
      }
    });

    MapboxGlPlatform.instance.onMapLongClickPlatform.add((dict) {
      if (onMapLongClick != null) {
        onMapLongClick(dict['point'], dict['latLng']);
      }
    });

    MapboxGlPlatform.instance.onCameraTrackingChangedPlatform.add((mode) {
      if (onCameraTrackingChanged != null) {
        onCameraTrackingChanged(mode);
      }
    });

    MapboxGlPlatform.instance.onCameraTrackingDismissedPlatform.add((_) {
      if (onCameraTrackingDismissed != null) {
        onCameraTrackingDismissed();
      }
    });

    MapboxGlPlatform.instance.onMapIdlePlatform.add((_) {
      if (onMapIdle != null) {
        onMapIdle();
      }
    });
  }

  static Future<MapboxMapController> init(
      int id, CameraPosition initialCameraPosition,
      {OnStyleLoadedCallback onStyleLoadedCallback,
      OnMapClickCallback onMapClick,
      OnMapLongClickCallback onMapLongClick,
      OnCameraTrackingDismissedCallback onCameraTrackingDismissed,
      OnCameraTrackingChangedCallback onCameraTrackingChanged,
      OnCameraIdleCallback onCameraIdle,
      OnMapIdleCallback onMapIdle}) async {
    assert(id != null);
    await MapboxGlPlatform.instance.initPlatform(id);
    return MapboxMapController._(id, initialCameraPosition,
        onStyleLoadedCallback: onStyleLoadedCallback,
        onMapClick: onMapClick,
        onMapLongClick: onMapLongClick,
        onCameraTrackingDismissed: onCameraTrackingDismissed,
        onCameraTrackingChanged: onCameraTrackingChanged,
        onCameraIdle: onCameraIdle,
        onMapIdle: onMapIdle);
  }

  final OnStyleLoadedCallback onStyleLoadedCallback;

  final OnMapClickCallback onMapClick;
  final OnMapLongClickCallback onMapLongClick;

  final OnCameraTrackingDismissedCallback onCameraTrackingDismissed;
  final OnCameraTrackingChangedCallback onCameraTrackingChanged;

  final OnCameraIdleCallback onCameraIdle;

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

  Widget buildView(
      Map<String, dynamic> creationParams,
      Function onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers) {
    return MapboxGlPlatform.instance
        .buildView(creationParams, onPlatformViewCreated, gestureRecognizers);
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
    _cameraPosition =
        await MapboxGlPlatform.instance.updateMapOptions(optionsUpdate);
    notifyListeners();
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool> animateCamera(CameraUpdate cameraUpdate) async {
    assert(cameraUpdate != null);
    return MapboxGlPlatform.instance.animateCamera(cameraUpdate);
  }

  /// Instantaneously re-position the camera.
  /// Note: moveCamera() quickly moves the camera, which can be visually jarring for a user. Strongly consider using the animateCamera() methods instead because it's less abrupt.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool> moveCamera(CameraUpdate cameraUpdate) async {
    return MapboxGlPlatform.instance.moveCamera(cameraUpdate);
  }

  /// Updates user location tracking mode.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    return MapboxGlPlatform.instance
        .updateMyLocationTrackingMode(myLocationTrackingMode);
  }

  /// Updates the language of the map labels to match the device's language.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> matchMapLanguageWithDeviceDefault() async {
    return MapboxGlPlatform.instance.matchMapLanguageWithDeviceDefault();
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
    return MapboxGlPlatform.instance.updateContentInsets(insets, animated);
  }

  /// Updates the language of the map labels to match the specified language.
  /// Supported language strings are available here: https://github.com/mapbox/mapbox-plugins-android/blob/e29c18d25098eb023a831796ff807e30d8207c36/plugin-localization/src/main/java/com/mapbox/mapboxsdk/plugins/localization/MapLocale.java#L39-L87
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setMapLanguage(String language) async {
    return MapboxGlPlatform.instance.setMapLanguage(language);
  }

  /// Enables or disables the collection of anonymized telemetry data.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setTelemetryEnabled(bool enabled) async {
    return MapboxGlPlatform.instance.setTelemetryEnabled(enabled);
  }

  /// Retrieves whether collection of anonymized telemetry data is enabled.
  ///
  /// The returned [Future] completes after the query has been made on the
  /// platform side.
  Future<bool> getTelemetryEnabled() async {
    return MapboxGlPlatform.instance.getTelemetryEnabled();
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
    final symbol = await MapboxGlPlatform.instance.addSymbol(effectiveOptions);
    _symbols[symbol.id] = symbol;
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
    assert(_symbols[symbol.id] == symbol);
    assert(changes != null);
    await MapboxGlPlatform.instance.updateSymbol(symbol, changes);
    symbol.options = symbol.options.copyWith(changes);
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
    assert(_symbols[symbol.id] == symbol);
    await _removeSymbol(symbol.id);
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
    await MapboxGlPlatform.instance.removeSymbol(id);
    _symbols.remove(id);
  }

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setSymbolIconAllowOverlap(bool enable) async {
    await _channel.invokeMethod('symbolManager#iconAllowOverlap', <String, dynamic>{
      'iconAllowOverlap': enable,
    });
  }
  
  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setSymbolIconIgnorePlacement(bool enable) async {
    await _channel.invokeMethod('symbolManager#iconIgnorePlacement', <String, dynamic>{
      'iconIgnorePlacement': enable,
    });
  }
  
  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setSymbolTextAllowOverlap(bool enable) async {
    await _channel.invokeMethod('symbolManager#textAllowOverlap', <String, dynamic>{
      'textAllowOverlap': enable,
    });
  }

  /// For more information on what this does, see https://docs.mapbox.com/help/troubleshooting/optimize-map-label-placement/#label-collision
  Future<void> setSymbolTextIgnorePlacement(bool enable) async {
    await _channel.invokeMethod('symbolManager#textIgnorePlacement', <String, dynamic>{
      'textIgnorePlacement': enable,
    });
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
    final line = await MapboxGlPlatform.instance.addLine(effectiveOptions);
    _lines[line.id] = line;
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
    assert(_lines[line.id] == line);
    assert(changes != null);
    await MapboxGlPlatform.instance.updateLine(line, changes);
    line.options = line.options.copyWith(changes);
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
    assert(_lines[line.id] == line);
    await _removeLine(line.id);
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
    await MapboxGlPlatform.instance.removeLine(id);
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
    final circle = await MapboxGlPlatform.instance.addCircle(effectiveOptions);
    _circles[circle.id] = circle;
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
    assert(_circles[circle.id] == circle);
    assert(changes != null);
    await MapboxGlPlatform.instance.updateCircle(circle, changes);
    circle.options = circle.options.copyWith(changes);
    notifyListeners();
  }

  /// `circle.options.geometry` can't get real-time location.For example, when you
  /// set circle `draggable` is true,and you dragged circle.At this time you
  /// should use `getCircleLatLng()`
  Future<LatLng> getCircleLatLng(Circle circle) async {
    assert(circle != null);
    assert(_circles[circle.id] == circle);
    final circleLatLng =
        await MapboxGlPlatform.instance.getCircleLatLng(circle);
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
    assert(_circles[circle.id] == circle);
    await _removeCircle(circle.id);
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
    await MapboxGlPlatform.instance.removeCircle(id);

    _circles.remove(id);
  }

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, String filter) async {
    return MapboxGlPlatform.instance
        .queryRenderedFeatures(point, layerIds, filter);
  }

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String filter) async {
    return MapboxGlPlatform.instance
        .queryRenderedFeaturesInRect(rect, layerIds, filter);
  }

  Future invalidateAmbientCache() async {
    return MapboxGlPlatform.instance.invalidateAmbientCache();
  }

  /// Get last my location
  ///
  /// Return last latlng, nullable
  Future<LatLng> requestMyLocationLatLng() async {
    return MapboxGlPlatform.instance.requestMyLocationLatLng();
  }

  /// This method returns the boundaries of the region currently displayed in the map.
  Future<LatLngBounds> getVisibleRegion() async {
    return MapboxGlPlatform.instance.getVisibleRegion();
  }

  /// Adds an image to the style currently displayed in the map, so that it can later be referred to by the provided name.
  ///
  /// This allows you to add an image to the currently displayed style once, and from there on refer to it e.g. in the [Symbol.iconImage] anytime you add a [Symbol] later on.
  /// Set [sdf] to true if the image you add is an SDF image.
  /// Returns after the image has successfully been added to the style.
  /// Note: This can only be called after OnStyleLoadedCallback has been invoked and any added images will have to be re-added if a new style is loaded.
  ///
  /// Example: Adding an asset image and using it in a new symbol:
  /// ```dart
  /// Future<void> addImageFromAsset() async{
  ///   final ByteData bytes = await rootBundle.load("assets/someAssetImage.jpg");
  ///   final Uint8List list = bytes.buffer.asUint8List();
  ///   await controller.addImage("assetImage", list);
  ///   controller.addSymbol(
  ///    SymbolOptions(
  ///     geometry: LatLng(0,0),
  ///     iconImage: "assetImage",
  ///    ),
  ///   );
  /// }
  /// ```
  ///
  /// Example: Adding a network image (with the http package) and using it in a new symbol:
  /// ```dart
  /// Future<void> addImageFromUrl() async{
  ///  var response = await get("https://example.com/image.png");
  ///  await controller.addImage("testImage",  response.bodyBytes);
  ///  controller.addSymbol(
  ///   SymbolOptions(
  ///     geometry: LatLng(0,0),
  ///     iconImage: "testImage",
  ///   ),
  ///  );
  /// }
  /// ```
  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]) {
    return MapboxGlPlatform.instance.addImage(name, bytes, sdf);
  }
}
