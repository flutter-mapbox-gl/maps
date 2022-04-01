import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl_example/main.dart';
import 'package:mapbox_gl_example/page.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class CustomMyLocationStyle extends ExamplePage {
  const CustomMyLocationStyle({Key? key})
      : super(const Icon(Icons.my_location), "Custom my location style");

  @override
  Widget build(BuildContext context) {
    return CustomMyLocationStyleBody();
  }
}

class CustomMyLocationStyleBody extends StatefulWidget {
  const CustomMyLocationStyleBody({Key? key}) : super(key: key);

  @override
  State<CustomMyLocationStyleBody> createState() =>
      _CustomMyLocationStyleBodyState();
}

class _CustomMyLocationStyleBodyState extends State<CustomMyLocationStyleBody> {
  var _myLocationStyle = MyLocationStyle();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxMap(
        initialCameraPosition: CameraPosition(target: LatLng(0, 0)),
        accessToken: MapsDemo.ACCESS_TOKEN,
        myLocationEnabled: true,
        myLocationStyle: _myLocationStyle,
        onMapCreated: (ctr) async {
          final location = await Location().getLocation();
          await ctr.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(location.latitude ?? 0, location.longitude ?? 0), 14));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.swap_horiz),
        onPressed: () {
          setState(() {
            _myLocationStyle = MyLocationStyle(
              puckColor: Colors.yellow,
              pulsingColor: Colors.green,
            );
          });
        },
      ),
    );
  }
}
