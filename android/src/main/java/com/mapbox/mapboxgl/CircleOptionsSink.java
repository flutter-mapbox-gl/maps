// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.geometry.LatLng;

/** Receiver of Circle configuration options. */
interface CircleOptionsSink {
      
  void setCircleRadius(float circleRadius);
          
  void setCircleColor(String circleColor);
          
  void setCircleBlur(float circleBlur);
          
  void setCircleOpacity(float circleOpacity);
                          
  void setCircleStrokeWidth(float circleStrokeWidth);
          
  void setCircleStrokeColor(String circleStrokeColor);
          
  void setCircleStrokeOpacity(float circleStrokeOpacity);
      
  void setGeometry(LatLng geometry);

  void setDraggable(boolean draggable);
}
