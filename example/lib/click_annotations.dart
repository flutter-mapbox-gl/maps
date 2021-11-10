// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';

import 'page.dart';

class ClickAnnotationPage extends ExamplePage {
  ClickAnnotationPage()
      : super(const Icon(Icons.check_circle), 'Annotation tap');

  @override
  Widget build(BuildContext context) {
    return const ClickAnnotationBody();
  }
}

class ClickAnnotationBody extends StatefulWidget {
  const ClickAnnotationBody();

  @override
  State<StatefulWidget> createState() => ClickAnnotationBodyState();
}

class ClickAnnotationBodyState extends State<ClickAnnotationBody> {
  ClickAnnotationBodyState();
  static const LatLng center = const LatLng(-33.88, 151.16);

  MapboxMapController? controller;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFillTapped.add(_onFillTapped);
    controller.onCircleTapped.add(_onCircleTapped);
    controller.onLineTapped.add(_onLineTapped);
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  @override
  void dispose() {
    controller?.onFillTapped.remove(_onFillTapped);
    super.dispose();
  }

  _showSnackBar(String type, String id) {
    final snackBar = SnackBar(
        content: Text('Tapped $type $id',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onFillTapped(Fill fill) {
    _showSnackBar('fill', fill.id);
  }

  void _onCircleTapped(Circle circle) {
    _showSnackBar('circle', circle.id);
  }

  void _onLineTapped(Line line) {
    _showSnackBar('line', line.id);
  }

  void _onSymbolTapped(Symbol symbol) {
    _showSnackBar('symbol', symbol.id);
  }

  void _onStyleLoaded() {
    controller!.addCircle(
      CircleOptions(
        geometry: LatLng(-33.881979408447314, 151.171361438502117),
        circleStrokeColor: "#00FF00",
        circleStrokeWidth: 2,
        circleRadius: 16,
      ),
    );
    controller!.addCircle(
      CircleOptions(
        geometry: LatLng(-33.894372606072309, 151.17576679759523),
        circleStrokeColor: "#00FF00",
        circleStrokeWidth: 2,
        circleRadius: 30,
      ),
    );
    controller!.addSymbol(
      SymbolOptions(
          geometry: LatLng(-33.894372606072309, 151.17576679759523),
          iconImage: "fast-food-15",
          iconSize: 2),
    );
    controller!.addLine(
      LineOptions(
        geometry: [
          LatLng(-33.874867744475786, 151.170627211986584),
          LatLng(-33.881979408447314, 151.171361438502117),
          LatLng(-33.887058805548882, 151.175032571079726),
          LatLng(-33.894372606072309, 151.17576679759523),
          LatLng(-33.900060683994681, 151.15765587687909),
        ],
        lineColor: "#0000FF",
        lineWidth: 20,
      ),
    );

    controller!.addFill(
      FillOptions(
        geometry: [
          [
            LatLng(-33.901517742631846, 151.178099204457737),
            LatLng(-33.872845324482071, 151.179025547977773),
            LatLng(-33.868230472039514, 151.147000529140399),
            LatLng(-33.883172899638311, 151.150838238009328),
            LatLng(-33.894158309528244, 151.14223647675135),
            LatLng(-33.904812805307806, 151.155999294764086),
            LatLng(-33.901517742631846, 151.178099204457737),
          ],
        ],
        fillColor: "#FF0000",
        fillOutlineColor: "#000000",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: MapsDemo.ACCESS_TOKEN,
      annotationOrder: [
        AnnotationType.fill,
        AnnotationType.line,
        AnnotationType.circle,
        AnnotationType.symbol,
      ],
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      initialCameraPosition: const CameraPosition(
        target: center,
        zoom: 12.0,
      ),
    );
  }
}
