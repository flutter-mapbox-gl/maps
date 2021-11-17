import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class FullMapPage extends ExamplePage {
  FullMapPage() : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController? mapController;
  var isLight = true;
  static const lightStyle = "mapbox://styles/mapbox/light-v10";
  static const darkStyle = "mapbox://styles/mapbox/dark-v10";

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton(
            child: Icon(Icons.swap_horiz),
            onPressed: () => setState(
              () => isLight = !isLight,
            ),
          ),
        ),
        body: MapboxMap(
          styleString: isLight ? lightStyle : darkStyle,
          accessToken: MapsDemo.ACCESS_TOKEN,
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          onStyleLoadedCallback: onStyleLoadedCallback,
        ));
  }

  void onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Style loaded :)"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
  }
}
