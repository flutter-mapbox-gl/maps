import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/models/feature.dart';
import 'package:mapbox_gl/models/feature_collection.dart';
import 'package:mapbox_gl/models/geometry/geometry_point.dart';
import 'package:mapbox_gl_example/main.dart';
import 'package:mapbox_gl_example/page.dart';

class DynamicSymbolsPage extends ExamplePage {
  DynamicSymbolsPage() : super(const Icon(Icons.place), 'Dynamic Symbols');

  @override
  Widget build(BuildContext context) => LayerBody();
}

class LayerBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LayerState();
}

class LayerState extends State {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);
  static const String CUSTOM_SYMBOL_SOURCE = 'my-custom-symbol-source';

  final FeatureCollection featureCollection = FeatureCollection([
    Feature(
      GeometryPoint(
        -33.87112820031405,
        151.19213104248047,
      ),
      properties: {"image-name": "cat"},
    ),
    Feature(
      GeometryPoint(
        -33.86112820031405,
        151.19213104248047,
      ),
      properties: {"image-name": "dog"},
    )
  ]);

  late MapboxMapController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 300.0,
              height: 500.0,
              child: MapboxMap(
                accessToken: MapsDemo.ACCESS_TOKEN,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 13.0,
                ),
                onMapClick: _onMapClick,
              ),
            ),
          ),
        ]);
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() async {
    // add some images to mapbox
    var response = await get(Uri.parse(
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/201408_cat.png'));
    await controller.addImage('cat', response.bodyBytes);
    var dogresponse = await get(Uri.parse(
        'https://upload.wikimedia.org/wikipedia/commons/1/1e/201412_dog.png'));
    await controller.addImage('dog', dogresponse.bodyBytes);

    // add source before adding a layer
    // await controller.addSource(
    //     CUSTOM_SYMBOL_SOURCE, featureCollection.toJson());

    // Sets the image according to the image-name property on the feature
    await controller
        .addSymbolLayerCustom(CUSTOM_SYMBOL_SOURCE, 'my-custom-symbol-layer', {
      'icon-size': '''[
        "interpolate",
        ["linear"],
        ["zoom"], 11.0, 0.2, 22.0, 1
      ]''',
      "icon-image": '["get", "image-name"]'
    });
  }

  _onMapClick(Point<double> point, LatLng latlng) {
    featureCollection.addFeature(Feature(
      GeometryPoint(latlng.latitude, latlng.longitude),
      properties: {'image-name': 'cat'},
    ));

    // update the source while the map is running
    controller.addSourceFeaturesCustom(
        CUSTOM_SYMBOL_SOURCE, featureCollection.toJson());
  }
}
