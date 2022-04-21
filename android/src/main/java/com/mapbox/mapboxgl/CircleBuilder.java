// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Circle;
import com.mapbox.mapboxsdk.plugins.annotation.CircleManager;
import com.mapbox.mapboxsdk.plugins.annotation.CircleOptions;

class CircleBuilder implements CircleOptionsSink {
  private final CircleManager circleManager;
  private final CircleOptions circleOptions;

  CircleBuilder(CircleManager circleManager) {
    this.circleManager = circleManager;
    this.circleOptions = new CircleOptions();
  }

  public CircleOptions getCircleOptions(){
    return this.circleOptions;
  }

  Circle build() {
    return circleManager.create(circleOptions);
  }

  @Override
  public void setCircleRadius(float circleRadius) {
    circleOptions.withCircleRadius(circleRadius);
  }

  @Override
  public void setCircleColor(String circleColor) {
    circleOptions.withCircleColor(circleColor);
  }

  @Override
  public void setCircleBlur(float circleBlur) {
    circleOptions.withCircleBlur(circleBlur);
  }

  @Override
  public void setCircleOpacity(float circleOpacity) {
    circleOptions.withCircleOpacity(circleOpacity);
  }

  @Override
  public void setCircleStrokeWidth(float circleStrokeWidth) {
    circleOptions.withCircleStrokeWidth(circleStrokeWidth);
  }

  @Override
  public void setCircleStrokeColor(String circleStrokeColor) {
    circleOptions.withCircleStrokeColor(circleStrokeColor);
  }

  @Override
  public void setCircleStrokeOpacity(float circleStrokeOpacity) {
    circleOptions.withCircleStrokeOpacity(circleStrokeOpacity);
  }

  @Override
  public void setGeometry(LatLng geometry) {
    circleOptions.withGeometry(Point.fromLngLat(geometry.getLongitude(), geometry.getLatitude()));
  }

  @Override
  public void setDraggable(boolean draggable) {
    circleOptions.withDraggable(draggable);
  }
}