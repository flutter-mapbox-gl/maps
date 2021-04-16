// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import java.util.List;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.plugins.annotation.Line;
import com.mapbox.mapboxsdk.plugins.annotation.LineManager;
import com.mapbox.mapboxsdk.plugins.annotation.LineOptions;

class LineBuilder implements LineOptionsSink {
  private final LineManager lineManager;
  private final LineOptions lineOptions;

  LineBuilder(LineManager lineManager) {
    this.lineManager = lineManager;
    this.lineOptions = new LineOptions();
  }

  public LineOptions getLineOptions(){
    return this.lineOptions;
  }

  Line build() {
    return lineManager.create(lineOptions);
  }

  @Override
  public void setLineJoin(String lineJoin) {
    lineOptions.withLineJoin(lineJoin);
  }
  
  @Override
  public void setLineOpacity(float lineOpacity) {
    lineOptions.withLineOpacity(lineOpacity);
  }
  
  @Override
  public void setLineColor(String lineColor) {
    lineOptions.withLineColor(lineColor);
  }

  @Override
  public void setLineWidth(float lineWidth) {
    lineOptions.withLineWidth(lineWidth);
  }

  @Override
  public void setLineGapWidth(float lineGapWidth) {
    lineOptions.withLineGapWidth(lineGapWidth);
  }

  @Override
  public void setLineOffset(float lineOffset) {
    lineOptions.withLineOffset(lineOffset);
  }

  @Override
  public void setLineBlur(float lineBlur) {
    lineOptions.withLineBlur(lineBlur);
  }

  @Override
  public void setLinePattern(String linePattern) {
    lineOptions.withLinePattern(linePattern);
  }
  
  @Override
  public void setGeometry(List<LatLng> geometry) {
    lineOptions.withLatLngs(geometry);
  }

  @Override
  public void setDraggable(boolean draggable) {
    lineOptions.withDraggable(draggable);
  }
}