// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class PlaceNeoRangesPage extends ExamplePage {
  PlaceNeoRangesPage() : super(const Icon(Icons.check_circle), 'Place circle');

  @override
  Widget build(BuildContext context) {
    return const PlaceNeoRangeBody();
  }
}

class PlaceNeoRangeBody extends StatefulWidget {
  const PlaceNeoRangeBody();

  @override
  State<StatefulWidget> createState() => PlaceNeoRangeBodyState();
}

class PlaceNeoRangeBodyState extends State<PlaceNeoRangeBody> {
  PlaceNeoRangeBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  static final NeoRanges neoRanges = NeoRanges(
    visionRangeRadius: 400,
    adRangeRadius: 300,
    actionRangeRadius: 200,
    visionRangeCircleOptions: CircleOptions(
      geometry: center,
      circleOpacity: 0,
      circleStrokeColor: "#2AA2D2",
      circleStrokeWidth: 25,
    ),
    actionRangeCircleOptions: CircleOptions(
      geometry: center,
      circleOpacity: 0.5,
      circleColor: "#2AA2D2",
      circleStrokeColor: "#FFFFFF",
      circleStrokeWidth: 20,
    ),
    adRangeCircleOptions: CircleOptions(
      geometry: center,
      circleOpacity: 0.15,
      circleColor: "#2AA2D2",
      circleStrokeColor: "#FFFFFF",
      circleStrokeWidth: 15,
    ),
  );

  MapboxMapController controller;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateNeoRanges() {
    controller.updateNeoRanges(neoRanges);
    controller.addCircle(
      CircleOptions(circleColor: "#FFFFFF", circleRadius: 5, geometry: center),
    );
    controller.addCircle(
      CircleOptions(
        circleColor: "#FF0000",
        circleRadius: 3,
        geometry: LatLng(
          -33.86891,
          151.1947171,
        ),
      ),
    );
    controller.addCircle(
      CircleOptions(
        circleColor: "#FF0000",
        circleRadius: 3,
        geometry: LatLng(
          -33.86981,
          151.1947171,
        ),
      ),
    );
    controller.addCircle(
      CircleOptions(
        circleColor: "#FF0000",
        circleRadius: 3,
        geometry: LatLng(
          -33.87071,
          151.1947171,
        ),
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
                          child: const Text('Update NeoRanges'),
                          onPressed: () => _updateNeoRanges(),
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
