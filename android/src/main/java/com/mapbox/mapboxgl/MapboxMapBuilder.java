// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;
import com.mapbox.mapboxsdk.maps.Style;

import io.flutter.plugin.common.PluginRegistry;

import java.util.concurrent.atomic.AtomicInteger;


class MapboxMapBuilder implements MapboxMapOptionsSink {
  public final String TAG = getClass().getSimpleName();
  private final MapboxMapOptions options = new MapboxMapOptions()
    .textureMode(true)
    .attributionEnabled(false);
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private int myLocationTrackingMode = 0;
  private int myLocationRenderMode = 0;
  private String styleString = Style.MAPBOX_STREETS;

  MapboxMapController build(
    int id, Context context, AtomicInteger state, PluginRegistry.Registrar registrar) {
    final MapboxMapController controller =
      new MapboxMapController(id, context, state, registrar, options, styleString);
    controller.init();
    controller.setMyLocationEnabled(myLocationEnabled);
    controller.setMyLocationTrackingMode(myLocationTrackingMode);
    controller.setMyLocationRenderMode(myLocationRenderMode);
    controller.setTrackCameraPosition(trackCameraPosition);
    return controller;
  }

  public void setInitialCameraPosition(CameraPosition position) {
    options.camera(position);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    options.compassEnabled(compassEnabled);
  }

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    Log.e(TAG, "setCameraTargetBounds is supported only after map initiated.");
    //throw new UnsupportedOperationException("setCameraTargetBounds is supported only after map initiated.");
    //options.latLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setStyleString(String styleString) {
    this.styleString = styleString;
    //options. styleString(styleString);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    if (min != null) {
      options.minZoomPreference(min);
    }
    if (max != null) {
      options.maxZoomPreference(max);
    }
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    options.rotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    options.scrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    options.tiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    options.zoomGesturesEnabled(zoomGesturesEnabled);
  }

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    this.myLocationEnabled = myLocationEnabled;
  }

  @Override
  public void setMyLocationTrackingMode(int myLocationTrackingMode) {
    this.myLocationTrackingMode = myLocationTrackingMode;
  }

  @Override
  public void setMyLocationRenderMode(int myLocationRenderMode) {
    this.myLocationRenderMode = myLocationRenderMode;
  }
  
  public void setLogoViewMargins(int x, int y) {
        options.logoMargins(new int[] {
            (int) x, //left
            (int) 0, //top
            (int) 0, //right
            (int) y, //bottom
    });
  }

  @Override
  public void setCompassViewMargins(int x, int y) {
    options.compassMargins(new int[] {
            (int) 0, //left
            (int) y, //top
            (int) x, //right
            (int) 0, //bottom
    });
  }

  @Override
  public void setAttributionButtonMargins(int x, int y) {
    options.attributionMargins(new int[] {
            (int) x, //left
            (int) 0, //top
            (int) 0, //right
            (int) y, //bottom
    });
  }
}
