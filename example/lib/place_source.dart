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

  static const SOURCE_ID = 'sydney_source';
  static const LAYER_ID = 'sydney_layer';

  bool sourceAdded = false;
  late MapboxMapController controller;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Adds an asset image as a source to the currently displayed style
  Future<void> addImageSourceFromAsset(
      String imageSourceId, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImageSource(
      imageSourceId,
      list,
      const LatLngQuad(
        bottomRight: LatLng(-33.86264728692581, 151.19916915893555),
        bottomLeft: LatLng(-33.86264728692581, 151.2288236618042),
        topLeft: LatLng(-33.84322353475214, 151.2288236618042),
        topRight: LatLng(-33.84322353475214, 151.19916915893555),
      ),
    );
  }

  Future<void> removeImageSource(String imageSourceId) {
    return controller.removeImageSource(imageSourceId);
  }

  Future<void> addLayer(String imageLayerId, String imageSourceId) {
    return controller.addLayer(imageLayerId, imageSourceId);
  }

  Future<void> addLayerBelow(
      String imageLayerId, String imageSourceId, String belowLayerId) {
    return controller.addLayerBelow(imageLayerId, imageSourceId, belowLayerId);
  }

  Future<void> removeLayer(String imageLayerId) {
    return controller.removeLayer(imageLayerId);
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
                          child: const Text('Add source (asset image)'),
                          onPressed: sourceAdded
                              ? null
                              : () {
                                  addImageSourceFromAsset(
                                          SOURCE_ID, 'assets/sydney.png')
                                      .then((value) {
                                    setState(() => sourceAdded = true);
                                  });
                                },
                        ),
                        TextButton(
                          child: const Text('Remove source (asset image)'),
                          onPressed: sourceAdded
                              ? () async {
                                  await removeLayer(LAYER_ID);
                                  removeImageSource(SOURCE_ID).then((value) {
                                    setState(() => sourceAdded = false);
                                  });
                                }
                              : null,
                        ),
                        TextButton(
                          child: const Text('Show layer'),
                          onPressed: sourceAdded
                              ? () => addLayer(LAYER_ID, SOURCE_ID)
                              : null,
                        ),
                        TextButton(
                          child: const Text('Show layer below water'),
                          onPressed: sourceAdded
                              ? () =>
                                  addLayerBelow(LAYER_ID, SOURCE_ID, 'water')
                              : null,
                        ),
                        TextButton(
                          child: const Text('Hide layer'),
                          onPressed:
                              sourceAdded ? () => removeLayer(LAYER_ID) : null,
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
