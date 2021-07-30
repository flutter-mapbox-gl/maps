import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/models/bounding_box.dart';
import 'package:mapbox_gl/models/geometry/geometry.dart';
import 'package:mapbox_gl/models/geometry/geometry_point.dart';

class GeometryPolygon extends Geometry {
  static const TYPE = "Polygon";
  String type;

  List<List<GeometryPoint>> coordinates = [];

  final BoundingBox bbox;

  GeometryPolygon(this.coordinates, {this.bbox}) {
    type = TYPE;
  }

  static GeometryPolygon fromJson(String jsonString) =>
      fromMap(json.decode(jsonString));

  static GeometryPolygon fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('coordinates')) return null;

    return GeometryPolygon(
        (map['coordinates'] as List)
            .map((a) =>
                (a as List).map((b) => GeometryPoint.fromMap(b)).toList())
            .toList(),
        bbox: map['bbox']);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = {
      "type": type,
      "bbox": bbox,
      "coordinates": coordinates
          .map((a) => a.map((b) => [b.longitude, b.latitude]).toList())
          .toList()
    };
    return map;
  }

  /// Add additional geometry and automatically repeat the first geometry point in the last position
  Future addGeometryPoints(List<LatLng> newCoordinates) async {
    for (final currentPoly in coordinates) {
      final index = coordinates.indexOf(currentPoly);

      final firstDoesRepeat = currentPoly.length > 1 &&
          currentPoly.first.latitude == currentPoly.last.latitude &&
          currentPoly.first.longitude == currentPoly.last.longitude;

      if (firstDoesRepeat) currentPoly.removeLast();

      for (final coordinate in newCoordinates) {
        currentPoly
            .add(GeometryPoint(coordinate.latitude, coordinate.longitude));
      }
      if (currentPoly?.first != null) {
        currentPoly.add(currentPoly.first);
      }
      coordinates[index] = currentPoly;
    }
  }
}
