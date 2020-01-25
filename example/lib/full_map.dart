import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'page.dart';

class FullMapPage extends Page {
  FullMapPage()
      : super(const Icon(Icons.map), 'Full screen map');

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
  MapboxMapController mapController;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: MapboxMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition:
          const CameraPosition(target: LatLng(0.0, 0.0)),
        )
    );
  }
}
