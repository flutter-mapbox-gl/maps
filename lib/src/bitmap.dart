// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

/// Defines a bitmap image. For a marker, this class can be used to set the
/// image of the marker icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
class BitmapDescriptor {
  const BitmapDescriptor._(this._json);

  static const double hueRed = 0.0;
  static const double hueOrange = 30.0;
  static const double hueYellow = 60.0;
  static const double hueGreen = 120.0;
  static const double hueCyan = 180.0;
  static const double hueAzure = 210.0;
  static const double hueBlue = 240.0;
  static const double hueViolet = 270.0;
  static const double hueMagenta = 300.0;
  static const double hueRose = 330.0;

  /// Creates a BitmapDescriptor that refers to the default marker image.
  static const BitmapDescriptor defaultMarker =
      BitmapDescriptor._(<dynamic>['defaultMarker']);

  /// Creates a BitmapDescriptor that refers to a colorization of the default
  /// marker image. For convenience, there is a predefined set of hue values.
  /// See e.g. [hueYellow].
  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    return BitmapDescriptor._(<dynamic>['defaultMarker', hue]);
  }

  /// Creates a BitmapDescriptor using the name of a bitmap image in the assets
  /// directory.
  static BitmapDescriptor fromAsset(String assetName, {String package}) {
    if (package == null) {
      return BitmapDescriptor._(<dynamic>['fromAsset', assetName]);
    } else {
      return BitmapDescriptor._(<dynamic>['fromAsset', assetName, package]);
    }
  }

  final dynamic _json;

  dynamic _toJson() => _json; //ignore: unused_element
}
