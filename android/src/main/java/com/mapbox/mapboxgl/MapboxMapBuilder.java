// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.content.Context;
import android.view.Gravity;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;
import com.mapbox.mapboxsdk.maps.Style;
import io.flutter.plugin.common.BinaryMessenger;

class MapboxMapBuilder implements MapboxMapOptionsSink {
  public final String TAG = getClass().getSimpleName();
  private final MapboxMapOptions options = new MapboxMapOptions().attributionEnabled(true);
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private boolean dragEnabled = true;
  private int myLocationTrackingMode = 0;
  private int myLocationRenderMode = 0;
  private String styleString = Style.MAPBOX_STREETS;
  private LatLngBounds bounds = null;

  MapboxMapController build(
      int id,
      Context context,
      BinaryMessenger messenger,
      MapboxMapsPlugin.LifecycleProvider lifecycleProvider,
      String accessToken) {
    final MapboxMapController controller =
        new MapboxMapController(
            id,
            context,
            messenger,
            lifecycleProvider,
            options,
            accessToken,
            styleString,
            dragEnabled);
    controller.init();
    controller.setMyLocationEnabled(myLocationEnabled);
    controller.setMyLocationTrackingMode(myLocationTrackingMode);
    controller.setMyLocationRenderMode(myLocationRenderMode);
    controller.setTrackCameraPosition(trackCameraPosition);

    if (null != bounds) {
      controller.setCameraTargetBounds(bounds);
    }

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
    this.bounds = bounds;
  }

  @Override
  public void setStyleString(String styleString) {
    this.styleString = styleString;
    // options. styleString(styleString);
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
    options.logoMargins(
        new int[] {
          (int) x, // left
          (int) 0, // top
          (int) 0, // right
          (int) y, // bottom
        });
  }

  @Override
  public void setCompassGravity(int gravity) {
    switch (gravity) {
      case 0:
        options.compassGravity(Gravity.TOP | Gravity.START);
        break;
      case 1:
        options.compassGravity(Gravity.TOP | Gravity.END);
        break;
      case 2:
        options.compassGravity(Gravity.BOTTOM | Gravity.START);
        break;
      case 3:
        options.compassGravity(Gravity.BOTTOM | Gravity.END);
        break;
    }
  }

  @Override
  public void setCompassViewMargins(int x, int y) {
    switch (options.getCompassGravity()) {
      case Gravity.TOP | Gravity.START:
        options.compassMargins(new int[] {(int) x, (int) y, 0, 0});
        break;
        // If the application code has not specified gravity, assume the platform
        // default for the compass which is top-right
      default:
      case Gravity.TOP | Gravity.END:
        options.compassMargins(new int[] {0, (int) y, (int) x, 0});
        break;
      case Gravity.BOTTOM | Gravity.START:
        options.compassMargins(new int[] {(int) x, 0, 0, (int) y});
        break;
      case Gravity.BOTTOM | Gravity.END:
        options.compassMargins(new int[] {0, 0, (int) x, (int) y});
        break;
    }
  }

  @Override
  public void setAttributionButtonGravity(int gravity) {
    switch (gravity) {
      case 0:
        options.attributionGravity(Gravity.TOP | Gravity.START);
        break;
      case 1:
        options.attributionGravity(Gravity.TOP | Gravity.END);
        break;
      case 2:
        options.attributionGravity(Gravity.BOTTOM | Gravity.START);
        break;
      case 3:
        options.attributionGravity(Gravity.BOTTOM | Gravity.END);
        break;
    }
  }

  @Override
  public void setAttributionButtonMargins(int x, int y) {
    switch (options.getAttributionGravity()) {
      case Gravity.TOP | Gravity.START:
        options.attributionMargins(new int[] {(int) x, (int) y, 0, 0});
        break;
      case Gravity.TOP | Gravity.END:
        options.attributionMargins(new int[] {0, (int) y, (int) x, 0});
        break;
        // If the application code has not specified gravity, assume the platform
        // default for the attribution button which is bottom left
      default:
      case Gravity.BOTTOM | Gravity.START:
        options.attributionMargins(new int[] {(int) x, 0, 0, (int) y});
        break;
      case Gravity.BOTTOM | Gravity.END:
        options.attributionMargins(new int[] {0, 0, (int) x, (int) y});
        break;
    }
  }

  public void setDragEnabled(boolean enabled) {
    this.dragEnabled = enabled;
  }
}
