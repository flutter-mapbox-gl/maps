import 'dart:io';

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
  String? snapshotUri;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _onTakeSnap() async {
    final renderBox = mapKey.currentContext?.findRenderObject() as RenderBox;

    final snapshotOptions = SnapshotOptions(
      width: renderBox.size.width,
      height: renderBox.size.height,
      writeToDisk: true,
      withLogo: false,
    );
    final uri = await mapController?.takeSnap(snapshotOptions);
    debugPrint("Snapshot uri: $uri");

    _setResult(uri);
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

  void _setResult(String? uri) {
    if (uri != null) {
      setState(() {
        snapshotUri = uri.replaceAll("file:", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MapboxMap(
                key: mapKey,
                accessToken: MapsDemo.ACCESS_TOKEN,
                onMapCreated: _onMapCreated,
                initialCameraPosition:
                    const CameraPosition(target: LatLng(0.0, 0.0)),
                myLocationEnabled: true,
                styleString: MapboxStyles.SATELLITE,

              ),
            ],
          ),
        ),
        const SizedBox(height: 5,),
        Container(
          height: height * 0.4,
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: _onTakeSnap, child: Text("Take Snap")),
                  ElevatedButton(
                      onPressed: _onTakeSnapWithBounds,
                      child: Text("Take snap With Bounds")),
                  ElevatedButton(
                      onPressed: _onTakeSnapWithCameraPosition,
                      child: Text("Take snap With Camera Position")),
                ],
              ),
              const SizedBox(height: 10,),
              if (snapshotUri != null)
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: Image.file(
                    File(snapshotUri!),
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
