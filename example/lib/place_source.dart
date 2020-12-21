// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class PlaceSourcePage extends ExamplePage {
  PlaceSourcePage() : super(const Icon(Icons.place), 'Place source');

  @override
  Widget build(BuildContext context) {
    return const PlaceSymbolBody();
  }
}

class PlaceSymbolBody extends StatefulWidget {
  const PlaceSymbolBody();

  @override
  State<StatefulWidget> createState() => PlaceSymbolBodyState();
}

class PlaceSymbolBodyState extends State<PlaceSymbolBody> {
  PlaceSymbolBodyState();

  bool sourceAdded = false;
  MapboxMapController controller;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Adds an asset image as a source to the currently displayed style
  Future<void> addImageSourceFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImageSource(
        name,
        list,
        LatLngQuad(
          bottomRight: const LatLng(-33.86264728692581, 151.19916915893555),
          bottomLeft: const LatLng(-33.86264728692581, 151.2288236618042),
          topLeft: const LatLng(-33.84322353475214, 151.2288236618042),
          topRight: const LatLng(-33.84322353475214, 151.19916915893555),
        ));
  }

  Future<void> removeImageSource(String name){
    return controller.removeImageSource(name);
  }

  Future<void> addLayer(String layerName, String sourceId) {
    return controller.addLayer(layerName, sourceId);
  }

  Future<void> removeLayer(String layerName) {
    return controller.removeLayer(layerName);
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
                          child: const Text('Add source (asset image)'),
                          onPressed: sourceAdded ? null : () => addImageSourceFromAsset("sydney", "assets/sydney.png").then((value) => setState(() => sourceAdded = true)),
                        ),
                        FlatButton(
                          child: const Text('Remove source (asset image)'),
                          onPressed: sourceAdded ? () async {
                            await removeLayer("imageLayer");
                            removeImageSource("sydney").then((value) => setState(() => sourceAdded = false));
                          } : null,
                        ),
                        FlatButton(
                          child: const Text('Show layer'),
                          onPressed: sourceAdded ? () => addLayer("imageLayer", "sydney") : null,
                        ),
                        FlatButton(
                          child: const Text('Hide layer'),
                          onPressed: sourceAdded ? () => removeLayer("imageLayer") : null,
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
