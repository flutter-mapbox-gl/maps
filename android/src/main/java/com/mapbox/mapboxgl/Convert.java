// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.graphics.Point;

import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Conversions between JSON-like values and MapboxMaps data types. */
class Convert {
//  private static BitmapDescriptor toBitmapDescriptor(Object o) {
//    final List<?> data = toList(o);
//    switch (toString(data.get(0))) {
//      case "defaultMarker":
//        if (data.size() == 1) {
//          return BitmapDescriptorFactory.defaultMarker();
//        } else {
//          return BitmapDescriptorFactory.defaultMarker(toFloat(data.get(1)));
//        }
//      case "fromAsset":
//        if (data.size() == 2) {
//          return BitmapDescriptorFactory.fromAsset(
//              FlutterMain.getLookupKeyForAsset(toString(data.get(1))));
//        } else {
//          return BitmapDescriptorFactory.fromAsset(
//              FlutterMain.getLookupKeyForAsset(toString(data.get(1)), toString(data.get(2))));
//        }
//      default:
//        throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
//    }
//  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = new CameraPosition.Builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  static boolean isScrollByCameraUpdate(Object o){
    return toString(toList(o).get(0)).equals("scrollBy");
  }

  static CameraUpdate toCameraUpdate(Object o, MapboxMap mapboxMap, float density) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(
          toLatLngBounds(data.get(1)), toPixels(data.get(2), density));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        mapboxMap.scrollBy(
          toFractionalPixels(data.get(1), density),
          toFractionalPixels(data.get(2), density)
        );
        return null;
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
      case "bearingTo":
        return CameraUpdateFactory.bearingTo(toFloat(data.get(1)));
      case "tiltTo":
        return CameraUpdateFactory.tiltTo(toFloat(data.get(1)));
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
    }
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static Float toFloatWrapper(Object o) {
    return (o == null) ? null : toFloat(o);
  }

  static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  static Object toJson(CameraPosition position) {
    if (position == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("bearing", position.bearing);
    data.put("target", toJson(position.target));
    data.put("tilt", position.tilt);
    data.put("zoom", position.zoom);
    return data;
  }

  private static Object toJson(LatLng latLng) {
    return Arrays.asList(latLng.getLatitude(), latLng.getLongitude());
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    LatLng[] boundsArray = new LatLng[]{toLatLng(data.get(0)), toLatLng(data.get(1))};
    List<LatLng> bounds = Arrays.asList(boundsArray);
    LatLngBounds.Builder builder = new LatLngBounds.Builder();
    builder.includes(bounds);
    return builder.build();
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  static long toLong(Object o) {
    return ((Number) o).longValue();
  }

  static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static float toFractionalPixels(Object o, float density) {
    return toFloat(o) * density;
  }

  static int toPixels(Object o, float density) {
    return (int) toFractionalPixels(o, density);
  }

  private static Point toPoint(Object o, float density) {
    final List<?> data = toList(o);
    return new Point(toPixels(data.get(0), density), toPixels(data.get(1), density));
  }

  private static String toString(Object o) {
    return (String) o;
  }

  static void interpretMapboxMapOptions(Object o, MapboxMapOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object cameraTargetBounds = data.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      sink.setCameraTargetBounds(toLatLngBounds(targetData.get(0)));
    }
    final Object compassEnabled = data.get("compassEnabled");
    if (compassEnabled != null) {
      sink.setCompassEnabled(toBoolean(compassEnabled));
    }
    final Object styleString = data.get("styleString");
    if (styleString != null) {
      sink.setStyleString(toString(styleString));
    }
    final Object minMaxZoomPreference = data.get("minMaxZoomPreference");
    if (minMaxZoomPreference != null) {
      final List<?> zoomPreferenceData = toList(minMaxZoomPreference);
      sink.setMinMaxZoomPreference( //
        toFloatWrapper(zoomPreferenceData.get(0)), //
        toFloatWrapper(zoomPreferenceData.get(1)));
    }
    final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object trackCameraPosition = data.get("trackCameraPosition");
    if (trackCameraPosition != null) {
      sink.setTrackCameraPosition(toBoolean(trackCameraPosition));
    }
    final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    final Object myLocationEnabled = data.get("myLocationEnabled");
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
    }
    final Object myLocationTrackingMode = data.get("myLocationTrackingMode");
    if (myLocationTrackingMode != null) {
      sink.setMyLocationTrackingMode(toInt(myLocationTrackingMode));
    }
  }

//  static void interpretMarkerOptions(Object o, MarkerOptionsSink sink) {
//    final Map<?, ?> data = toMap(o);
//    final Object alpha = data.get("alpha");
//    if (alpha != null) {
//      sink.setAlpha(toFloat(alpha));
//    }
//    final Object anchor = data.get("anchor");
//    if (anchor != null) {
//      final List<?> anchorData = toList(anchor);
//      sink.setAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
//    }
//    final Object consumesTapEvents = data.get("consumesTapEvents");
//    if (consumesTapEvents != null) {
//      sink.setConsumeTapEvents(toBoolean(consumesTapEvents));
//    }
//    final Object draggable = data.get("draggable");
//    if (draggable != null) {
//      sink.setDraggable(toBoolean(draggable));
//    }
//    final Object flat = data.get("flat");
//    if (flat != null) {
//      sink.setFlat(toBoolean(flat));
//    }
//    final Object icon = data.get("icon");
//    if (icon != null) {
//      sink.setIcon(toBitmapDescriptor(icon));
//    }
//    final Object infoWindowAnchor = data.get("infoWindowAnchor");
//    if (infoWindowAnchor != null) {
//      final List<?> anchorData = toList(infoWindowAnchor);
//      sink.setInfoWindowAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
//    }
//    final Object infoWindowText = data.get("infoWindowText");
//    if (infoWindowText != null) {
//      final List<?> textData = toList(infoWindowText);
//      sink.setInfoWindowText(toString(textData.get(0)), toString(textData.get(1)));
//    }
//    final Object position = data.get("position");
//    if (position != null) {
//      sink.setPosition(toLatLng(position));
//    }
//    final Object rotation = data.get("rotation");
//    if (rotation != null) {
//      sink.setRotation(toFloat(rotation));
//    }
//    final Object visible = data.get("visible");
//    if (visible != null) {
//      sink.setVisible(toBoolean(visible));
//    }
//    final Object zIndex = data.get("zIndex");
//    if (zIndex != null) {
//      sink.setZIndex(toFloat(zIndex));
//    }
//  }
}