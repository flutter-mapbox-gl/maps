import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class TakeSnapPage extends ExamplePage {
  TakeSnapPage() : super(const Icon(Icons.camera_alt), 'Take snapshot');

  @override
  Widget build(BuildContext context) {
    return const TakeSnapshot();
  }
}

class TakeSnapshot extends StatefulWidget {
  const TakeSnapshot();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<TakeSnapshot> {
  FullMapState();

  MapboxMapController? mapController;
  final mapKey = GlobalKey();
  String? snapshotResult;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _onTakeSnap([bool writeToDisk = true]) async {
    final renderBox = mapKey.currentContext?.findRenderObject() as RenderBox;

    final snapshotOptions = SnapshotOptions(
      width: renderBox.size.width,
      height: renderBox.size.height,
      writeToDisk: writeToDisk,
      withLogo: false,
    );
    final result = await mapController?.takeSnap(snapshotOptions);
    debugPrint("result: $result");
    _setResult(result);
  }

  void _onTakeSnapWithBounds() async {
    final renderBox = mapKey.currentContext?.findRenderObject() as RenderBox;
    final bounds = await mapController?.getVisibleRegion();

    final snapshotOptions = SnapshotOptions(
      width: renderBox.size.width,
      height: renderBox.size.height,
      writeToDisk: true,
      withLogo: false,
      bounds: bounds,
    );
    final uri = await mapController?.takeSnap(snapshotOptions);

    _setResult(uri);
  }

  void _onTakeSnapWithCameraPosition() async {
    final renderBox = mapKey.currentContext?.findRenderObject() as RenderBox;

    final snapshotOptions = SnapshotOptions(
      width: renderBox.size.width,
      height: renderBox.size.height,
      writeToDisk: true,
      withLogo: false,
      centerCoordinate: LatLng(40.79796, -74.126410),
      zoomLevel: 12,
      pitch: 30,
      heading: 20,
    );
    final uri = await mapController?.takeSnap(snapshotOptions);
    _setResult(uri);
  }

  void _setResult(String? result) {
    if (result != null) {
      setState(() {
        snapshotResult = result.replaceAll("file:", "");
      });
    }
  }

  Uint8List convertBase64Image(String base64String) {
    return Base64Decoder().convert(base64String.split(',').last);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: MapboxMap(
            key: mapKey,
            accessToken: MapsDemo.ACCESS_TOKEN,
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                const CameraPosition(target: LatLng(0.0, 0.0)),
            myLocationEnabled: true,
            styleString: MapboxStyles.SATELLITE,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: height * 0.4,
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onTakeSnap,
                    child: Text("Take Snap"),
                  ),
                  ElevatedButton(
                    onPressed: _onTakeSnapWithBounds,
                    child: Text("With Bounds"),
                  ),
                  ElevatedButton(
                    onPressed: _onTakeSnapWithCameraPosition,
                    child: Text("With Camera Position"),
                  ),
                  ElevatedButton(
                    onPressed: () => _onTakeSnap(false),
                    child: Text("With Base64"),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (snapshotResult != null)
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: snapshotResult!.contains("base64")
                      ? Image.memory(
                          convertBase64Image(snapshotResult!),
                          gaplessPlayback: true,
                          height: height * 0.20,
                        )
                      : Image.file(
                          File(snapshotResult!),
                          height: height * 0.20,
                        ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
