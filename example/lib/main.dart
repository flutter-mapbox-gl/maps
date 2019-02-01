import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

void main() => runApp(MaterialApp(home: MapboxExample()));

class MapboxExample extends StatefulWidget {
  @override
  MapboxExampleState createState() {
    return new MapboxExampleState();
  }
}

class MapboxExampleState extends State<MapboxExample> {
  MapViewController controller;

  void _onMapViewCreated(MapViewController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter MapView example')),
      body: Stack(children: [
        MapView(
          onMapViewCreated: _onMapViewCreated,
          onTap: (point, coords) async {
            List ls = await controller.queryRenderedFeatures(point, ['LayerName'], null);
            print("queryRenderedFeatures test $ls");
          },
        ),
        Column(
          children: [
            RaisedButton(
              child: Text('Show User Location'),
              onPressed: () async {
                //check permissions before this, or turn them on manually.
                controller.showUserLocation();
              },
            ),
            RaisedButton(
              child: Text('getStyle'),
              onPressed: () async {
                print(await controller.getStyleUrl());
              },
            ),
            RaisedButton(
              child: Text('setStyle'),
              onPressed: () async {
                controller.setStyleUrl("mapbox://styles/mapbox/satellite-v9");
              },
            ),
            RaisedButton(
              child: Text('at ease'),
              onPressed: () async {
                // controller.easeTo(Camera(target: LatLng(lat: 32, lng: 35), zoom: 12), 2000);
                controller.easeTo(Camera(target: LatLng(lat: 32, lng: 35)), 2000);
              },
            ),
            RaisedButton(
              child: Text('fly to'),
              onPressed: () async {
                controller.flyTo(Camera(target: LatLng(lat: 32, lng: 35)), 2000);
              },
            ),
            RaisedButton(
              child: Text('zoom only'),
              onPressed: () async {
                controller.zoom(10, 2000);
              },
            ),
          ],
        ),
      ]),
    );
  }
}
