import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // ignore: unnecessary_import
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class AnnotationOrderPage extends ExamplePage {
  AnnotationOrderPage()
      : super(const Icon(Icons.layers), 'Annotation order maps');

  @override
  Widget build(BuildContext context) => AnnotationOrderBody();
}

class AnnotationOrderBody extends StatefulWidget {
  AnnotationOrderBody();

  @override
  _AnnotationOrderBodyState createState() => _AnnotationOrderBodyState();
}

class _AnnotationOrderBodyState extends State<AnnotationOrderBody> {
  late MapboxMapController controllerOne;
  late MapboxMapController controllerTwo;

  final LatLng center = const LatLng(36.580664, 32.5563837);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                      'This map has polygones (fill) above all other anotations (default behavior)'),
                ),
                Center(
                  child: SizedBox(
                    width: 250.0,
                    height: 250.0,
                    child: MapboxMap(
                      accessToken: MapsDemo.ACCESS_TOKEN,
                      onMapCreated: onMapCreatedOne,
                      onStyleLoadedCallback: () => onStyleLoaded(controllerOne),
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 5.0,
                      ),
                      annotationOrder: const [
                        AnnotationType.line,
                        AnnotationType.symbol,
                        AnnotationType.circle,
                        AnnotationType.fill,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
                  child: Text(
                      'This map has polygones (fill) under all other anotations'),
                ),
                Center(
                  child: SizedBox(
                    width: 250.0,
                    height: 250.0,
                    child: MapboxMap(
                      accessToken: MapsDemo.ACCESS_TOKEN,
                      onMapCreated: onMapCreatedTwo,
                      onStyleLoadedCallback: () => onStyleLoaded(controllerTwo),
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 5.0,
                      ),
                      annotationOrder: const [
                        AnnotationType.fill,
                        AnnotationType.line,
                        AnnotationType.symbol,
                        AnnotationType.circle,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onMapCreatedOne(MapboxMapController controller) {
    this.controllerOne = controller;
  }

  void onMapCreatedTwo(MapboxMapController controller) {
    this.controllerTwo = controller;
  }

  void onStyleLoaded(MapboxMapController controller) {
    controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          center.latitude,
          center.longitude,
        ),
        iconImage: "airport-15",
      ),
    );
    controller.addLine(
      LineOptions(
        draggable: false,
        lineColor: "#ff0000",
        lineWidth: 7.0,
        lineOpacity: 1,
        geometry: [
          LatLng(35.3649902, 32.0593003),
          LatLng(34.9475098, 31.1187944),
          LatLng(36.7108154, 30.7040582),
          LatLng(37.6995850, 33.6512083),
          LatLng(35.8648682, 33.6969227),
          LatLng(35.3814697, 32.0546447),
        ],
      ),
    );
    controller.addFill(
      FillOptions(
        draggable: false,
        fillColor: "#008888",
        fillOpacity: 0.3,
        geometry: [
          [
            LatLng(35.3649902, 32.0593003),
            LatLng(34.9475098, 31.1187944),
            LatLng(36.7108154, 30.7040582),
            LatLng(37.6995850, 33.6512083),
            LatLng(35.8648682, 33.6969227),
            LatLng(35.3814697, 32.0546447),
          ]
        ],
      ),
    );
  }
}
