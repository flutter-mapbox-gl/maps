// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class LinePage extends ExamplePage {
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
          lineWidth: 28.0,
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
          ],
          lineColor: "#ff0000",
          lineWidth: 14.0,
          lineOpacity: 0.5,
          draggable: true),
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

  Future<void> _changeAlpha() async {
    double current = _selectedLine.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedLine(
      LineOptions(lineOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _toggleVisible() async {
    double current = _selectedLine.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }
    _updateSelectedLine(
      LineOptions(lineOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  void onStyleLoadedCallback() {
    controller.addLine(
      LineOptions(
        geometry: [LatLng(37.4220, -122.0841), LatLng(37.4240, -122.0941)],
        lineColor: "#ff0000",
        lineWidth: 14.0,
        lineOpacity: 0.5,
      ),
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
              onStyleLoadedCallback: onStyleLoadedCallback,
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
                          onPressed: (_lineCount == 12) ? null : _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (_selectedLine == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change alpha'),
                          onPressed:
                              (_selectedLine == null) ? null : _changeAlpha,
                        ),
                        TextButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (_selectedLine == null) ? null : _toggleVisible,
                        ),
                        TextButton(
                          child: const Text('print current LatLng'),
                          onPressed: (_selectedLine == null)
                              ? null
                              : () async {
                                  var latLngs = await controller
                                      .getLineLatLngs(_selectedLine);
                                  for (var latLng in latLngs) {
                                    print(latLng.toString());
                                  }
                                },
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
