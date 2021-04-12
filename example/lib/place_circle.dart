// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class PlaceCirclePage extends ExamplePage {
  PlaceCirclePage() : super(const Icon(Icons.check_circle), 'Place circle');

  @override
  Widget build(BuildContext context) {
    return const PlaceCircleBody();
  }
}

class PlaceCircleBody extends StatefulWidget {
  const PlaceCircleBody();

  @override
  State<StatefulWidget> createState() => PlaceCircleBodyState();
}

class PlaceCircleBodyState extends State<PlaceCircleBody> {
  PlaceCircleBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  MapboxMapController controller;
  int _circleCount = 0;
  Circle _selectedCircle;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onCircleTapped.add(_onCircleTapped);
  }

  @override
  void dispose() {
    controller?.onCircleTapped?.remove(_onCircleTapped);
    super.dispose();
  }

  void _onCircleTapped(Circle circle) {
    if (_selectedCircle != null) {
      _updateSelectedCircle(
        const CircleOptions(circleRadius: 60),
      );
    }
    setState(() {
      _selectedCircle = circle;
    });
    _updateSelectedCircle(
      CircleOptions(
        circleRadius: 30,
      ),
    );
  }

  void _updateSelectedCircle(CircleOptions changes) {
    controller.updateCircle(_selectedCircle, changes);
  }

  void _add() {
    controller.addCircle(
      CircleOptions(
          geometry: LatLng(
            center.latitude + sin(_circleCount * pi / 6.0) / 20.0,
            center.longitude + cos(_circleCount * pi / 6.0) / 20.0,
          ),
          circleColor: "#FF0000"),
    );
    setState(() {
      _circleCount += 1;
    });
  }

  void _remove() {
    controller.removeCircle(_selectedCircle);
    setState(() {
      _selectedCircle = null;
      _circleCount -= 1;
    });
  }

  void _changePosition() {
    final LatLng current = _selectedCircle.options.geometry;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _updateSelectedCircle(
      CircleOptions(
        geometry: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeDraggable() {
    bool draggable = _selectedCircle.options.draggable;
    if (draggable == null) {
      // default value
      draggable = false;
    }
    _updateSelectedCircle(
      CircleOptions(
        draggable: !draggable,
      ),
    );
  }

  void _getLatLng() async {
    LatLng latLng = await controller.getCircleLatLng(_selectedCircle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(latLng.toString()),
      ),
    );
  }

  void _changeCircleStrokeOpacity() {
    double current = _selectedCircle.options.circleStrokeOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedCircle(
      CircleOptions(circleStrokeOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  void _changeCircleStrokeWidth() {
    double current = _selectedCircle.options.circleStrokeWidth;
    if (current == null) {
      // default value
      current = 0;
    }
    _updateSelectedCircle(
        CircleOptions(circleStrokeWidth: current == 0 ? 5.0 : 0));
  }

  Future<void> _changeCircleStrokeColor() async {
    String current = _selectedCircle.options.circleStrokeColor;
    if (current == null) {
      // default value
      current = "#FFFFFF";
    }

    _updateSelectedCircle(
      CircleOptions(
          circleStrokeColor: current == "#FFFFFF" ? "#FF0000" : "#FFFFFF"),
    );
  }

  Future<void> _changeCircleOpacity() async {
    double current = _selectedCircle.options.circleOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedCircle(
      CircleOptions(circleOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeCircleRadius() async {
    double current = _selectedCircle.options.circleRadius;
    if (current == null) {
      // default value
      current = 0;
    }
    _updateSelectedCircle(
      CircleOptions(circleRadius: current == 120.0 ? 30.0 : current + 30.0),
    );
  }

  Future<void> _changeCircleColor() async {
    String current = _selectedCircle.options.circleColor;
    if (current == null) {
      // default value
      current = "#FF0000";
    }

    _updateSelectedCircle(
      CircleOptions(circleColor: "#FFFF00"),
    );
  }

  Future<void> _changeCircleBlur() async {
    double current = _selectedCircle.options.circleBlur;
    if (current == null) {
      // default value
      current = 0;
    }
    _updateSelectedCircle(
      CircleOptions(circleBlur: current == 0.75 ? 0 : 0.75),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: MapboxMap(
              accessToken: MapsDemo.ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add'),
                          onPressed: (_circleCount == 12) ? null : _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (_selectedCircle == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change circle-opacity'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleOpacity,
                        ),
                        TextButton(
                          child: const Text('change circle-radius'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleRadius,
                        ),
                        TextButton(
                          child: const Text('change circle-color'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleColor,
                        ),
                        TextButton(
                          child: const Text('change circle-blur'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleBlur,
                        ),
                        TextButton(
                          child: const Text('change circle-stroke-width'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleStrokeWidth,
                        ),
                        TextButton(
                          child: const Text('change circle-stroke-color'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleStrokeColor,
                        ),
                        TextButton(
                          child: const Text('change circle-stroke-opacity'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeCircleStrokeOpacity,
                        ),
                        TextButton(
                          child: const Text('change position'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changePosition,
                        ),
                        TextButton(
                          child: const Text('toggle draggable'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeDraggable,
                        ),
                        TextButton(
                          child: const Text('get current LatLng'),
                          onPressed:
                              (_selectedCircle == null) ? null : _getLatLng,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
