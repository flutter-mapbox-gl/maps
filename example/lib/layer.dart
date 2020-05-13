import 'package:flutter/material.dart';
import 'package:mapbox_gl_example/page.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class LayerPage extends Page {

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
  static final String geojson = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [
            151.19213104248047,
            -33.87112820031405
          ],
          [
            151.21770858764648,
            -33.853737857223145
          ]
        ]
      }
    }
  ]
}
      ''';

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
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              initialCameraPosition: CameraPosition(
                target: center,
                zoom: 11.0,
              ),
            ),
          ),
        ),
      ]
    );
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() {
    controller.addSource("source_1", geojson);
    controller.addLineLayer("source_1", "layer_1", {
      'line-color': "[\"rgb\", 171, 72, 33]",
      'line-width': "[\"to-number\", 5]"
    });
  }
}