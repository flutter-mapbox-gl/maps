import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // ignore: unnecessary_import
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

const randomMarkerNum = 100;

class CustomMarkerPage extends ExamplePage {
  CustomMarkerPage() : super(const Icon(Icons.place), 'Custom marker');

  @override
  Widget build(BuildContext context) {
    return CustomMarker();
  }
}

class CustomMarker extends StatefulWidget {
  const CustomMarker();

  @override
  State createState() => CustomMarkerState();
}

class CustomMarkerState extends State<CustomMarker> {
  final Random _rnd = new Random();

  late MapboxMapController _mapController;
  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

  void _onMapLongClickCallback(Point<double> point, LatLng coordinates) {
    _addMarker(point, coordinates);
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    _mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    setState(() {
      _markers.add(Marker(_rnd.nextInt(100000).toString(), coordinates, point,
          _addMarkerStates));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(children: [
        MapboxMap(
          accessToken: MapsDemo.ACCESS_TOKEN,
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapLongClick: _onMapLongClickCallback,
          onCameraIdle: _onCameraIdleCallback,
          onStyleLoadedCallback: _onStyleLoadedCallback,
          initialCameraPosition:
              const CameraPosition(target: LatLng(35.0, 135.0), zoom: 5),
        ),
        IgnorePointer(
            ignoring: true,
            child: Stack(
              children: _markers,
            ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //_measurePerformance();

          // Generate random markers
          var param = <LatLng>[];
          for (var i = 0; i < randomMarkerNum; i++) {
            final lat = _rnd.nextDouble() * 20 + 30;
            final lng = _rnd.nextDouble() * 20 + 125;
            param.add(LatLng(lat, lng));
          }

          _mapController.toScreenLocationBatch(param).then((value) {
            for (var i = 0; i < randomMarkerNum; i++) {
              var point =
                  Point<double>(value[i].x as double, value[i].y as double);
              _addMarker(point, param[i]);
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // ignore: unused_element
  void _measurePerformance() {
    final trial = 10;
    final batches = [500, 1000, 1500, 2000, 2500, 3000];
    var results = Map<int, List<double>>();
    for (final batch in batches) {
      results[batch] = [0.0, 0.0];
    }

    _mapController.toScreenLocation(LatLng(0, 0));
    Stopwatch sw = Stopwatch();

    for (final batch in batches) {
      //
      // primitive
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var list = <Future<Point<num>>>[];
        for (var j = 0; j < batch; j++) {
          var p = _mapController
              .toScreenLocation(LatLng(j.toDouble() % 80, j.toDouble() % 300));
          list.add(p);
        }
        Future.wait(list);
        sw.stop();
        results[batch]![0] += sw.elapsedMilliseconds;
        sw.reset();
      }

      //
      // batch
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var param = <LatLng>[];
        for (var j = 0; j < batch; j++) {
          param.add(LatLng(j.toDouble() % 80, j.toDouble() % 300));
        }
        Future.wait([_mapController.toScreenLocationBatch(param)]);
        sw.stop();
        results[batch]![1] += sw.elapsedMilliseconds;
        sw.reset();
      }

      print(
          'batch=$batch,primitive=${results[batch]![0] / trial}ms, batch=${results[batch]![1] / trial}ms');
    }
  }
}

class Marker extends StatefulWidget {
  final Point _initialPosition;
  final LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;

  Marker(
      String key, this._coordinate, this._initialPosition, this._addMarkerState)
      : super(key: Key(key));

  @override
  State<StatefulWidget> createState() {
    final state = _MarkerState(_initialPosition);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final _iconSize = 20.0;

  Point _position;

  late AnimationController _controller;
  late Animation<double> _animation;

  _MarkerState(this._position);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
        left: _position.x / ratio - _iconSize / 2,
        top: _position.y / ratio - _iconSize / 2,
        child: RotationTransition(
            turns: _animation,
            child: Image.asset('assets/symbols/2.0x/custom-icon.png',
                height: _iconSize)));
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
