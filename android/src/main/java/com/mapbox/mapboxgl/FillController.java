// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.graphics.Color;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Fill;
import com.mapbox.mapboxsdk.plugins.annotation.FillManager;

import java.util.List;

/**
 * Controller of a single Fill on the map.
 */
class FillController implements FillOptionsSink {
  private final Fill fill;
  private final OnFillTappedListener onTappedListener;
  private boolean consumeTapEvents;

  FillController(Fill fill, boolean consumeTapEvents, OnFillTappedListener onTappedListener) {
    this.fill = fill;
    this.consumeTapEvents = consumeTapEvents;
    this.onTappedListener = onTappedListener;
  }

  public Fill getFill(){
    return this.fill;
  }

  boolean onTap() {
    if (onTappedListener != null) {
      onTappedListener.onFillTapped(fill);
    }
    return consumeTapEvents;
  }

  void remove(FillManager fillManager) {
    fillManager.delete(fill);
  }

  @Override
  public void setFillOpacity(float fillOpacity) {
    fill.setFillOpacity(fillOpacity);
  }

  @Override
  public void setFillColor(String fillColor) {
    fill.setFillColor(Color.parseColor(fillColor));
  }

  @Override
  public void setFillOutlineColor(String fillOutlineColor) {
    fill.setFillOutlineColor(Color.parseColor(fillOutlineColor));
  }

  @Override
  public void setFillPattern(String fillPattern) {
    fill.setFillPattern(fillPattern);
  }

  @Override
  public void setGeometry(List<List<LatLng>> geometry) {
    fill.setGeometry(Convert.interpretListLatLng(geometry));
  }

  @Override
  public void setDraggable(boolean draggable) {
    fill.setDraggable(draggable);
  }

  public void update(FillManager fillManager) {
    fillManager.update(fill);
  }
}
