import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/models/bounding_box.dart';
import 'package:mapbox_gl/models/geometry/geometry.dart';
import 'package:mapbox_gl/models/geometry/geometry_point.dart';

/// A linestring represents two or more geographic points that share a relationship and is one of the
/// seven geometries found in the GeoJson spec.
/// <p>
/// This adheres to the RFC 7946 internet standard when serialized into JSON. When deserialized, this
/// class becomes an immutable object which should be initiated using its static factory methods.
/// </p><p>
/// The list of points must be equal to or greater than 2. A LineString has non-zero length and
/// zero area. It may approximate a curve and need not be straight. Unlike a LinearRing, a LineString
/// is not closed.
/// </p><p>
/// When representing a LineString that crosses the antimeridian, interoperability is improved by
/// modifying their geometry. Any geometry that crosses the antimeridian SHOULD be represented by
/// cutting it in two such that neither part's representation crosses the antimeridian.
/// </p><p>
/// For example, a line extending from 45 degrees N, 170 degrees E across the antimeridian to 45
/// degrees N, 170 degrees W should be cut in two and represented as a MultiLineString.
/// </p><p>
/// A sample GeoJson LineString's provided below (in it's serialized state).
/// <pre>
/// {
///   "TYPE": "LineString",
///   "coordinates": [
///     [100.0, 0.0],
///     [101.0, 1.0]
///   ]
/// }
/// </pre>
/// Look over the {@link Point} documentation to get more
/// information about formatting your list of point objects correctly.
///
/// @since 1.0.0

class GeometryLineString extends Geometry {
  //implements CoordinateContainer<List<Point>> {

  static const String TYPE = "LineString";

  String type;

  final BoundingBox bbox;

  final List<GeometryPoint> coordinates;

  GeometryLineString(
    this.coordinates, {
    this.bbox,
  }) {
    type = TYPE;
  }

  /// Create a new instance of this class by passing in a formatted valid JSON String. If you are
  /// creating a LineString object from scratch it is better to use one of the other provided static
  /// factory methods such as {@link #fromLngLats(List)}. For a valid lineString to exist, it must
  /// have at least 2 coordinate entries. The LineString should also have non-zero distance and zero
  /// area.
  ///
  /// @param json a formatted valid JSON string defining a GeoJson LineString
  /// @return a new instance of this class defined by the values passed inside this static factory
  ///   method
  /// @since 1.0.0

  static GeometryLineString fromJson(String jsonString) {
    final jsonMap = json.decode(jsonString);

    return fromMap(jsonMap);
  }

  static GeometryLineString fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('coordinates')) return null;

    return GeometryLineString(
        (map['coordinates'] as List<dynamic>)
            .map((e) => GeometryPoint.fromMap(e))
            .toList(),
        bbox: map['bbox']);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = {
      "type": type,
      "coordinates": coordinates.map((c) => [c.longitude, c.latitude]).toList()
    };
    if (bbox != null) map['bbox'] = bbox;

    return map;
  }
}
