// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import static com.mapbox.mapboxgl.MapboxMapsPlugin.CREATED;
import static com.mapbox.mapboxgl.MapboxMapsPlugin.DESTROYED;
import static com.mapbox.mapboxgl.MapboxMapsPlugin.PAUSED;
import static com.mapbox.mapboxgl.MapboxMapsPlugin.RESUMED;
import static com.mapbox.mapboxgl.MapboxMapsPlugin.STARTED;
import static com.mapbox.mapboxgl.MapboxMapsPlugin.STOPPED;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.graphics.PointF;

import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;

import com.mapbox.mapboxsdk.maps.MapboxMap;

import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;

import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.geojson.Feature;
import com.mapbox.mapboxsdk.plugins.annotation.OnSymbolClickListener;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;
import com.mapbox.mapboxsdk.style.expressions.Expression;

import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.location.LocationComponent;
import com.mapbox.mapboxsdk.location.LocationComponentOptions;
import com.mapbox.mapboxsdk.location.OnCameraTrackingChangedListener;
import com.mapbox.mapboxsdk.location.modes.CameraMode;
import com.mapbox.mapboxsdk.location.modes.RenderMode;
import com.mapbox.mapboxsdk.style.layers.RasterLayer;
import com.mapbox.mapboxsdk.style.sources.RasterSource;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.List;
import java.util.ArrayList;

import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import android.graphics.PointF;
import android.graphics.RectF;

/**
 * Controller of a single MapboxMaps MapView instance.
 */
final class MapboxMapController
  implements Application.ActivityLifecycleCallbacks,
  MapboxMap.OnCameraIdleListener,
  MapboxMap.OnCameraMoveListener,
  MapboxMap.OnCameraMoveStartedListener,
  OnSymbolClickListener,
  MapboxMap.OnMapClickListener,
  MapboxMapOptionsSink,
  MethodChannel.MethodCallHandler,
  com.mapbox.mapboxsdk.maps.OnMapReadyCallback,
  OnCameraTrackingChangedListener,
  OnSymbolTappedListener,
  PlatformView {
  private static final String TAG = "MapboxMapController";
  private final int id;
  private final AtomicInteger activityState;
  private final MethodChannel methodChannel;
  private final PluginRegistry.Registrar registrar;
  private final MapView mapView;
  private final Map<String, SymbolController> symbols;
  private MapboxMap mapboxMap;
  private SymbolManager symbolManager;
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private int myLocationTrackingMode = 0;
  private boolean disposed = false;
  private final float density;
  private MethodChannel.Result mapReadyResult;
  private final int registrarActivityHashCode;
  private final Context context;
  private final String styleStringInitial;
  private LocationComponent locationComponent = null;

  MapboxMapController(
    int id,
    Context context,
    AtomicInteger activityState,
    PluginRegistry.Registrar registrar,
    MapboxMapOptions options,
    String styleStringInitial) {
    Mapbox.getInstance(context, getAccessToken(context));
    this.id = id;
    this.context = context;
    this.activityState = activityState;
    this.registrar = registrar;
    this.styleStringInitial = styleStringInitial;
    this.mapView = new MapView(context, options);
    this.symbols = new HashMap<>();
    this.density = context.getResources().getDisplayMetrics().density;
    methodChannel =
      new MethodChannel(registrar.messenger(), "plugins.flutter.io/mapbox_maps_" + id);
    methodChannel.setMethodCallHandler(this);
    this.registrarActivityHashCode = registrar.activity().hashCode();
  }

  private static String getAccessToken(@NonNull Context context) {
    try {
      ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      Bundle bundle = ai.metaData;
      return bundle.getString("com.mapbox.token");
    } catch (PackageManager.NameNotFoundException e) {
      Log.e(TAG, "Failed to load meta-data, NameNotFound: " + e.getMessage());
    } catch (NullPointerException e) {
      Log.e(TAG, "Failed to load meta-data, NullPointer: " + e.getMessage());
    }
    return null;
  }

  @Override
  public View getView() {
    return mapView;
  }

  void init() {
    switch (activityState.get()) {
      case STOPPED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        mapView.onPause();
        mapView.onStop();
        break;
      case PAUSED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        mapView.onPause();
        break;
      case RESUMED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        break;
      case STARTED:
        mapView.onCreate(null);
        mapView.onStart();
        break;
      case CREATED:
        mapView.onCreate(null);
        break;
      case DESTROYED:
        mapboxMap.removeOnCameraIdleListener(this);
        mapboxMap.removeOnCameraMoveStartedListener(this);
        mapboxMap.removeOnCameraMoveListener(this);
        mapView.onDestroy();
        break;
      default:
        throw new IllegalArgumentException(
          "Cannot interpret " + activityState.get() + " as an activity state");
    }
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(this);
    mapView.getMapAsync(this);
  }

  private void moveCamera(CameraUpdate cameraUpdate) {
    mapboxMap.moveCamera(cameraUpdate);
  }

  private void animateCamera(CameraUpdate cameraUpdate) {
    mapboxMap.animateCamera(cameraUpdate);
  }

  private CameraPosition getCameraPosition() {
    return trackCameraPosition ? mapboxMap.getCameraPosition() : null;
  }

  private SymbolBuilder newSymbolBuilder() {
    return new SymbolBuilder(symbolManager);
  }

  private void removeSymbol(String symbolId) {
    final SymbolController symbolController = symbols.remove(symbolId);
    if (symbolController != null) {
      symbolController.remove(symbolManager);
    }
  }

  private SymbolController symbol(String symbolId) {
    final SymbolController symbol = symbols.get(symbolId);
    if (symbol == null) {
      throw new IllegalArgumentException("Unknown symbol: " + symbolId);
    }
    return symbol;
  }

  @Override
  public void onMapReady(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    if (mapReadyResult != null) {
      mapReadyResult.success(null);
      mapReadyResult = null;
    }
    mapboxMap.addOnCameraMoveStartedListener(this);
    mapboxMap.addOnCameraMoveListener(this);
    mapboxMap.addOnCameraIdleListener(this);
    setStyleString(styleStringInitial);
    // updateMyLocationEnabled();
  }

  @Override
  public void setStyleString(String styleString) {
    //check if json, url or plain string:
    if (styleString == null || styleString.isEmpty()) {
      Log.e(TAG, "setStyleString - string empty or null");
    } else if (styleString.startsWith("{") || styleString.startsWith("[")) {
      mapboxMap.setStyle(new Style.Builder().fromJson(styleString), onStyleLoadedCallback);
    } else {
      mapboxMap.setStyle(new Style.Builder().fromUrl(styleString), onStyleLoadedCallback);
    }
  }

  Style.OnStyleLoaded onStyleLoadedCallback = new Style.OnStyleLoaded() {
    @Override
    public void onStyleLoaded(@NonNull Style style) {
      enableSymbolManager(style);
      enableLocationComponent(style);
      // needs to be placed after SymbolManager#addClickListener,
      // is fixed with 0.6.0 of annotations plugin
      mapboxMap.addOnMapClickListener(MapboxMapController.this);
    }
  };

  @SuppressWarnings( {"MissingPermission"})
  private void enableLocationComponent(@NonNull Style style) {
    if (hasLocationPermission()) {
      LocationComponentOptions locationComponentOptions = LocationComponentOptions.builder(context)
        .trackingGesturesManagement(true)
        .build();
      locationComponent = mapboxMap.getLocationComponent();
      locationComponent.activateLocationComponent(context, style, locationComponentOptions);
      locationComponent.setLocationComponentEnabled(true);
      locationComponent.setRenderMode(RenderMode.COMPASS);
      updateMyLocationTrackingMode();
      setMyLocationTrackingMode(this.myLocationTrackingMode);
      locationComponent.addOnCameraTrackingChangedListener(this);
    } else {
      Log.e(TAG, "missing location permissions");
    }
  }

  private void enableSymbolManager(@NonNull Style style) {
    if (symbolManager == null) {
      symbolManager = new SymbolManager(mapView, mapboxMap, style);
      symbolManager.setIconAllowOverlap(true);
      symbolManager.setIconIgnorePlacement(true);
      symbolManager.setTextAllowOverlap(true);
      symbolManager.setTextIgnorePlacement(true);
      symbolManager.addClickListener(this);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "map#waitForMap":
        if (mapboxMap != null) {
          result.success(null);
          return;
        }
        mapReadyResult = result;
        break;
      case "map#update": {
        Convert.interpretMapboxMapOptions(call.argument("options"), this);
        result.success(Convert.toJson(getCameraPosition()));
        break;
      }
      case "camera#move": {
        final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
        if (cameraUpdate != null) {
          // camera transformation not handled yet
          moveCamera(cameraUpdate);
        }
        result.success(null);
        break;
      }
      case "camera#animate": {
        final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
        if (cameraUpdate != null) {
          // camera transformation not handled yet
          animateCamera(cameraUpdate);
        }
        result.success(null);
        break;
      }
      case "map#queryRenderedFeatures": {
        Map<String, Object> reply = new HashMap<>();
        List<Feature> features;

        String[] layerIds = ((List<String>) call.argument("layerIds")).toArray(new String[0]);

        String filter = (String) call.argument("filter");

        Expression filterExpression = filter == null ? null : new Expression(filter);
        if (call.hasArgument("x")) {
          Double x = call.argument("x");
          Double y = call.argument("y");
          PointF pixel = new PointF(x.floatValue(), y.floatValue());
          features = mapboxMap.queryRenderedFeatures(pixel, filterExpression, layerIds);
        } else {
          Double left = call.argument("left");
          Double top = call.argument("top");
          Double right = call.argument("right");
          Double bottom = call.argument("bottom");
          RectF rectF = new RectF(left.floatValue(), top.floatValue(), right.floatValue(), bottom.floatValue());
          features = mapboxMap.queryRenderedFeatures(rectF, filterExpression, layerIds);
        }
        List<String> featuresJson = new ArrayList<>();
        for (Feature feature : features) {
          featuresJson.add(feature.toJson());
        }
        reply.put("features", featuresJson);
        result.success(reply);
        break;
      }
      case "symbol#add": {
        final SymbolBuilder symbolBuilder = newSymbolBuilder();
        Convert.interpretSymbolOptions(call.argument("options"), symbolBuilder);
        final Symbol symbol = symbolBuilder.build();
        final String symbolId = String.valueOf(symbol.getId());
        symbols.put(symbolId, new SymbolController(symbol, true, this));
        result.success(symbolId);
        break;
      }
      case "symbol#remove": {
        final String symbolId = call.argument("symbol");
        removeSymbol(symbolId);
        result.success(null);
        break;
      }
      case "symbol#update": {
        final String symbolId = call.argument("symbol");
        final SymbolController symbol = symbol(symbolId);
        Convert.interpretSymbolOptions(call.argument("options"), symbol);
        symbol.update(symbolManager);
        result.success(null);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    final Map<String, Object> arguments = new HashMap<>(2);
    boolean isGesture = reason == MapboxMap.OnCameraMoveStartedListener.REASON_API_GESTURE;
    arguments.put("isGesture", isGesture);
    methodChannel.invokeMethod("camera#onMoveStarted", arguments);
  }

  @Override
  public void onCameraMove() {
    if (!trackCameraPosition) {
      return;
    }
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.toJson(mapboxMap.getCameraPosition()));
    methodChannel.invokeMethod("camera#onMove", arguments);
  }

  @Override
  public void onCameraIdle() {
    methodChannel.invokeMethod("camera#onIdle", Collections.singletonMap("map", id));
  }

  @Override
  public void onCameraTrackingChanged(int currentMode) {
  }

  @Override
  public void onCameraTrackingDismissed() {
    methodChannel.invokeMethod("map#onCameraTrackingDismissed", new HashMap<>());
  }

  @Override
  public void onAnnotationClick(Symbol symbol) {
    final SymbolController symbolController = symbols.get(String.valueOf(symbol.getId()));
    if (symbolController != null) {
      symbolController.onTap();
    }
  }

  @Override
  public void onSymbolTapped(Symbol symbol) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("symbol", String.valueOf(symbol.getId()));
    methodChannel.invokeMethod("symbol#onTap", arguments);
  }

  @Override
  public boolean onMapClick(@NonNull LatLng point) {
    PointF pointf = mapboxMap.getProjection().toScreenLocation(point);
    final Map<String, Object> arguments = new HashMap<>(5);
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("lng", point.getLongitude());
    arguments.put("lat", point.getLatitude());
    methodChannel.invokeMethod("map#onMapClick", arguments);
    return true;
  }

  @Override
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    if (locationComponent != null) {
      locationComponent.setLocationComponentEnabled(false);
    }
    if (symbolManager != null) {
      symbolManager.onDestroy();
    }
    mapView.onDestroy();
    registrar.activity().getApplication().unregisterActivityLifecycleCallbacks(this);
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onCreate(savedInstanceState);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onActivityResumed(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onResume();
  }

  @Override
  public void onActivityPaused(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onPause();
  }

  @Override
  public void onActivityStopped(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onStop();
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onSaveInstanceState(outState);
  }

  @Override
  public void onActivityDestroyed(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onDestroy();
  }

  // MapboxMapOptionsSink methods

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    mapboxMap.setLatLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    mapboxMap.getUiSettings().setCompassEnabled(compassEnabled);
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    mapboxMap.getUiSettings().setRotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    mapboxMap.getUiSettings().setScrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    mapboxMap.getUiSettings().setTiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    //mapboxMap.resetMinMaxZoomPreference();
    if (min != null) {
      mapboxMap.setMinZoomPreference(min);
    }
    if (max != null) {
      mapboxMap.setMaxZoomPreference(max);
    }
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    mapboxMap.getUiSettings().setZoomGesturesEnabled(zoomGesturesEnabled);
  }

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    if (this.myLocationEnabled == myLocationEnabled) {
      return;
    }
    this.myLocationEnabled = myLocationEnabled;
    if (mapboxMap != null) {
      updateMyLocationEnabled();
    }
  }

  @Override
  public void setMyLocationTrackingMode(int myLocationTrackingMode) {
    if (this.myLocationTrackingMode == myLocationTrackingMode) {
      return;
    }
    this.myLocationTrackingMode = myLocationTrackingMode;
    if (mapboxMap != null && locationComponent != null) {
      updateMyLocationTrackingMode();
    }
  }

  private void updateMyLocationEnabled() {
    //TODO: call location initialization if changed to true and not initialized yet.;
    //Show/Hide use location as needed
  }

  private void updateMyLocationTrackingMode() {
    int[] mapboxTrackingModes = new int[] {CameraMode.NONE, CameraMode.TRACKING, CameraMode.TRACKING_COMPASS, CameraMode.TRACKING_GPS};
    locationComponent.setCameraMode(mapboxTrackingModes[this.myLocationTrackingMode]);
  }

  private boolean hasLocationPermission() {
    return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
      == PackageManager.PERMISSION_GRANTED
      || checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
      == PackageManager.PERMISSION_GRANTED;
  }

  private int checkSelfPermission(String permission) {
    if (permission == null) {
      throw new IllegalArgumentException("permission is null");
    }
    return context.checkPermission(
      permission, android.os.Process.myPid(), android.os.Process.myUid());
  }

}
