import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class SymbolDragPage extends ExamplePage {
  SymbolDragPage() : super(const Icon(Icons.map), 'Symbol Drag Events');

  @override
  Widget build(BuildContext context) {
    return const SymbolDrag();
  }
}

class SymbolDrag extends StatefulWidget {
  const SymbolDrag();

  @override
  State createState() => SymbolDragState();
}

class SymbolDragState extends State<SymbolDrag> {
  MapboxMapController mapController;

  DragEventType type = DragEventType.none;

  LatLng latLng = new LatLng(0,0);
  LatLng prevLatLng = new LatLng(0,0);

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;

    controller.onSymbolDragged.add((argument) {

      setState(() {
        type = argument.eventType;
        latLng = argument.currentLatLng;
        prevLatLng = argument.previousLatLng;

      });
      switch(argument.eventType)
      {
        case DragEventType.start:
          // TODO: Handle this case.
          break;
        case DragEventType.drag:
          // TODO: Handle this case.
          break;
        case DragEventType.end:

          break;
        case DragEventType.none:
          // TODO: Handle this case.
          break;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(


        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container( height: 70.0,
                child: Column(children: [
                  Text("Event type :$type", style: TextStyle(fontSize: 11),),
                  SizedBox(height: 10,),
                  Text("Current :$latLng", style: TextStyle(fontSize: 11),),
                  SizedBox(height: 10,),
                  Text("Previous :$prevLatLng", style: TextStyle(fontSize: 11),),

                ],),
              ),
            ),
            Expanded(
              child: MapboxMap(
                accessToken: MapsDemo.ACCESS_TOKEN,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
                onStyleLoadedCallback: onStyleLoadedCallback,
              ),
            ),
          ],
        ));
  }

  void onStyleLoadedCallback() {

    mapController.addSymbol(SymbolOptions(
      geometry: LatLng(0,0),
      iconImage: "airport-15",
      iconSize: 2.0,
      draggable: true,
    ));


  }

  @override
  void dispose() {

    mapController.dispose();

    super.dispose();
  }
}
