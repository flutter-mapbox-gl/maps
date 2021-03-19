// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Fill;
import com.mapbox.mapboxsdk.plugins.annotation.FillManager;
import com.mapbox.mapboxsdk.plugins.annotation.FillOptions;

import java.util.List;

class FillBuilder implements FillOptionsSink {
  private final FillManager fillManager;
  private final FillOptions fillOptions;

  FillBuilder(FillManager fillManager) {
    this.fillManager = fillManager;
    this.fillOptions = new FillOptions();
  }

  public FillOptions getFillOptions(){
    return this.fillOptions;
  }

  Fill build() {
    return fillManager.create(fillOptions);
  }

  @Override
  public void setFillOpacity(float fillOpacity) {
    fillOptions.withFillOpacity(fillOpacity);
  }

  @Override
  public void setFillColor(String fillColor) {
    fillOptions.withFillColor(fillColor);
  }

  @Override
  public void setFillOutlineColor(String fillOutlineColor) {
    fillOptions.withFillOutlineColor(fillOutlineColor);
  }

  @Override
  public void setFillPattern(String fillPattern) {
    fillOptions.withFillPattern(fillPattern);
  }

  @Override
  public void setGeometry(List<List<LatLng>> geometry) {
    fillOptions.withGeometry(Convert.interpretListLatLng(geometry));
  }

  @Override
  public void setDraggable(boolean draggable) {
    fillOptions.withDraggable(draggable);
  }
}