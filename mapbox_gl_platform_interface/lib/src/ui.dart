// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl_platform_interface;

class MapboxStyles {
  static const String MAPBOX_STREETS = "mapbox://styles/mapbox/streets-v11";

  /// Outdoors: A general-purpose style tailored to outdoor activities. Using this constant means
  /// your map style will always use the latest version and may change as we improve the style.
  static const String OUTDOORS = "mapbox://styles/mapbox/outdoors-v11";

  /// Light: Subtle light backdrop for data visualizations. Using this constant means your map
  /// style will always use the latest version and may change as we improve the style.
  static const String LIGHT = "mapbox://styles/mapbox/light-v10";

  /// Dark: Subtle dark backdrop for data visualizations. Using this constant means your map style
  /// will always use the latest version and may change as we improve the style.
  static const String DARK = "mapbox://styles/mapbox/dark-v10";

  /// Satellite: A beautiful global satellite and aerial imagery layer. Using this constant means
  /// your map style will always use the latest version and may change as we improve the style.
  static const String SATELLITE = "mapbox://styles/mapbox/satellite-v9";

  /// Satellite Streets: Global satellite and aerial imagery with unobtrusive labels. Using this
  /// constant means your map style will always use the latest version and may change as we
  /// improve the style.
  static const String SATELLITE_STREETS =
      "mapbox://styles/mapbox/satellite-streets-v11";

  /// Traffic Day: Color-coded roads based on live traffic congestion data. Traffic data is currently
  /// available in
  /// <a href="https://www.mapbox.com/help/how-directions-work/#traffic-data">these select
  /// countries</a>. Using this constant means your map style will always use the latest version and
  /// may change as we improve the style.
  static const String TRAFFIC_DAY = "mapbox://styles/mapbox/traffic-day-v2";

  /// Traffic Night: Color-coded roads based on live traffic congestion data, designed to maximize
  /// legibility in low-light situations. Traffic data is currently available in
  /// <a href="https://www.mapbox.com/help/how-directions-work/#traffic-data">these select
  /// countries</a>. Using this constant means your map style will always use the latest version and
  /// may change as we improve the style.
  static const String TRAFFIC_NIGHT = "mapbox://styles/mapbox/traffic-night-v2";
}

/// The camera mode, which determines how the map camera will track the rendered location.
enum MyLocationTrackingMode {
  None,
  Tracking,
  TrackingCompass,
  TrackingGPS,
}

/// Render mode
enum MyLocationRenderMode {
  NORMAL,
  COMPASS,
  GPS,
}

/// Compass View Position
enum CompassViewPosition {
  TopLeft,
  TopRight,
  BottomLeft,
  BottomRight,
}

/// Attribution Button Position
enum AttributionButtonPosition {
  TopLeft,
  TopRight,
  BottomLeft,
  BottomRight,
}

/// Bounds for the map camera target.
// Used with [MapboxMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds? bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  dynamic toJson() => <dynamic>[bounds?.toList()];

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraTargetBounds typedOther = other;
    return bounds == typedOther.bounds;
  }

  @override
  int get hashCode => bounds.hashCode;

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }
}

/// Preferred bounds for map camera zoom level.
// Used with [MapboxMapOptions] to wrap min and max zoom. This allows
// distinguishing between specifying unbounded zooming (null `minZoom` and
// `maxZoom`) from not specifying anything (null `MinMaxZoomPreference`).
class MinMaxZoomPreference {
  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double? minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  /// Unbounded zooming.
  static const MinMaxZoomPreference unbounded =
      MinMaxZoomPreference(null, null);

  dynamic toJson() => <dynamic>[minZoom, maxZoom];

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final MinMaxZoomPreference typedOther = other;
    return minZoom == typedOther.minZoom && maxZoom == typedOther.maxZoom;
  }

  @override
  int get hashCode => hashValues(minZoom, maxZoom);

  @override
  String toString() {
    return 'MinMaxZoomPreference(minZoom: $minZoom, maxZoom: $maxZoom)';
  }
}
