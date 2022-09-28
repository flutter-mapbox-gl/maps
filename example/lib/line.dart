// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  MapboxMapController? controller;
  int _lineCount = 0;
  Line? _selectedLine;
  final String _linePatternImage = "assets/fill/cat_silhouette_pattern.png";

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onLineTapped.add(_onLineTapped);
  }

  @override
  void dispose() {
    controller?.onLineTapped.remove(_onLineTapped);
    super.dispose();
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller!.addImage(name, list);
  }

  _onLineTapped(Line line) async {
    await _updateSelectedLine(
      LineOptions(lineColor: "#ff0000"),
    );
    setState(() {
      _selectedLine = line;
    });
    await _updateSelectedLine(
      LineOptions(lineColor: "#ffe100"),
    );
  }

  _updateSelectedLine(LineOptions changes) async {
    if (_selectedLine != null) controller!.updateLine(_selectedLine!, changes);
  }

  void _add() {
    controller!.addLine(
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

  _move() async {
    final currentStart = _selectedLine!.options.geometry![0];
    final currentEnd = _selectedLine!.options.geometry![1];
    final end =
        LatLng(currentEnd.latitude + 0.001, currentEnd.longitude + 0.001);
    final start =
        LatLng(currentStart.latitude - 0.001, currentStart.longitude - 0.001);
    await controller!
        .updateLine(_selectedLine!, LineOptions(geometry: [start, end]));
  }

  void _remove() {
    controller!.removeLine(_selectedLine!);
    setState(() {
      _selectedLine = null;
      _lineCount -= 1;
    });
  }

  Future<void> _changeLinePattern() async {
    String? current =
        _selectedLine!.options.linePattern == null ? "assetImage" : null;
    await _updateSelectedLine(
      LineOptions(linePattern: current),
    );
  }

  Future<void> _changeAlpha() async {
    double? current = _selectedLine!.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    await _updateSelectedLine(
      LineOptions(lineOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _toggleVisible() async {
    double? current = _selectedLine!.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }
    await _updateSelectedLine(
      LineOptions(lineOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  _onStyleLoadedCallback() async {
    addImageFromAsset("assetImage", _linePatternImage);
    await controller!.addLine(
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
            height: 400.0,
            child: MapboxMap(
              accessToken: MapsDemo.ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
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
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add'),
                          onPressed: (_lineCount == 12) ? null : _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (_selectedLine == null) ? null : _remove,
                        ),
                        TextButton(
                          child: const Text('move'),
                          onPressed: (_selectedLine == null)
                              ? null
                              : () async {
                                  await _move();
                                },
                        ),
                        TextButton(
                          child: const Text('change line-pattern'),
                          onPressed: (_selectedLine == null)
                              ? null
                              : _changeLinePattern,
                        ),
                      ],
                    ),
                    Row(
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
                                  var latLngs = await controller!
                                      .getLineLatLngs(_selectedLine!);
                                  for (var latLng in latLngs) {
                                    print(latLng.toString());
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
