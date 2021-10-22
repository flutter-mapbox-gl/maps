import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';
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

  void _onStyleLoadedCallback() {
    controller.addGeoJsonSource("fills", _fills);
    controller.addGeoJsonSource("points", _points);

    controller.addFillLayer("fills", "fills", {
      FillProperties.fillColor: [
        'interpolate',
        ['exponential', 0.5],
        ['zoom'],
        11,
        'red',
        18,
        'green'
      ],
      FillProperties.fillOpacity: [
        'interpolate',
        ['exponential', 0.5],
        ['zoom'],
        11,
        0.5,
        18,
        0.5
      ],
    });

    controller.addLineLayer("fills", "lines", {
      LineProperties.lineWidth: [
        Expressions.interpolate,
        ["linear"],
        [Expressions.zoom],
        11.0,
        2.0,
        20.0,
        10.0
      ]
    });

    controller.addCircleLayer("fills", "circles", {
      CircleProperties.circleRadius: 4.0,
      CircleProperties.circleColor: "#ff0000"
    });

    controller.addSymbolLayer("points", "symbols", {
      SymbolProperties.iconImage: "{type}-15",
      SymbolProperties.iconSize: 2,
      SymbolProperties.iconAllowOverlap: true
    });
  }
}

final _fills = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [151.178099204457737, -33.901517742631846],
            [151.179025547977773, -33.872845324482071],
            [151.147000529140399, -33.868230472039514],
            [151.150838238009328, -33.883172899638311],
            [151.14223647675135, -33.894158309528244],
            [151.155999294764086, -33.904812805307806],
            [151.178099204457737, -33.901517742631846]
          ],
          [
            [151.162657925954278, -33.879168932438581],
            [151.155323416087612, -33.890737666431583],
            [151.173659690754278, -33.897637567778119],
            [151.162657925954278, -33.879168932438581]
          ]
        ]
      }
    },
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [151.18735077583878, -33.891143558434102],
            [151.197374605989864, -33.878357032551868],
            [151.213021560372084, -33.886475683791488],
            [151.204953599518745, -33.899463918807818],
            [151.18735077583878, -33.891143558434102]
          ]
        ]
      }
    }
  ]
};

final _points = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "type": "restaurant",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.184913929732943, -33.874874486427181]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "type": "airport",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.215730044667879, -33.874616048776858]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "type": "bakery",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.228803547973598, -33.892188026142584]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "type": "college",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.186470299174118, -33.902781145804774]
      }
    }
  ]
};
