import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';
import 'package:mapbox_gl/models/feature.dart';
import 'package:mapbox_gl/models/feature_collection.dart';
import 'package:mapbox_gl/models/geometry/line_string.dart';
import 'package:mapbox_gl/models/geometry/point.dart';
import 'package:mapbox_gl/models/geometry/polygon.dart';
import 'package:mapbox_gl_example/page.dart';

class PolygonPage extends ExamplePage {
  PolygonPage() : super(const Icon(Icons.video_stable), 'Polygon');

  @override
  Widget build(BuildContext context) => LayerBody();
}

class LayerBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LayerState();
}

class LayerState extends State {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  final polygon = GeometryPolygon([
    [
      GeometryPoint(-33.863737857223145, 151.19213104248047),
      GeometryPoint(-33.863737857223145, 151.20213104248047),
      GeometryPoint(-33.873737857223145, 151.20213104248047),
      GeometryPoint(-33.873737857223145, 151.19213104248047),
      GeometryPoint(-33.863737857223145, 151.19213104248047),
    ],
  ]);

  FeatureCollection polygonCollection;

  MapboxMapController controller;

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
    var stripeResponse = await get(Uri.parse(
        'https://i.pinimg.com/originals/b8/10/a9/b810a96181bf310343954b86397eba69.jpg'));
    await controller.addImage('stripe', stripeResponse.bodyBytes);

    polygonCollection = FeatureCollection([Feature(polygon)]);

    await controller.addSource("source_1", polygonCollection.toJson());
    await controller.addFillLayer(
        "source_1",
        "layer_1",
        {
          // 'fill-pattern': '["image", "stripe"]',
          'fill-color':
              '["rgb", ["number", 0], ["number", 255], ["number", 255]]',
          'fill-opacity': '["number", 0.5]',
          'fill-outline-color':
              '["rgb", ["number", 0], ["number", 100], ["number", 0]]'
        },
        filter: '[">", "zoom", ["literal","14"]]');
  }

  _onMapClick(Point<double> point, LatLng latlng) {
    // remove the last point(copy of first)
    polygon.coordinates.first.removeAt(polygon.coordinates.first.length - 1);
    // add new point
    polygon.coordinates.first
        .add(GeometryPoint(latlng.latitude, latlng.longitude));
    // add back the last point
    polygon.coordinates.first.add(polygon.coordinates.first.first);

    // update the source while the map is running
    controller.addSourceFeatures("source_1", polygonCollection.toJson());
  }
}
