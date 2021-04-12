import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'page.dart';

class LocalStylePage extends ExamplePage {
  LocalStylePage()
      : super(const Icon(Icons.map), 'Local style');

  @override
  Widget build(BuildContext context) {
    return const LocalStyle();
  }
}

class LocalStyle extends StatefulWidget {
  const LocalStyle();

  @override
  State createState() => LocalStyleState();
}

class LocalStyleState extends State<LocalStyle> {
  MapboxMapController mapController;
  String styleAbsoluteFilePath;

  @override
  initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((dir) async {
      String documentDir = dir.path;
      String stylesDir = '$documentDir/styles';
      String styleJSON = '{"version":8,"name":"Basic","constants":{},"sources":{"mapillary":{"type":"vector","tiles":["https://d25uarhxywzl1j.cloudfront.net/v0.1/{z}/{x}/{y}.mvt"],"attribution":"<a href=\\"https://www.mapillary.com\\" target=\\"_blank\\">© Mapillary, CC BY</a>","maxzoom":14}},"sprite":"","glyphs":"","layers":[{"id":"background","type":"background","paint":{"background-color":"rgba(135, 149, 154, 1)"}},{"id":"water","type":"fill","source":"mapbox","source-layer":"water","paint":{"fill-color":"rgba(108, 148, 120, 1)"}}]}';

      await new Directory(stylesDir).create(recursive: true);

      File styleFile = new File('$stylesDir/style.json');

      await styleFile.writeAsString(styleJSON);

      setState(() {
        styleAbsoluteFilePath = styleFile.path;
      });
    });
  }


  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (styleAbsoluteFilePath == null) {
      return Scaffold(
        body: Center(child: Text('Creating local style file...')),
      );
    }

    return new Scaffold(
      body: MapboxMap(
        accessToken: MapsDemo.ACCESS_TOKEN,
        styleString: styleAbsoluteFilePath,
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
        onStyleLoadedCallback: onStyleLoadedCallback,
      )
    );
  }

  void onStyleLoadedCallback() {}
}
