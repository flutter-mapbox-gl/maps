import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class StyleCombination {
  final String name;
  final String baseStyle;
  final Future<void> Function(MapboxMapController) addDetails;

  const StyleCombination(
      {required this.name, required this.baseStyle, required this.addDetails});
}

class Sources extends ExamplePage {
  Sources() : super(const Icon(Icons.map), 'Various Sources');

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
  final watercolorRasterId = "watercolorRaster";
  int selectedStyleId = 0;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  static Future<void> addWatercolor(MapboxMapController controller) async {
    await controller.addSource(
      "watercolor",
      RasterSource(
          tiles: [
            'https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg'
          ],
          tileSize: 256,
          attribution:
              'Map tiles by <a target="_top" rel="noopener" href="http://stamen.com">Stamen Design</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a target="_top" rel="noopener" href="http://openstreetmap.org">OpenStreetMap</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>'),
    );
    await controller.addLayer(
        "watercolor", "watercolor", RasterLayerProperties(rasterHueRotate: 20));
  }

  static Future<void> addEarthQuakes(MapboxMapController controller) async {
    await controller.addSource(
        "earthquakes",
        GeojsonSource(
            data:
                'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson',
            cluster: true,
            clusterMaxZoom: 14, // Max zoom to cluster points on
            clusterRadius:
                50 // Radius of each cluster when clustering points (defaults to 50)
            ));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-circles",
        CircleLayerProperties(circleColor: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          '#51bbd6',
          100,
          '#f1f075',
          750,
          '#f28cb1'
        ], circleRadius: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          20,
          100,
          30,
          750,
          40
        ]));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-count",
        SymbolLayerProperties(
          textField: '{point_count_abbreviated}',
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 12,
        ));
  }

  static Future<void> addContour(MapboxMapController controller) async {
    await controller.addSource(
        "terrain",
        VectorSource(
          url: "mapbox://mapbox.mapbox-terrain-v2",
        ));

    await controller.addLayer(
        "terrain",
        "earthquakes-circles",
        LineLayerProperties(
          lineColor: "#ff69b4",
          lineWidth: 1,
          lineCap: "round",
          lineJoin: "round",
        ),
        sourceLayer: "contour");
  }

  static const _stylesAndLoaders = [
    StyleCombination(
        name: "Contour", baseStyle: MapboxStyles.LIGHT, addDetails: addContour),
    StyleCombination(
        name: "Watercolor",
        baseStyle: MapboxStyles.EMPTY,
        addDetails: addWatercolor),
    StyleCombination(
        name: "Earthquakes",
        baseStyle: MapboxStyles.SATELLITE,
        addDetails: addEarthQuakes),
  ];

  _onStyleLoadedCallback() async {
    _stylesAndLoaders[selectedStyleId].addDetails(mapController!);
  }

  @override
  Widget build(BuildContext context) {
    final combo = _stylesAndLoaders[selectedStyleId];
    final nextName =
        _stylesAndLoaders[(selectedStyleId + 1) % _stylesAndLoaders.length]
            .name;
    return new Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton.extended(
            icon: Icon(Icons.swap_horiz),
            label: SizedBox(
                width: 120, child: Center(child: Text("To $nextName"))),
            onPressed: () => setState(
              () => selectedStyleId =
                  (selectedStyleId + 1) % _stylesAndLoaders.length,
            ),
          ),
        ),
        body: MapboxMap(
          styleString: combo.baseStyle,
          accessToken: MapsDemo.ACCESS_TOKEN,
          onMapCreated: _onMapCreated,
          initialCameraPosition:
              const CameraPosition(target: LatLng(33.5, -118.1), zoom: 9),
          onStyleLoadedCallback: _onStyleLoadedCallback,
        ));
  }
}
