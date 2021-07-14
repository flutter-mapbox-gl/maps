import 'dart:convert';

import 'package:mapbox_gl/models/geometry/geometry.dart';

class GeometryPoint extends Geometry {
  static const String TYPE = "Point";
  String type;

  GeometryPoint(this.latitude, this.longitude) {
    type = TYPE;
  }

  final double latitude;
  final double longitude;

  static GeometryPoint fromJson(String jsonString) {
    final jsonMap = json.decode(jsonString);
    return fromMap(jsonMap);
  }

  String toJson() => json.encode(toMap());

  static GeometryPoint fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('coordinates') ||
        map['coordinates'][0] == null ||
        map['coordinates'][1] == null) return null;

    return GeometryPoint(map['coordinates'][1], map['coordinates'][0]);
  }

  @override
  Map<String, dynamic> toMap() => {
        "type": type,
        "coordinates": [longitude, latitude]
      };

  @override
  String toString() {
    return "Point{ latitude=$latitude, longitude=$longitude}";
  }
}
