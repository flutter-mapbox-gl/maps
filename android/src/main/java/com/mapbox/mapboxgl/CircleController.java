// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.graphics.Color;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Circle;
import com.mapbox.mapboxsdk.plugins.annotation.CircleManager;

/** Controller of a single Circle on the map. */
class CircleController implements CircleOptionsSink {
  private final Circle circle;
  private final OnCircleTappedListener onTappedListener;
  private boolean consumeTapEvents;

  CircleController(Circle circle, boolean consumeTapEvents, OnCircleTappedListener onTappedListener) {
    this.circle = circle;
    this.consumeTapEvents = consumeTapEvents;
    this.onTappedListener = onTappedListener;
  }

  public Circle getCircle(){
    return this.circle;
  }

  boolean onTap() {
    if (onTappedListener != null) {
      onTappedListener.onCircleTapped(circle);
    }
    return consumeTapEvents;
  }

  void remove(CircleManager circleManager) {
    circleManager.delete(circle);
  }

  @Override
  public void setCircleRadius(float circleRadius) {
    circle.setCircleRadius(circleRadius);
  }

  @Override
  public void setCircleColor(String circleColor) {
    circle.setCircleColor(Color.parseColor(circleColor));
  }

  @Override
  public void setCircleBlur(float circleBlur) {
    circle.setCircleBlur(circleBlur);
  }

  @Override
  public void setCircleOpacity(float circleOpacity) {
    circle.setCircleOpacity(circleOpacity);
  }

  @Override
  public void setCircleStrokeWidth(float circleStrokeWidth) {
    circle.setCircleStrokeWidth(circleStrokeWidth);
  }

  @Override
  public void setCircleStrokeColor(String circleStrokeColor) {
    circle.setCircleStrokeColor(Color.parseColor(circleStrokeColor));
  }

  @Override
  public void setCircleStrokeOpacity(float circleStrokeOpacity) {
    circle.setCircleStrokeOpacity(circleStrokeOpacity);
  }

  @Override
  public void setGeometry(LatLng geometry) {
    circle.setGeometry(Point.fromLngLat(geometry.getLongitude(), geometry.getLatitude()));
  }

  public LatLng getGeometry() {
    Point point =  circle.getGeometry();
    return new LatLng(point.latitude(), point.longitude());
  }

  @Override
  public void setDraggable(boolean draggable) {
    circle.setDraggable(draggable);
  }

  public void update(CircleManager circleManager) {
    circleManager.update(circle);
  }

}
