import 'dart:convert';

import 'package:mapbox_gl/models/bounding_box.dart';
import 'package:mapbox_gl/models/feature.dart';
import 'package:mapbox_gl/models/geometry/geo_json.dart';

/// This represents a GeoJson Feature Collection which holds a list of {@link Feature} objects (when
/// serialized the feature list becomes a JSON array).
/// <p>
/// Note that the feature list could potentially be empty. Features within the list must follow the
/// specifications defined inside the {@link Feature} class.
/// <p>
/// An example of a Feature Collections given below:
/// <pre>
/// {
///   "TYPE": "FeatureCollection",
///   "bbox": [100.0, 0.0, -100.0, 105.0, 1.0, 0.0],
///   "features": [
///     //...
///   ]
/// }
/// </pre>
///
/// @since 1.0.0
class FeatureCollection extends GeoJson {
  static const String TYPE = "FeatureCollection";

  late final String type;

  FeatureCollection(
    this.features, {
    this.bbox,
  }) {
    type = TYPE;
  }

  final BoundingBox? bbox;

  final List<Feature> features;

  /// Create a new instance of this class by passing in a formatted valid JSON String. If you are
  /// creating a FeatureCollection object from scratch it is better to use one of the other provided
  /// static factory methods such as {@link #fromFeatures(List)}.
  ///
  /// @param json a formatted valid JSON string defining a GeoJson Feature Collection
  /// @return a new instance of this class defined by the values passed inside this static factory
  ///   method
  /// @since 1.0.0
  static FeatureCollection fromJson(String jsonString) {
    final jsonObject = json.decode(jsonString);
    return fromMap(jsonObject);
  }

  static FeatureCollection fromMap(Map<String, dynamic> map) {
    if (map['features'] == null) return null;

    final featureCollection = FeatureCollection(
      (map['features'] as List<dynamic>)
          .map((e) => Feature.fromJson(e))
          .toList(),
      bbox: map['bbox'],
    );
    return featureCollection;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = {
      "type": type,
      "features": features.map((f) => f.toMap()).toList(),
    };

    return map;
  }

  String toString() {
    return "FeatureCollection{" +
        "type=" +
        type +
        ", " +
        "bbox=" +
        bbox.toString() +
        ", " +
        "features=" +
        features.toString() +
        "}";
  }

  @override
  set bbox(BoundingBox? _bbox) {
    bbox = _bbox;
  }

  addFeature(Feature feature) => features.add(feature);
  removeFeature(Feature feature) => features.remove(feature);
  removeFeatureAt(int index) => features.removeAt(index);
}
