import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';
import 'package:mapbox_gl/models/feature.dart';
import 'package:mapbox_gl/models/feature_collection.dart';
import 'package:mapbox_gl/models/geometry/geometry_line_string.dart';
import 'package:mapbox_gl/models/geometry/geometry_point.dart';
import 'package:mapbox_gl_example/page.dart';

class LayerPage extends ExamplePage {
  LayerPage() : super(const Icon(Icons.share), 'Layer');

  @override
  Widget build(BuildContext context) => LayerBody();
}

class LayerBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LayerState();
}

class LayerState extends State {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  static final geojson = FeatureCollection([
    Feature(GeometryLineString(
      [
        GeometryPoint(-33.87112820031405, 151.19213104248047),
        GeometryPoint(-33.853737857223145, 151.4770858764648),
      ],
    ))
  ]).toJson();

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
                  zoom: 11.0,
                ),
              ),
            ),
          ),
        ]);
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() async {
    controller.addSource("source_1", geojson);

    await controller.addLineLayer("source_1", "layer_1", {
      'line-dasharray': '["literal", [4, 5, 6, 2]]',
      'line-width': '''[
        "interpolate",
        ["linear"],
        ["zoom"], 
        5.0, 2.0, 
        23.0, 20.0,
        24.0, 25.0
      ]''',
    });
  }
}
