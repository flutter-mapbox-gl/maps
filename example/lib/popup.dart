import 'package:flutter/material.dart';
import 'package:mapbox_gl_example/main.dart';
import 'package:mapbox_gl_example/page.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class PopupPage extends ExamplePage {
  PopupPage() : super(const Icon(Icons.mouse), "Popup");

  @override
  Widget build(BuildContext context) {
    return PopupBody();
  }
}

class PopupBody extends StatefulWidget {
  const PopupBody({Key? key}) : super(key: key);

  @override
  State<PopupBody> createState() => _PopupBodyState();
}

class _PopupBodyState extends State<PopupBody> {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  late final MapboxMapController controller;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() async {
    await controller.addGeoJsonSource("points", _points);

    await controller.addSymbolLayer(
      "points",
      "symbols",
      SymbolLayerProperties(
        iconImage: "{type}-15",
        iconSize: 2,
        iconAllowOverlap: true,
      ),
    );

    controller.showPopupOnFeatureHover(
        layerId: "symbols",
        closeButton: false,
        loseButton: false,
        closeOnClick: false);
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: MapsDemo.ACCESS_TOKEN,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoadedCallback,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 11.0,
      ),
    );
  }
}

const _points = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": 2,
      "properties": {
        "description": "a good restaurant",
        "type": "restaurant",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.184913929732943, -33.874874486427181]
      }
    },
    {
      "type": "Feature",
      "id": 3,
      "properties": {
        "description": "<i>Sydney airport</i>",
        "type": "airport",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.215730044667879, -33.874616048776858]
      }
    },
    {
      "type": "Feature",
      "id": 4,
      "properties": {
        "description": "<h3>Go get croissants!</h3>",
        "type": "bakery",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.228803547973598, -33.892188026142584]
      }
    },
    {
      "type": "Feature",
      "id": 5,
      "properties": {
        "description": "The city college",
        "type": "college",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.186470299174118, -33.902781145804774]
      }
    }
  ]
};
