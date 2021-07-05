import 'dart:convert';

import 'package:mapbox_gl/models/bounding_box.dart';
import 'package:mapbox_gl/models/geometry/geo_json.dart';
import 'package:mapbox_gl/models/geometry/geometry.dart';

/// This defines a GeoJson Feature object which represents a spatially bound thing. Every Feature
/// object is a GeoJson object no matter where it occurs in a GeoJson text. A Feature object will
/// always have a "TYPE" member with the value "Feature".
/// <p>
/// A Feature object has a member with the name "geometry". The value of the geometry member SHALL be
/// either a Geometry object or, in the case that the Feature is unlocated, a JSON null value.
/// <p>
/// A Feature object has a member with the name "properties". The value of the properties member is
/// an object (any JSON object or a JSON null value).
/// <p>
/// If a Feature has a commonly used identifier, that identifier SHOULD be included as a member of
/// the Feature object through the {@link #id()} method, and the value of this member is either a
/// JSON string or number.
/// <p>
/// An example of a serialized feature is given below:
/// <pre>
/// {
///   "TYPE": "Feature",
///   "geometry": {
///     "TYPE": "Point",
///     "coordinates": [102.0, 0.5]
///   },
///   "properties": {
///     "prop0": "value0"
///   }
/// </pre>
///
/// @since 1.0.0
class Feature extends GeoJson {
  static const String TYPE = "Feature";
  @override
  String type;

  final String id;

  final BoundingBox bbox;
  @override
  set bbox(BoundingBox _bbox) {
    bbox = _bbox;
  }

  final Geometry geometry;

  final Map<String, dynamic> properties;

  Feature(
    this.geometry, {
    this.bbox,
    this.id,
    this.properties,
  }) {
    this.type = TYPE;
  }

  /// Create a new instance of this class by passing in a formatted valid JSON String. If you are
  /// creating a Feature object from scratch it is better to use one of the other provided static
  /// factory methods such as {@link #fromGeometry(Geometry)}.
  ///
  /// @param json a formatted valid JSON string defining a GeoJson Feature
  /// @return a new instance of this class defined by the values passed inside this static factory
  ///   method
  /// @since 1.0.0

  static Feature fromJson(String jsonString) {
    final jsonObject = json.decode(jsonString);

    return fromMap(jsonObject);
  }

  static Feature fromMap(Map<String, dynamic> map) {
    if (map['geometry'] == null) return null;

    return Feature(
      map['geometry'],
      bbox: map['bbox'],
      properties: map['properties'] ?? {},
      id: map['id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = {
      "type": type,
      "geometry": geometry.toMap(),
      "properties": properties,
    };

    if (bbox != null) map["bbox"] = bbox.toJson();

    return map;
  }

  /// Convenience method to add a String member.
  ///
  /// @param key   name of the member
  /// @param value the String value associated with the member
  /// @since 1.0.0

  void addProperty(String key, dynamic value) {
    properties[key] = value;
  }

  /// Convenience method to get a String member.
  ///
  /// @param key name of the member
  /// @return the value of the member, null if it doesn't exist
  /// @since 1.0.0

  dynamic getProperty(String key) {
    return properties[key];
  }

  /// Removes the property from the object properties.
  ///
  /// @param key name of the member
  /// @return Removed {@code property} from the key string passed in through the parameter.
  /// @since 1.0.0

  dynamic removeProperty(String key) => properties.remove(key);

  /// Convenience method to check if a member with the specified name is present in this object.
  ///
  /// @param key name of the member
  /// @return true if there is the member has the specified name, false otherwise.
  /// @since 1.0.0

  bool hasProperty(String key) => properties.containsKey(key);

  @override
  String toString() {
    return "Feature{" +
        "type=" +
        type +
        ", " +
        "bbox=" +
        bbox.toString() +
        ", " +
        "id=" +
        id +
        ", " +
        "geometry=" +
        geometry.toString() +
        ", " +
        "properties=" +
        properties.toString() +
        "}";
  }
}
