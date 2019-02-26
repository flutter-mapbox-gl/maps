// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'page.dart';

class LinePage extends Page {
  LinePage() : super(const Icon(Icons.share), 'Line');

  @override
  Widget build(BuildContext context) {
    return const LineBody();
  }
}

class LineBody extends StatefulWidget {
  const LineBody();

  @override
  State<StatefulWidget> createState() => LineBodyState();
}

class LineBodyState extends State<LineBody> {
  LineBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  MapboxMapController controller;
  int _lineCount = 0;
  Line _selectedLine;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onLineTapped.add(_onLineTapped);
  }

  @override
  void dispose() {
    controller?.onLineTapped?.remove(_onLineTapped);
    super.dispose();
  }

  void _onLineTapped(Line line) {
    if (_selectedLine != null) {
      _updateSelectedLine(
        const LineOptions(
            //linecolor:
            ),
      );
    }
    setState(() {
      _selectedLine = line;
    });
    _updateSelectedLine(
      LineOptions(
          // linecolor: ,
          ),
    );
  }

  void _updateSelectedLine(LineOptions changes) {
    controller.updateLine(_selectedLine, changes);
  }

  void _add() {
    controller.addLine(
      LineOptions(
          geometry: [
        LatLng(-33.86711, 151.1947171),
        LatLng(-33.86711, 151.1947171),
        LatLng(-32.86711, 151.1947171),
        LatLng(-33.86711, 152.1947171),
      ]),
    );
    setState(() {
      _lineCount += 1;
    });
  }

  void _remove() {
    controller.removeLine(_selectedLine);
    setState(() {
      _selectedLine = null;
      _lineCount -= 1;
    });
  }

  // void _changePosition() {
  //   final LatLng current = _selectedLine.options.geometry;
  //   final Offset offset = Offset(
  //     center.latitude - current.latitude,
  //     center.longitude - current.longitude,
  //   );
  //   _updateSelectedLine(
  //     LineOptions(
  //       geometry: LatLng(
  //         center.latitude + offset.dy,
  //         center.longitude + offset.dx,
  //       ),
  //     ),
  //   );
  // }

  // void _changeAnchor() {
  //   Offset currentAnchor = _selectedLine.options.iconOffset;
  //   if (currentAnchor == null) {
  //     // default value
  //     currentAnchor = Offset(0.0, 0.0);
  //   }
  //   final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
  //   _updateSelectedLine(LineOptions(iconOffset: newAnchor));
  // }

  // Future<void> _toggleDraggable() async {
  //   bool draggable = _selectedLine.options.draggable;
  //   if (draggable == null) {
  //     // default value
  //     draggable = false;
  //   }

  //   _updateSelectedLine(
  //     LineOptions(draggable: !draggable),
  //   );
  // }

  // Future<void> _changeAlpha() async {
  //   double current = _selectedLine.options.iconOpacity;
  //   if (current == null) {
  //     // default value
  //     current = 1.0;
  //   }

  //   _updateSelectedLine(
  //     LineOptions(iconOpacity: current < 0.1 ? 1.0 : current * 0.75),
  //   );
  // }

  // Future<void> _changeRotation() async {
  //   double current = _selectedLine.options.iconRotate;
  //   if (current == null) {
  //     // default value
  //     current = 0;
  //   }
  //   _updateSelectedLine(
  //     LineOptions(iconRotate: current == 330.0 ? 0.0 : current + 30.0),
  //   );
  // }

  // Future<void> _toggleVisible() async {
  //   double current = _selectedLine.options.iconOpacity;
  //   if (current == null) {
  //     // default value
  //     current = 1.0;
  //   }

  //   _updateSelectedLine(
  //     LineOptions(iconOpacity: current == 0.0 ? 1.0 : 0.0),
  //   );
  // }

  // Future<void> _changeZIndex() async {
  //   int current = _selectedLine.options.zIndex;
  //   if (current == null) {
  //     // default value
  //     current = 0;
  //   }
  //   _updateSelectedLine(
  //     LineOptions(zIndex: current == 12 ? 0 : current + 1),
  //   );
  // }

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
                          onPressed: (_lineCount == 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedLine == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // FlatButton(
                        //   child: const Text('change alpha'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _changeAlpha,
                        // ),
                        // FlatButton(
                        //   child: const Text('change anchor'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _changeAnchor,
                        // ),
                        // FlatButton(
                        //   child: const Text('toggle draggable'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _toggleDraggable,
                        // ),
                        // FlatButton(
                        //   child: const Text('change position'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _changePosition,
                        // ),
                        // FlatButton(
                        //   child: const Text('change rotation'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _changeRotation,
                        // ),
                        // FlatButton(
                        //   child: const Text('toggle visible'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _toggleVisible,
                        // ),
                        // FlatButton(
                        //   child: const Text('change zIndex'),
                        //   onPressed:
                        //       (_selectedLine == null) ? null : _changeZIndex,
                        // ),
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
