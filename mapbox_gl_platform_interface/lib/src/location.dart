// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl_platform_interface;

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  dynamic toJson() {
    return <double>[latitude, longitude];
  }

  static LatLng _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() => '$runtimeType($latitude, $longitude)';

  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}

/// A latitude/longitude aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.latitude`, `northeast.latitude`]
/// * lng ∈ [`southwest.longitude`, `northeast.longitude`],
///   if `southwest.longitude` ≤ `northeast.longitude`,
/// * lng ∈ [-180, `northeast.longitude`] ∪ [`southwest.longitude`, 180[,
///   if `northeast.longitude` < `southwest.longitude`
class LatLngBounds {
  /// Creates geographical bounding box with the specified corners.
  ///
  /// The latitude of the southwest corner cannot be larger than the
  /// latitude of the northeast corner.
  LatLngBounds({@required this.southwest, @required this.northeast})
      : assert(southwest != null),
        assert(northeast != null),
        assert(southwest.latitude <= northeast.latitude);

  /// The southwest corner of the rectangle.
  final LatLng southwest;

  /// The northeast corner of the rectangle.
  final LatLng northeast;

  dynamic toList() {
    return <dynamic>[southwest.toJson(), northeast.toJson()];
  }

  @visibleForTesting
  static LatLngBounds fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng._fromJson(json[0]),
      northeast: LatLng._fromJson(json[1]),
    );
  }

  @override
  String toString() {
    return '$runtimeType($southwest, $northeast)';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southwest == southwest &&
        o.northeast == northeast;
  }

  @override
  int get hashCode => hashValues(southwest, northeast);
}

/// A geographical area representing a non-aligned quadrilateral
/// This class does not wrap values to the world bounds
class LatLngQuad {
  LatLngQuad({@required this.topLeft, @required this.topRight, @required this.bottomRight, @required this.bottomLeft})
      : assert(topLeft != null),
        assert(topRight != null),
        assert(bottomRight != null),
        assert(bottomLeft != null);

  final LatLng topLeft;

  final LatLng topRight;

  final LatLng bottomRight;

  final LatLng bottomLeft;

  dynamic toList() {
    return <dynamic>[topLeft.toJson(), topRight.toJson(), bottomRight.toJson(), bottomLeft.toJson()];
  }

  @visibleForTesting
  static LatLngQuad fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngQuad(
      topLeft: LatLng._fromJson(json[0]),
      topRight: LatLng._fromJson(json[1]),
      bottomRight: LatLng._fromJson(json[2]),
      bottomLeft: LatLng._fromJson(json[3]),
    );
  }

  @override
  String toString() {
    return '$runtimeType($topLeft, $topRight, $bottomRight, $bottomLeft)';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngQuad &&
        o.topLeft == topLeft &&
        o.topRight == topRight &&
        o.bottomRight == bottomRight &&
        o.bottomLeft == bottomLeft;
  }

  @override
  int get hashCode => hashValues(topLeft, topRight, bottomRight, bottomLeft);
  
}

/// User's observed location
class UserLocation {
  /// User's position in latitude and longitude
  final LatLng position;

  /// User's altitude in meters
  final double altitude;

  /// Direction user is traveling, measured in degrees
  final double bearing;

  /// User's speed in meters per second
  final double speed;

  /// The radius of uncertainty for the location, measured in meters
  final double horizontalAccuracy;

  /// Accuracy of the altitude measurement, in meters
  final double verticalAccuracy;

  /// Time the user's location was observed
  final DateTime timestamp;

  const UserLocation(
      {@required this.position,
      @required this.altitude,
      @required this.bearing,
      @required this.speed,
      @required this.horizontalAccuracy,
      @required this.verticalAccuracy,
      @required this.timestamp});
}