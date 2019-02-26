// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import java.util.List;
import com.mapbox.mapboxsdk.geometry.LatLng;

/**
 * Receiver of Line configuration options.
 */
interface LineOptionsSink {

  void setLineJoin(String lineJoin);

  void setLineOpacity(float lineOpacity);

  void setLineColor(String lineColor);

  void setLineWidth(float lineWidth);

  void setLineGapWidth(float lineGapWidth);

  void setLineOffset(float lineOffset);

  void setLineBlur(float lineBlur);

  void setLinePattern(String linePattern);

  void setGeometry(List<LatLng> geometry);

  void setDraggable(boolean draggable);
}
