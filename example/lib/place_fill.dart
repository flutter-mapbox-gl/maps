// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

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

  MapboxMapController controller;
  int _fillCount = 0;
  Fill _selectedFill;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFillTapped.add(_onFillTapped);
  }

  @override
  void dispose() {
    controller?.onFillTapped?.remove(_onFillTapped);
    super.dispose();
  }

  void _onFillTapped(Fill fill) {
    // if (_selectedFill != null) {
    //   _updateSelectedFill(
    //     const FillOptions(fillRadius: 60),
    //   );
    // }
    setState(() {
      _selectedFill = fill;
    });
    // _updateSelectedFill(
    //   FillOptions(
    //     fillRadius: 30,
    //   ),
    // );
  }

  void _updateSelectedFill(FillOptions changes) {
    controller.updateFill(_selectedFill, changes);
  }

  void _add() {
    controller.addFill(
      FillOptions(
          geometry: LatLng(
            center.latitude + sin(_fillCount * pi / 6.0) / 20.0,
            center.longitude + cos(_fillCount * pi / 6.0) / 20.0,
          ),
          fillColor: "#FF0000"),
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
    final LatLng current = _selectedFill.options.geometry;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _updateSelectedFill(
      FillOptions(
        geometry: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeDraggable() {
    bool draggable = _selectedFill.options.draggable;
    if (draggable == null) {
      // default value
      draggable = false;
    }
    _updateSelectedFill(
      FillOptions(
        draggable: !draggable,
      ),
    );
  }

  void _changeFillStrokeOpacity() {
    //TODO: Implement fillStrokeOpacity.
    // double current = _selectedFill.options.fillStrokeOpacity;
    // if (current == null) {
    //   // default value
    //   current = 1.0;
    // }

    // _updateSelectedFill(
    //   FillOptions(fillStrokeOpacity: current < 0.1 ? 1.0 : current * 0.75),
    // );
  }

  void _changeFillStrokeWidth() {
    //TODO: Implement fillStrokeWidth
    // double current = _selectedFill.options.fillStrokeWidth;
    // if (current == null) {
    //   // default value
    //   current = 0;
    // }
    // _updateSelectedFill(FillOptions(fillStrokeWidth: current == 0 ? 5.0 : 0));
  }

  Future<void> _changeFillStrokeColor() async {
    //TODO: Implement fillStrokeColor
    // String current = _selectedFill.options.fillStrokeColor;
    // if (current == null) {
    //   // default value
    //   current = "#FFFFFF";
    // }

    // _updateSelectedFill(
    //   FillOptions(fillStrokeColor: current == "#FFFFFF" ? "#FF0000" : "#FFFFFF"),
    // );
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

  Future<void> _changeFillRadius() async {
    // TODO: Implement fillRadius
    // double current = _selectedFill.options.fillRadius;
    // if (current == null) {
    //   // default value
    //   current = 0;
    // }
    // _updateSelectedFill(
    //   FillOptions(fillRadius: current == 120.0 ? 30.0 : current + 30.0),
    // );
  }

  Future<void> _changeFillColor() async {
    String current = _selectedFill.options.fillColor;
    if (current == null) {
      // default value
      current = "#FF0000";
    }

    _updateSelectedFill(
      FillOptions(
          fillColor: "#FFFF00"),
    );
  }

  Future<void> _changeFillBlur() async {
    // TODO: Implement fillBlur
    // double current = _selectedFill.options.fillBlur;
    // if (current == null) {
    //   // default value
    //   current = 0;
    // }
    // _updateSelectedFill(
    //   FillOptions(fillBlur: current == 0.75 ? 0 : 0.75),
    // );
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
                        FlatButton(
                          child: const Text('add'),
                          onPressed: (_fillCount == 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedFill == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change fill-opacity'),
                          onPressed:
                              (_selectedFill == null) ? null : _changeFillOpacity,
                        ),
                        FlatButton(
                          child: const Text('change fill-radius'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillRadius,
                        ),
                        FlatButton(
                          child: const Text('change fill-color'),
                          onPressed:
                          (_selectedFill == null) ? null : _changeFillColor,
                        ),
                        FlatButton(
                          child: const Text('change fill-blur'),
                          onPressed:
                          (_selectedFill == null) ? null : _changeFillBlur,
                        ),
                        FlatButton(
                          child: const Text('change fill-stroke-width'),
                          onPressed:
                              (_selectedFill == null) ? null : _changeFillStrokeWidth,
                        ),
                        FlatButton(
                          child: const Text('change fill-stroke-color'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillStrokeColor,
                        ),
                        FlatButton(
                          child: const Text('change fill-stroke-opacity'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeFillStrokeOpacity,
                        ),
                        FlatButton(
                          child: const Text('change position'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changePosition,
                        ),
                        FlatButton(
                          child: const Text('toggle draggable'),
                          onPressed: (_selectedFill == null)
                              ? null
                              : _changeDraggable,
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