// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';

import 'page.dart';

class PlaceFillPage extends ExamplePage {
  PlaceFillPage() : super(const Icon(Icons.check_circle), 'Place fill');

  @override
  Widget build(BuildContext context) {
    return const PlaceFillBody();
  }
}

class PlaceFillBody extends StatefulWidget {
  const PlaceFillBody();

  @override
  State<StatefulWidget> createState() => PlaceFillBodyState();
}

class PlaceFillBodyState extends State<PlaceFillBody> {
  PlaceFillBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);
  final String _fillPatternImage = "assets/fill/cat_silhouette_pattern.png";

  MapboxMapController controller;
  int _fillCount = 0;
  Fill _selectedFill;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFillTapped.add(_onFillTapped);
  }

  void _onStyleLoaded() {
    addImageFromAsset("assetImage", _fillPatternImage);
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  @override
  void dispose() {
    controller?.onFillTapped?.remove(_onFillTapped);
    super.dispose();
  }

  void _onFillTapped(Fill fill) {
    setState(() {
      _selectedFill = fill;
    });
  }

  void _updateSelectedFill(FillOptions changes) {
    controller.updateFill(_selectedFill, changes);
  }

  void _add() {
    controller.addFill(
      FillOptions(geometry: [
        [
          LatLng(-33.719, 151.150),
          LatLng(-33.858, 151.150),
          LatLng(-33.866, 151.401),
          LatLng(-33.747, 151.328),
          LatLng(-33.719, 151.150),
        ],
        [
          LatLng(-33.762, 151.250),
          LatLng(-33.827, 151.250),
          LatLng(-33.833, 151.347),
          LatLng(-33.762, 151.250),
        ]
      ], fillColor: "#FF0000", fillOutlineColor: "#FF0000"),
    );
    setState(() {
      _fillCount += 1;
    });
  }

  void _remove() {
    controller.removeFill(_selectedFill);
    setState(() {
      _selectedFill = null;
      _fillCount -= 1;
    });
  }

  void _changePosition() {
    //TODO: Implement change position.
  }

  void _changeDraggable() {
    bool draggable = _selectedFill.options.draggable;
    if (draggable == null) {
      // default value
      draggable = false;
    }
    _updateSelectedFill(
      FillOptions(draggable: !draggable),
    );
  }

  Future<void> _changeFillOpacity() async {
    double current = _selectedFill.options.fillOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedFill(
      FillOptions(fillOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeFillColor() async {
    String current = _selectedFill.options.fillColor;
    if (current == null) {
      // default value
      current = "#FF0000";
    }

    _updateSelectedFill(
      FillOptions(fillColor: "#FFFF00"),
    );
  }

  Future<void> _changeFillOutlineColor() async {
    String current = _selectedFill.options.fillOutlineColor;
    if (current == null) {
      // default value
      current = "#FF0000";
    }

    _updateSelectedFill(
      FillOptions(fillOutlineColor: "#FFFF00"),
    );
  }

  Future<void> _changeFillPattern() async {
    String current =
        _selectedFill.options.fillPattern == null ? "assetImage" : null;
    _updateSelectedFill(
      FillOptions(fillPattern: current),
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
              onStyleLoadedCallback: _onStyleLoaded,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 7.0,
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
                          onPressed: (_fillCount == 12) ? null : _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (_selectedFill == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change fill-opacity'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillOpacity,
                        ),
                        TextButton(
                          child: const Text('change fill-color'),
                          onPressed:
                              (_selectedFill == null) ? null : _changeFillColor,
                        ),
                        TextButton(
                          child: const Text('change fill-outline-color'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillOutlineColor,
                        ),
                        TextButton(
                          child: const Text('change fill-pattern'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillPattern,
                        ),
                        TextButton(
                          child: const Text('change position'),
                          onPressed:
                              (_selectedFill == null) ? null : _changePosition,
                        ),
                        TextButton(
                          child: const Text('toggle draggable'),
                          onPressed:
                              (_selectedFill == null) ? null : _changeDraggable,
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
