// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

class Fill {
  @visibleForTesting
  Fill(this._id, this._options);

  /// A unique identifier for this fill.
  ///
  /// The identifier is an arbitrary unique string.
  final String _id;

  String get id => _id;

  FillOptions _options;

  /// The fill configuration options most recently applied programmatically
  /// via the map controller.
  ///
  /// The returned value does not reflect any changes made to the fill through
  /// touch events. Add listeners to the owning map controller to track those.
  FillOptions get options => _options;
}

/// Configuration options for [Fill] instances.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class FillOptions {
  /// Creates a set of fill configuration options.
  ///
  /// By default, every non-specified field is null, meaning no desire to change
  /// fill defaults or current configuration.
  const FillOptions({
    this.fillOpacity,
    this.fillColor,
    this.fillOutlineColor,
    this.fillPattern,
    this.geometry,
  });

  final double fillOpacity;
  final String fillColor;
  final String fillOutlineColor;
  final String fillPattern;
  final LatLng geometry;

  static const FillOptions defaultOptions = FillOptions(
    fillOpacity: 1.0,
    fillColor: "rgba(0, 0, 0, 1)",
    fillOutlineColor: "rgba(0, 0, 0, 1)",
    fillPattern: "pedestrian-polygon",
    geometry: LatLng(0.0, 0.0),
  );

  FillOptions copyWith(FillOptions changes) {
    if (changes == null) {
      return this;
    }
    return FillOptions(
      fillOpacity: changes.fillOpacity ?? fillOpacity,
      fillColor: changes.fillColor ?? fillColor,
      fillOutlineColor: changes.fillOutlineColor ?? fillOutlineColor,
      fillPattern: changes.fillPattern ?? fillPattern,
      geometry: changes.geometry ?? geometry,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {q
    if (value != null) {
      json[fieldName] = value;
    }
    }

    addIfPresent('fill-opacity', fillOpacity);
    addIfPresent('fill-color', fillColor);
    addIfPresent('fill-outline-color', fillOutlineColor);
    addIfPresent('fill-pattern', fillPattern);
    addIfPresent('geometry', geometry?._toJson());
    return json;
  }
}