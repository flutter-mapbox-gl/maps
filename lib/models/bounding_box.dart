import 'dart:convert';

import 'package:mapbox_gl/models/geometry/geometry_point.dart';

/// A GeoJson object MAY have a member named "bbox" to include information on the coordinate range
/// for its Geometries, Features, or FeatureCollections.
/// <p>
/// This class simplifies the build process for creating a bounding box and working with them when
/// deserialized. specific parameter naming helps define which coordinates belong where when a
/// bounding box instance is being created. Note that since GeoJson objects only have the option of
/// including a bounding box JSON element, the {@code bbox} value returned by a GeoJson object might
/// be null.
/// <p>
/// At a minimum, a bounding box will have two {@link Point}s or four coordinates which define the
/// box. A 3rd dimensional bounding box can be produced if elevation or altitude is defined.
///
/// @since 3.0.0

class BoundingBox {
  // implements Serializable {

  final GeometryPoint southwest;

  final GeometryPoint northeast;

  BoundingBox(this.southwest, this.northeast);

  /// Create a new instance of this class by passing in a formatted valid JSON String.
  ///
  /// @param json a formatted valid JSON string defining a Bounding Box
  /// @return a new instance of this class defined by the values passed inside this static factory
  ///   method
  /// @since 3.0.0
  static BoundingBox? fromJson(String jsonString) {
    final jsonObject = json.decode(jsonString);

    if (jsonObject['southwest'] != null && jsonObject['northeast'] != null) {
      return BoundingBox(jsonObject['southwest'], jsonObject['northeast']);
    }

    return null;
  }

  /// Define a new instance of this class by passing in two {@link Point}s, representing both the
  /// southwest and northwest corners of the bounding box.
  ///
  /// @param southwest represents the bottom left corner of the bounding box when the camera is
  ///                  pointing due north
  /// @param northeast represents the top right corner of the bounding box when the camera is
  ///                  pointing due north
  /// @return a new instance of this class defined by the provided points
  /// @since 3.0.0

  static BoundingBox fromPoints(
      GeometryPoint southwest, GeometryPoint northeast) {
    return new BoundingBox(southwest, northeast);
  }

  double west() => southwest.longitude;
  double south() => southwest.latitude;
  double east() => northeast.longitude;
  double north() => northeast.latitude;

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() =>
      {"southwest": southwest, "northeast": northeast};

  String toString() {
    return "BoundingBox{" +
        "southwest=" +
        southwest.toString() +
        ", " +
        "northeast=" +
        northeast.toString() +
        "}";
  }
}
