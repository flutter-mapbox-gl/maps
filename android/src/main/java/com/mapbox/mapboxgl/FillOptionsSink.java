// This file is generated.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

/** Receiver of Fill configuration options. */
interface FillOptionsSink {
          
  void setFillOpacity(float fillOpacity);
          
  void setFillColor(String fillColor);
          
  void setFillOutlineColor(String fillOutlineColor);
                  
  void setFillPattern(String fillPattern);
      
  void setGeometry(List<List<LatLng>> geometry);

  void setDraggable(boolean draggable);
}
