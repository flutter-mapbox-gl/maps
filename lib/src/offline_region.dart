import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

final offlineRegionDefinition = OfflineRegionDefinition(
  bounds: LatLngBounds(
    southwest: LatLng(37.7749, -122.4194),
    northeast: LatLng(37.8049, -122.3894),
  ),
  mapStyleUrl: MapboxStyles.SATELLITE_STREETS,
  minZoom: 10.0,
  maxZoom: 16.0,
  includeIdeographs: true,
  vectorSourceProperties: VectorSourceProperties(
    url: 'mapbox://mapbox.mapbox-traffic-v1',
    // other properties for the vector source
  ),
);
class StyleInfo {
  final String name;
  final String baseStyle;
  final CameraPosition position;

  const StyleInfo(
      {required this.name,
        required this.baseStyle,
        required this.position});
}
class OfflineRegionMap extends StatefulWidget {

  @override
  _OfflineRegionMapState createState() => _OfflineRegionMapState();
}

class _OfflineRegionMapState extends State<OfflineRegionMap> {
  MapboxMapController? _controller;
  _onMapCreated(MapboxMapController controller) {
    _controller = controller;
  }
  static Future<void> addVector(MapboxMapController controller) async {
    await controller.addSource(
      "traffic",
     offlineRegionDefinition.vectorSourceProperties.url,
    );


// // Adding a layer using the "traffic" source
//     await controller.addLayer(
//       "traffic",
//       "traffic-layer",
//       const LineLayerProperties(
//         lineColor: "#ff0000", // Red color
//         lineWidth: 2,
//         lineCap: "round",
//         lineJoin: "round",
//       ),
//       sourceLayer: "traffic",
//     );
//     await controller.addSource(
//         "terrain",
//         const VectorSourceProperties(
//           url: "mapbox://mapbox.mapbox-terrain-v2",
//         ));
//
//     await controller.addLayer(
//         "terrain",
//         "contour",
//         const LineLayerProperties(
//           lineColor: "#ff69b4",
//           lineWidth: 10,
//           lineCap: "round",
//           lineJoin: "round",
//         ),
//
//
//         sourceLayer: "contour");


  }


  // static const _stylesAndLoaders = [
  //   StyleInfo(
  //     name: "Vector ",
  //     baseStyle: MapboxStyles.MAPBOX_STREETS,
  //     position: CameraPosition(target: LatLng(34.052235, -118.243683), zoom: 12),
  //   ),
  // ];
  _onStyleLoadedCallback() async {
    // final styleInfo = _stylesAndLoaders[0];
    addVector(_controller!);
    _controller!
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(34.052235, -118.243683), zoom: 12)));
  }
  @override


  Widget build(BuildContext context) {
    // final styleInfo = _stylesAndLoaders[0];
    return Scaffold(
      appBar: AppBar(
        title: Text("offline rendered"),
      ),
      body: MapboxMap(
        styleString: offlineRegionDefinition.mapStyleUrl,
        accessToken: "sk.eyJ1IjoidXRzYXYwMSIsImEiOiJjbGwyMmQwMXQwd2szM29wMzZueXl4ejBwIn0.aWDCoRxRA_1o5luDfZIF6A",
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: LatLng(34.052235, -118.243683), zoom: 12),
        onStyleLoadedCallback: _onStyleLoadedCallback,
      ),

    );

  }



}
