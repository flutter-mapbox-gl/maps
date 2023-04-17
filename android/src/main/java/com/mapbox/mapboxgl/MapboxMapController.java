// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;
import android.graphics.RectF;
import android.location.Location;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.mapbox.android.core.location.LocationEngine;
import com.mapbox.android.core.location.LocationEngineCallback;
import com.mapbox.android.core.location.LocationEngineProvider;
import com.mapbox.android.core.location.LocationEngineResult;
import com.mapbox.android.gestures.AndroidGesturesManager;
import com.mapbox.android.gestures.MoveGestureDetector;
import com.mapbox.android.telemetry.TelemetryEnabler;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.constants.MapboxConstants;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.geometry.LatLngQuad;
import com.mapbox.mapboxsdk.geometry.VisibleRegion;
import com.mapbox.mapboxsdk.location.LocationComponent;
import com.mapbox.mapboxsdk.location.LocationComponentOptions;
import com.mapbox.mapboxsdk.location.OnCameraTrackingChangedListener;
import com.mapbox.mapboxsdk.location.modes.CameraMode;
import com.mapbox.mapboxsdk.location.modes.RenderMode;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;
import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.mapboxsdk.offline.OfflineManager;
import com.mapbox.mapboxsdk.plugins.localization.LocalizationPlugin;
import com.mapbox.mapboxsdk.snapshotter.MapSnapshotter;
import com.mapbox.mapboxsdk.storage.FileSource;
import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.CircleLayer;
import com.mapbox.mapboxsdk.style.layers.FillExtrusionLayer;
import com.mapbox.mapboxsdk.style.layers.FillLayer;
import com.mapbox.mapboxsdk.style.layers.HeatmapLayer;
import com.mapbox.mapboxsdk.style.layers.HillshadeLayer;
import com.mapbox.mapboxsdk.style.layers.Layer;
import com.mapbox.mapboxsdk.style.layers.LineLayer;
import com.mapbox.mapboxsdk.style.layers.PropertyValue;
import com.mapbox.mapboxsdk.style.layers.RasterLayer;
import com.mapbox.mapboxsdk.style.layers.SymbolLayer;
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource;
import com.mapbox.mapboxsdk.style.sources.ImageSource;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/** Controller of a single MapboxMaps MapView instance. */
@SuppressLint("MissingPermission")
final class MapboxMapController
    implements DefaultLifecycleObserver,
        MapboxMap.OnCameraIdleListener,
        MapboxMap.OnCameraMoveListener,
        MapboxMap.OnCameraMoveStartedListener,
        MapView.OnDidBecomeIdleListener,
        MapboxMap.OnMapClickListener,
        MapboxMap.OnMapLongClickListener,
        MapboxMapOptionsSink,
        MethodChannel.MethodCallHandler,
        OnMapReadyCallback,
        OnCameraTrackingChangedListener,
        PlatformView {

  private static final String TAG = "MapboxMapController";
  private final int id;
  private final MethodChannel methodChannel;
  private final MapboxMapsPlugin.LifecycleProvider lifecycleProvider;
  private final float density;
  private final Context context;
  private final String styleStringInitial;
  private final Set<String> interactiveFeatureLayerIds;
  private final Map<String, FeatureCollection> addedFeaturesByLayer;
  private final Map<String, MapSnapshotter> mSnapshotterMap;
  private MapView mapView;
  private MapboxMap mapboxMap;
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private int myLocationTrackingMode = 0;
  private int myLocationRenderMode = 0;
  private boolean disposed = false;
  private boolean dragEnabled = true;
  private MethodChannel.Result mapReadyResult;
  private LocationComponent locationComponent = null;
  private LocationEngine locationEngine = null;
  private LocationEngineCallback<LocationEngineResult> locationEngineCallback = null;
  private LocalizationPlugin localizationPlugin;
  private Style style;
  private Feature draggedFeature;
  private AndroidGesturesManager androidGesturesManager;
  private LatLng dragOrigin;
  private LatLng dragPrevious;
  private LatLngBounds bounds = null;
  Style.OnStyleLoaded onStyleLoadedCallback =
      new Style.OnStyleLoaded() {
        @Override
        public void onStyleLoaded(@NonNull Style style) {
          MapboxMapController.this.style = style;

          updateMyLocationEnabled();

          if (null != bounds) {
            mapboxMap.setLatLngBoundsForCameraTarget(bounds);
          }

          mapboxMap.addOnMapClickListener(MapboxMapController.this);
          mapboxMap.addOnMapLongClickListener(MapboxMapController.this);
          localizationPlugin = new LocalizationPlugin(mapView, mapboxMap, style);

          methodChannel.invokeMethod("map#onStyleLoaded", null);
        }
      };

  MapboxMapController(
      int id,
      Context context,
      BinaryMessenger messenger,
      MapboxMapsPlugin.LifecycleProvider lifecycleProvider,
      MapboxMapOptions options,
      String accessToken,
      String styleStringInitial,
      boolean dragEnabled) {
    MapBoxUtils.getMapbox(context, accessToken);
    this.id = id;
    this.context = context;
    this.dragEnabled = dragEnabled;
    this.styleStringInitial = styleStringInitial;
    this.mapView = new MapView(context, options);
    this.interactiveFeatureLayerIds = new HashSet<>();
    this.addedFeaturesByLayer = new HashMap<String, FeatureCollection>();
    this.density = context.getResources().getDisplayMetrics().density;
    this.lifecycleProvider = lifecycleProvider;
    if (dragEnabled) {
      this.androidGesturesManager = new AndroidGesturesManager(this.mapView.getContext(), false);
    }
    this.mSnapshotterMap = new HashMap<>();
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/mapbox_maps_" + id);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public View getView() {
    return mapView;
  }

  void init() {
    lifecycleProvider.getLifecycle().addObserver(this);
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

    if (androidGesturesManager != null) {
      androidGesturesManager.setMoveGestureListener(new MoveGestureListener());
      mapView.setOnTouchListener(
          new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
              androidGesturesManager.onTouchEvent(event);

              return draggedFeature != null;
            }
          });
    }

    mapView.addOnStyleImageMissingListener(
        (id) -> {
          DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
          final Bitmap bitmap = getScaledImage(id, displayMetrics.density);
          if (bitmap != null) {
            mapboxMap.getStyle().addImage(id, bitmap);
          }
        });

    mapView.addOnDidBecomeIdleListener(this);

    setStyleString(styleStringInitial);
  }

  @Override
  public void setStyleString(String styleString) {
    // clear old layer id from the location Component
    clearLocationComponentLayer();

    // Check if json, url, absolute path or asset path:
    if (styleString == null || styleString.isEmpty()) {
      Log.e(TAG, "setStyleString - string empty or null");
    } else if (styleString.startsWith("{") || styleString.startsWith("[")) {
      mapboxMap.setStyle(new Style.Builder().fromJson(styleString), onStyleLoadedCallback);
    } else if (styleString.startsWith("/")) {
      // Absolute path
      mapboxMap.setStyle(
          new Style.Builder().fromUri("file://" + styleString), onStyleLoadedCallback);
    } else if (!styleString.startsWith("http://")
        && !styleString.startsWith("https://")
        && !styleString.startsWith("mapbox://")) {
      // We are assuming that the style will be loaded from an asset here.
      String key = MapboxMapsPlugin.flutterAssets.getAssetFilePathByName(styleString);
      mapboxMap.setStyle(new Style.Builder().fromUri("asset://" + key), onStyleLoadedCallback);
    } else {
      mapboxMap.setStyle(new Style.Builder().fromUri(styleString), onStyleLoadedCallback);
    }
  }

  @SuppressWarnings({"MissingPermission"})
  private void enableLocationComponent(@NonNull Style style) {
    if (hasLocationPermission()) {
      locationEngine = LocationEngineProvider.getBestLocationEngine(context);
      locationComponent = mapboxMap.getLocationComponent();
      locationComponent.activateLocationComponent(
          context, style, buildLocationComponentOptions(style));
      locationComponent.setLocationComponentEnabled(true);
      // locationComponent.setRenderMode(RenderMode.COMPASS); // remove or keep default?
      locationComponent.setLocationEngine(locationEngine);
      locationComponent.setMaxAnimationFps(30);
      updateMyLocationTrackingMode();
      updateMyLocationRenderMode();
      locationComponent.addOnCameraTrackingChangedListener(this);
    } else {
      Log.e(TAG, "missing location permissions");
    }
  }

  private void updateLocationComponentLayer() {
    if (locationComponent != null && locationComponentRequiresUpdate()) {
      locationComponent.applyStyle(buildLocationComponentOptions(style));
    }
  }

  private void clearLocationComponentLayer() {
    if (locationComponent != null) {
      locationComponent.applyStyle(buildLocationComponentOptions(null));
    }
  }

  String getLastLayerOnStyle(Style style) {
    if (style != null) {
      final List<Layer> layers = style.getLayers();

      if (layers.size() > 0) {
        return layers.get(layers.size() - 1).getId();
      }
    }
    return null;
  }

  /// only update if the last layer is not the mapbox-location-bearing-layer
  boolean locationComponentRequiresUpdate() {
    final String lastLayerId = getLastLayerOnStyle(style);
    return lastLayerId != null && !lastLayerId.equals("mapbox-location-bearing-layer");
  }

  private LocationComponentOptions buildLocationComponentOptions(Style style) {
    final LocationComponentOptions.Builder optionsBuilder =
        LocationComponentOptions.builder(context);
    optionsBuilder.trackingGesturesManagement(true);

    final String lastLayerId = getLastLayerOnStyle(style);
    if (lastLayerId != null) {
      optionsBuilder.layerAbove(lastLayerId);
    }
    return optionsBuilder.build();
  }

  private void onUserLocationUpdate(Location location) {
    if (location == null) {
      return;
    }

    final Map<String, Object> userLocation = new HashMap<>(6);
    userLocation.put("position", new double[] {location.getLatitude(), location.getLongitude()});
    userLocation.put("speed", location.getSpeed());
    userLocation.put("altitude", location.getAltitude());
    userLocation.put("bearing", location.getBearing());
    userLocation.put("horizontalAccuracy", location.getAccuracy());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      userLocation.put(
          "verticalAccuracy",
          (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
              ? location.getVerticalAccuracyMeters()
              : null);
    }
    userLocation.put("timestamp", location.getTime());

    final Map<String, Object> arguments = new HashMap<>(1);
    arguments.put("userLocation", userLocation);
    methodChannel.invokeMethod("map#onUserLocationUpdated", arguments);
  }

  private void addGeoJsonSource(String sourceName, String source) {
    FeatureCollection featureCollection = FeatureCollection.fromJson(source);
    GeoJsonSource geoJsonSource = new GeoJsonSource(sourceName, featureCollection);
    addedFeaturesByLayer.put(sourceName, featureCollection);

    style.addSource(geoJsonSource);
  }

  private void setGeoJsonSource(String sourceName, String geojson) {
    FeatureCollection featureCollection = FeatureCollection.fromJson(geojson);
    GeoJsonSource geoJsonSource = style.getSourceAs(sourceName);
    addedFeaturesByLayer.put(sourceName, featureCollection);

    geoJsonSource.setGeoJson(featureCollection);
  }

  private void setGeoJsonFeature(String sourceName, String geojsonFeature) {
    Feature feature = Feature.fromJson(geojsonFeature);
    FeatureCollection featureCollection = addedFeaturesByLayer.get(sourceName);
    GeoJsonSource geoJsonSource = style.getSourceAs(sourceName);
    if (featureCollection != null && geoJsonSource != null) {
      final List<Feature> features = featureCollection.features();
      for (int i = 0; i < features.size(); i++) {
        final String id = features.get(i).id();
        if (id.equals(feature.id())) {
          features.set(i, feature);
          break;
        }
      }

      geoJsonSource.setGeoJson(featureCollection);
    }
  }

  private void addSymbolLayer(
      String layerName,
      String sourceName,
      String belowLayerId,
      String sourceLayer,
      Float minZoom,
      Float maxZoom,
      PropertyValue[] properties,
      boolean enableInteraction,
      Expression filter) {

    SymbolLayer symbolLayer = new SymbolLayer(layerName, sourceName);
    symbolLayer.setProperties(properties);
    if (sourceLayer != null) {
      symbolLayer.setSourceLayer(sourceLayer);
    }
    if (minZoom != null) {
      symbolLayer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      symbolLayer.setMaxZoom(maxZoom);
    }
    if (filter != null) {
      symbolLayer.setFilter(filter);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(symbolLayer, belowLayerId);
    } else {
      style.addLayer(symbolLayer);
    }
    if (enableInteraction) {
      interactiveFeatureLayerIds.add(layerName);
    }
  }

  private void addLineLayer(
      String layerName,
      String sourceName,
      String belowLayerId,
      String sourceLayer,
      Float minZoom,
      Float maxZoom,
      PropertyValue[] properties,
      boolean enableInteraction,
      Expression filter) {
    LineLayer lineLayer = new LineLayer(layerName, sourceName);
    lineLayer.setProperties(properties);
    if (sourceLayer != null) {
      lineLayer.setSourceLayer(sourceLayer);
    }
    if (minZoom != null) {
      lineLayer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      lineLayer.setMaxZoom(maxZoom);
    }
    if (filter != null) {
      lineLayer.setFilter(filter);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(lineLayer, belowLayerId);
    } else {
      style.addLayer(lineLayer);
    }
    if (enableInteraction) {
      interactiveFeatureLayerIds.add(layerName);
    }
  }

  private void addFillLayer(
      String layerName,
      String sourceName,
      String belowLayerId,
      String sourceLayer,
      Float minZoom,
      Float maxZoom,
      PropertyValue[] properties,
      boolean enableInteraction,
      Expression filter) {
    FillLayer fillLayer = new FillLayer(layerName, sourceName);
    fillLayer.setProperties(properties);
    if (sourceLayer != null) {
      fillLayer.setSourceLayer(sourceLayer);
    }
    if (minZoom != null) {
      fillLayer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      fillLayer.setMaxZoom(maxZoom);
    }
    if (filter != null) {
      fillLayer.setFilter(filter);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(fillLayer, belowLayerId);
    } else {
      style.addLayer(fillLayer);
    }
    if (enableInteraction) {
      interactiveFeatureLayerIds.add(layerName);
    }
  }

  private void addFillExtrusionLayer(
      String layerName,
      String sourceName,
      String belowLayerId,
      String sourceLayer,
      Float minZoom,
      Float maxZoom,
      PropertyValue[] properties,
      boolean enableInteraction,
      Expression filter) {
    FillExtrusionLayer fillLayer = new FillExtrusionLayer(layerName, sourceName);
    fillLayer.setProperties(properties);
    if (sourceLayer != null) {
      fillLayer.setSourceLayer(sourceLayer);
    }
    if (minZoom != null) {
      fillLayer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      fillLayer.setMaxZoom(maxZoom);
    }
    if (filter != null) {
      fillLayer.setFilter(filter);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(fillLayer, belowLayerId);
    } else {
      style.addLayer(fillLayer);
    }
    if (enableInteraction) {
      interactiveFeatureLayerIds.add(layerName);
    }
  }

  private void addCircleLayer(
      String layerName,
      String sourceName,
      String belowLayerId,
      String sourceLayer,
      Float minZoom,
      Float maxZoom,
      PropertyValue[] properties,
      boolean enableInteraction,
      Expression filter) {
    CircleLayer circleLayer = new CircleLayer(layerName, sourceName);
    circleLayer.setProperties(properties);
    if (sourceLayer != null) {
      circleLayer.setSourceLayer(sourceLayer);
    }
    if (minZoom != null) {
      circleLayer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      circleLayer.setMaxZoom(maxZoom);
    }
    if (filter != null) {
      circleLayer.setFilter(filter);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(circleLayer, belowLayerId);
    } else {
      style.addLayer(circleLayer);
    }
    if (enableInteraction) {
      interactiveFeatureLayerIds.add(layerName);
    }
  }

  private Expression parseFilter(String filter) {
    JsonParser parser = new JsonParser();
    JsonElement filterJsonElement = parser.parse(filter);
    return filterJsonElement.isJsonNull() ? null : Expression.Converter.convert(filterJsonElement);
  }

  private void addRasterLayer(
      String layerName,
      String sourceName,
      Float minZoom,
      Float maxZoom,
      String belowLayerId,
      PropertyValue[] properties,
      Expression filter) {
    RasterLayer layer = new RasterLayer(layerName, sourceName);
    layer.setProperties(properties);
    if (minZoom != null) {
      layer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      layer.setMaxZoom(maxZoom);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(layer, belowLayerId);
    } else {
      style.addLayer(layer);
    }
  }

  private void addHillshadeLayer(
      String layerName,
      String sourceName,
      Float minZoom,
      Float maxZoom,
      String belowLayerId,
      PropertyValue[] properties,
      Expression filter) {
    HillshadeLayer layer = new HillshadeLayer(layerName, sourceName);
    layer.setProperties(properties);
    if (minZoom != null) {
      layer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      layer.setMaxZoom(maxZoom);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(layer, belowLayerId);
    } else {
      style.addLayer(layer);
    }
  }

  private void addHeatmapLayer(
      String layerName,
      String sourceName,
      Float minZoom,
      Float maxZoom,
      String belowLayerId,
      PropertyValue[] properties,
      Expression filter) {
    HeatmapLayer layer = new HeatmapLayer(layerName, sourceName);
    layer.setProperties(properties);
    if (minZoom != null) {
      layer.setMinZoom(minZoom);
    }
    if (maxZoom != null) {
      layer.setMaxZoom(maxZoom);
    }
    if (belowLayerId != null) {
      style.addLayerBelow(layer, belowLayerId);
    } else {
      style.addLayer(layer);
    }
  }

  private Feature firstFeatureOnLayers(RectF in) {
    if (style != null) {
      final List<Layer> layers = style.getLayers();
      final List<String> layersInOrder = new ArrayList<String>();
      for (Layer layer : layers) {
        String id = layer.getId();
        if (interactiveFeatureLayerIds.contains(id)) {
          layersInOrder.add(id);
        }
      }
      Collections.reverse(layersInOrder);

      for (String id : layersInOrder) {
        List<Feature> features = mapboxMap.queryRenderedFeatures(in, id);
        if (!features.isEmpty()) {
          return features.get(0);
        }
      }
    }
    return null;
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
      case "map#update":
        {
          Convert.interpretMapboxMapOptions(call.argument("options"), this, context);
          result.success(Convert.toJson(getCameraPosition()));
          break;
        }
      case "map#updateMyLocationTrackingMode":
        {
          int myLocationTrackingMode = call.argument("mode");
          setMyLocationTrackingMode(myLocationTrackingMode);
          result.success(null);
          break;
        }
      case "map#matchMapLanguageWithDeviceDefault":
        {
          try {
            localizationPlugin.matchMapLanguageWithDeviceDefault();
            result.success(null);
          } catch (RuntimeException exception) {
            Log.d(TAG, exception.toString());
            result.error("MAPBOX LOCALIZATION PLUGIN ERROR", exception.toString(), null);
          }
          break;
        }
      case "map#updateContentInsets":
        {
          HashMap<String, Object> insets = call.argument("bounds");
          final CameraUpdate cameraUpdate =
              CameraUpdateFactory.paddingTo(
                  Convert.toPixels(insets.get("left"), density),
                  Convert.toPixels(insets.get("top"), density),
                  Convert.toPixels(insets.get("right"), density),
                  Convert.toPixels(insets.get("bottom"), density));

          if (call.argument("animated")) {
            animateCamera(cameraUpdate, null, result);
          } else {
            moveCamera(cameraUpdate, result);
          }
          break;
        }
      case "map#setMapLanguage":
        {
          final String language = call.argument("language");
          try {
            localizationPlugin.setMapLanguage(language);
            result.success(null);
          } catch (RuntimeException exception) {
            Log.d(TAG, exception.toString());
            result.error("MAPBOX LOCALIZATION PLUGIN ERROR", exception.toString(), null);
          }
          break;
        }
      case "map#getVisibleRegion":
        {
          Map<String, Object> reply = new HashMap<>();
          VisibleRegion visibleRegion = mapboxMap.getProjection().getVisibleRegion();
          reply.put(
              "sw",
              Arrays.asList(
                  visibleRegion.nearLeft.getLatitude(), visibleRegion.nearLeft.getLongitude()));
          reply.put(
              "ne",
              Arrays.asList(
                  visibleRegion.farRight.getLatitude(), visibleRegion.farRight.getLongitude()));
          result.success(reply);
          break;
        }
      case "map#toScreenLocation":
        {
          Map<String, Object> reply = new HashMap<>();
          PointF pointf =
              mapboxMap
                  .getProjection()
                  .toScreenLocation(
                      new LatLng(call.argument("latitude"), call.argument("longitude")));
          reply.put("x", pointf.x);
          reply.put("y", pointf.y);
          result.success(reply);
          break;
        }
      case "map#toScreenLocationBatch":
        {
          double[] param = (double[]) call.argument("coordinates");
          double[] reply = new double[param.length];

          for (int i = 0; i < param.length; i += 2) {
            PointF pointf =
                mapboxMap.getProjection().toScreenLocation(new LatLng(param[i], param[i + 1]));
            reply[i] = pointf.x;
            reply[i + 1] = pointf.y;
          }

          result.success(reply);
          break;
        }
      case "map#toLatLng":
        {
          Map<String, Object> reply = new HashMap<>();
          LatLng latlng =
              mapboxMap
                  .getProjection()
                  .fromScreenLocation(
                      new PointF(
                          ((Double) call.argument("x")).floatValue(),
                          ((Double) call.argument("y")).floatValue()));
          reply.put("latitude", latlng.getLatitude());
          reply.put("longitude", latlng.getLongitude());
          result.success(reply);
          break;
        }
      case "map#getMetersPerPixelAtLatitude":
        {
          Map<String, Object> reply = new HashMap<>();
          Double retVal =
              mapboxMap
                  .getProjection()
                  .getMetersPerPixelAtLatitude((Double) call.argument("latitude"));
          reply.put("metersperpixel", retVal);
          result.success(reply);
          break;
        }
      case "camera#move":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
          moveCamera(cameraUpdate, result);
          break;
        }
      case "camera#animate":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
          final Integer duration = call.argument("duration");

          animateCamera(cameraUpdate, duration, result);
          break;
        }
      case "map#queryRenderedFeatures":
        {
          Map<String, Object> reply = new HashMap<>();
          List<Feature> features;

          String[] layerIds = ((List<String>) call.argument("layerIds")).toArray(new String[0]);

          List<Object> filter = call.argument("filter");
          JsonElement jsonElement = filter == null ? null : new Gson().toJsonTree(filter);
          JsonArray jsonArray = null;
          if (jsonElement != null && jsonElement.isJsonArray()) {
            jsonArray = jsonElement.getAsJsonArray();
          }
          Expression filterExpression =
              jsonArray == null ? null : Expression.Converter.convert(jsonArray);
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
            RectF rectF =
                new RectF(
                    left.floatValue(), top.floatValue(), right.floatValue(), bottom.floatValue());
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
      case "map#setTelemetryEnabled":
        {
          final boolean enabled = call.argument("enabled");
          Mapbox.getTelemetry().setUserTelemetryRequestState(enabled);
          result.success(null);
          break;
        }
      case "map#getTelemetryEnabled":
        {
          final TelemetryEnabler.State telemetryState =
              TelemetryEnabler.retrieveTelemetryStateFromPreferences();
          result.success(telemetryState == TelemetryEnabler.State.ENABLED);
          break;
        }
      case "map#invalidateAmbientCache":
        {
          OfflineManager fileSource = OfflineManager.getInstance(context);

          fileSource.invalidateAmbientCache(
              new OfflineManager.FileSourceCallback() {
                @Override
                public void onSuccess() {
                  result.success(null);
                }

                @Override
                public void onError(@NonNull String message) {
                  result.error("MAPBOX CACHE ERROR", message, null);
                }
              });
          break;
        }
      case "source#addGeoJson":
        {
          final String sourceId = call.argument("sourceId");
          final String geojson = call.argument("geojson");
          addGeoJsonSource(sourceId, geojson);
          result.success(null);
          break;
        }
      case "source#setGeoJson":
        {
          final String sourceId = call.argument("sourceId");
          final String geojson = call.argument("geojson");
          setGeoJsonSource(sourceId, geojson);
          result.success(null);
          break;
        }
      case "source#setFeature":
        {
          final String sourceId = call.argument("sourceId");
          final String geojsonFeature = call.argument("geojsonFeature");
          setGeoJsonFeature(sourceId, geojsonFeature);
          result.success(null);
          break;
        }
      case "symbolLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final String sourceLayer = call.argument("sourceLayer");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final String filter = call.argument("filter");
          final boolean enableInteraction = call.argument("enableInteraction");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretSymbolLayerProperties(call.argument("properties"));

          Expression filterExpression = parseFilter(filter);

          removeLayer(layerId);
          addSymbolLayer(
              layerId,
              sourceId,
              belowLayerId,
              sourceLayer,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              properties,
              enableInteraction,
              filterExpression);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "lineLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final String sourceLayer = call.argument("sourceLayer");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final String filter = call.argument("filter");
          final boolean enableInteraction = call.argument("enableInteraction");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretLineLayerProperties(call.argument("properties"));

          Expression filterExpression = parseFilter(filter);

          removeLayer(layerId);
          addLineLayer(
              layerId,
              sourceId,
              belowLayerId,
              sourceLayer,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              properties,
              enableInteraction,
              filterExpression);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "fillLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final String sourceLayer = call.argument("sourceLayer");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final String filter = call.argument("filter");
          final boolean enableInteraction = call.argument("enableInteraction");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretFillLayerProperties(call.argument("properties"));

          Expression filterExpression = parseFilter(filter);

          removeLayer(layerId);
          addFillLayer(
              layerId,
              sourceId,
              belowLayerId,
              sourceLayer,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              properties,
              enableInteraction,
              filterExpression);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "fillExtrusionLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final String sourceLayer = call.argument("sourceLayer");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final String filter = call.argument("filter");
          final boolean enableInteraction = call.argument("enableInteraction");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretFillExtrusionLayerProperties(
                  call.argument("properties"));

          Expression filterExpression = parseFilter(filter);

          removeLayer(layerId);
          addFillExtrusionLayer(
              layerId,
              sourceId,
              belowLayerId,
              sourceLayer,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              properties,
              enableInteraction,
              filterExpression);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "circleLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final String sourceLayer = call.argument("sourceLayer");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final String filter = call.argument("filter");
          final boolean enableInteraction = call.argument("enableInteraction");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretCircleLayerProperties(call.argument("properties"));

          Expression filterExpression = parseFilter(filter);

          removeLayer(layerId);
          addCircleLayer(
              layerId,
              sourceId,
              belowLayerId,
              sourceLayer,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              properties,
              enableInteraction,
              filterExpression);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "rasterLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretRasterLayerProperties(call.argument("properties"));

          removeLayer(layerId);
          addRasterLayer(
              layerId,
              sourceId,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              belowLayerId,
              properties,
              null);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "hillshadeLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretHillshadeLayerProperties(call.argument("properties"));
          addHillshadeLayer(
              layerId,
              sourceId,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              belowLayerId,
              properties,
              null);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "heatmapLayer#add":
        {
          final String sourceId = call.argument("sourceId");
          final String layerId = call.argument("layerId");
          final String belowLayerId = call.argument("belowLayerId");
          final Double minzoom = call.argument("minzoom");
          final Double maxzoom = call.argument("maxzoom");
          final PropertyValue[] properties =
              LayerPropertyConverter.interpretHeatmapLayerProperties(call.argument("properties"));
          addHeatmapLayer(
              layerId,
              sourceId,
              minzoom != null ? minzoom.floatValue() : null,
              maxzoom != null ? maxzoom.floatValue() : null,
              belowLayerId,
              properties,
              null);
          updateLocationComponentLayer();

          result.success(null);
          break;
        }
      case "locationComponent#getLastLocation":
        {
          Log.e(TAG, "location component: getLastLocation");
          if (this.myLocationEnabled && locationComponent != null && locationEngine != null) {
            Map<String, Object> reply = new HashMap<>();
            locationEngine.getLastLocation(
                new LocationEngineCallback<LocationEngineResult>() {
                  @Override
                  public void onSuccess(LocationEngineResult locationEngineResult) {
                    Location lastLocation = locationEngineResult.getLastLocation();
                    if (lastLocation != null) {
                      reply.put("latitude", lastLocation.getLatitude());
                      reply.put("longitude", lastLocation.getLongitude());
                      reply.put("altitude", lastLocation.getAltitude());
                      result.success(reply);
                    } else {
                      result.error("", "", null); // ???
                    }
                  }

                  @Override
                  public void onFailure(@NonNull Exception exception) {
                    result.error("", "", null); // ???
                  }
                });
          }
          break;
        }
      case "style#addImage":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          style.addImage(
              call.argument("name"),
              BitmapFactory.decodeByteArray(call.argument("bytes"), 0, call.argument("length")),
              call.argument("sdf"));
          result.success(null);
          break;
        }
      case "style#addImageSource":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          List<LatLng> coordinates = Convert.toLatLngList(call.argument("coordinates"), false);
          style.addSource(
              new ImageSource(
                  call.argument("imageSourceId"),
                  new LatLngQuad(
                      coordinates.get(0),
                      coordinates.get(1),
                      coordinates.get(2),
                      coordinates.get(3)),
                  BitmapFactory.decodeByteArray(
                      call.argument("bytes"), 0, call.argument("length"))));
          result.success(null);
          break;
        }
      case "style#updateImageSource":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          ImageSource imageSource = style.getSourceAs(call.argument("imageSourceId"));
          List<LatLng> coordinates = Convert.toLatLngList(call.argument("coordinates"), false);
          if (coordinates != null) {
            // https://github.com/mapbox/mapbox-maps-android/issues/302
            imageSource.setCoordinates(
                new LatLngQuad(
                    coordinates.get(0),
                    coordinates.get(1),
                    coordinates.get(2),
                    coordinates.get(3)));
          }
          byte[] bytes = call.argument("bytes");
          if (bytes != null) {
            imageSource.setImage(BitmapFactory.decodeByteArray(bytes, 0, call.argument("length")));
          }
          result.success(null);
          break;
        }
      case "style#addSource":
        {
          final String id = Convert.toString(call.argument("sourceId"));
          final Map<String, Object> properties = (Map<String, Object>) call.argument("properties");
          SourcePropertyConverter.addSource(id, properties, style);
          result.success(null);
          break;
        }

      case "style#removeSource":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          style.removeSource((String) call.argument("sourceId"));
          result.success(null);
          break;
        }
      case "style#addLayer":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          addRasterLayer(
              call.argument("imageLayerId"),
              call.argument("imageSourceId"),
              call.argument("minzoom") != null
                  ? ((Double) call.argument("minzoom")).floatValue()
                  : null,
              call.argument("maxzoom") != null
                  ? ((Double) call.argument("maxzoom")).floatValue()
                  : null,
              null,
              new PropertyValue[] {},
              null);
          result.success(null);
          break;
        }
      case "style#addLayerBelow":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          addRasterLayer(
              call.argument("imageLayerId"),
              call.argument("imageSourceId"),
              call.argument("minzoom") != null
                  ? ((Double) call.argument("minzoom")).floatValue()
                  : null,
              call.argument("maxzoom") != null
                  ? ((Double) call.argument("maxzoom")).floatValue()
                  : null,
              call.argument("belowLayerId"),
              new PropertyValue[] {},
              null);
          result.success(null);
          break;
        }
      case "style#removeLayer":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          String layerId = call.argument("layerId");
          removeLayer(layerId);

          result.success(null);
          break;
        }
      case "style#setFilter":
        {
          if (style == null) {
            result.error(
                "STYLE IS NULL",
                "The style is null. Has onStyleLoaded() already been invoked?",
                null);
          }
          String layerId = call.argument("layerId");
          String filter = call.argument("filter");

          Layer layer = style.getLayer(layerId);

          JsonParser parser = new JsonParser();
          JsonElement jsonElement = parser.parse(filter);
          Expression expression = Expression.Converter.convert(jsonElement);

          if (layer instanceof CircleLayer) {
            ((CircleLayer) layer).setFilter(expression);
          } else if (layer instanceof FillExtrusionLayer) {
            ((FillExtrusionLayer) layer).setFilter(expression);
          } else if (layer instanceof FillLayer) {
            ((FillLayer) layer).setFilter(expression);
          } else if (layer instanceof HeatmapLayer) {
            ((HeatmapLayer) layer).setFilter(expression);
          } else if (layer instanceof LineLayer) {
            ((LineLayer) layer).setFilter(expression);
          } else if (layer instanceof SymbolLayer) {
            ((SymbolLayer) layer).setFilter(expression);
          } else {
            result.error(
                "INVALID LAYER TYPE",
                String.format("Layer '%s' does not support filtering.", layerId),
                null);
            break;
          }

          result.success(null);
          break;
        }
      case "snapshot#takeSnapshot":
        {
          FileSource.getInstance(context).activate();
          MapSnapshotter.Options snapShotOptions =
              new MapSnapshotter.Options(
                  (int) call.argument("width"), (int) call.argument("height"));

          snapShotOptions.withLogo((boolean) call.argument("withLogo"));
          Style.Builder styleBuilder = new Style.Builder();
          if (call.hasArgument("styleUri")) {
            styleBuilder.fromUri((String) call.argument("styleUri"));
          } else if (call.hasArgument("styleJson")) {
            styleBuilder.fromJson((String) call.argument("styleJson"));
          } else {
            if (style == null) {
              result.error(
                  "STYLE IS NULL",
                  "The style is null. Has onStyleLoaded() already been invoked?",
                  null);
            }
            styleBuilder.fromUri(style.getUri());
          }
          snapShotOptions.withStyleBuilder(styleBuilder);
          if (call.hasArgument("bounds")) {
            FeatureCollection bounds = FeatureCollection.fromJson((String) call.argument("bounds"));
            snapShotOptions.withRegion(GeoJSONUtils.toLatLngBounds(bounds));
          } else if (call.hasArgument("centerCoordinate")) {
            Feature centerPoint = Feature.fromJson((String) call.argument("centerCoordinate"));
            CameraPosition cameraPosition =
                new CameraPosition.Builder()
                    .target(GeoJSONUtils.toLatLng((Point) centerPoint.geometry()))
                    .tilt((double) call.argument("pitch"))
                    .bearing((double) call.argument("heading"))
                    .zoom((double) call.argument("zoomLevel"))
                    .build();
            snapShotOptions.withCameraPosition(cameraPosition);
          } else {
            snapShotOptions.withRegion(mapboxMap.getProjection().getVisibleRegion().latLngBounds);
          }

          final MapSnapshotter snapshotter = new MapSnapshotter(context, snapShotOptions);
          final String snapshotterID = UUID.randomUUID().toString();
          mSnapshotterMap.put(snapshotterID, snapshotter);

          snapshotter.start(
              snapshot -> {
                Bitmap bitmap = snapshot.getBitmap();

                String result1;
                if ((boolean) call.argument("writeToDisk")) {
                  result1 = BitmapUtils.createTempFile(context, bitmap);
                } else {
                  result1 = BitmapUtils.createBase64(bitmap);
                }

                if (result1 == null) {
                  result.error(
                      "NO_RESULT",
                      "Could not generate snapshot, please check Android logs for more info.",
                      null);
                  return;
                }

                result.success(result1);
                mSnapshotterMap.remove(snapshotterID);
              },
              new MapSnapshotter.ErrorHandler() {
                @Override
                public void onError(String error) {
                  result.error("SNAPSHOT_ERROR", error, null);
                  mSnapshotterMap.remove(snapshotterID);
                }
              });
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
    final Map<String, Object> arguments = new HashMap<>(2);
    if (trackCameraPosition) {
      arguments.put("position", Convert.toJson(mapboxMap.getCameraPosition()));
    }
    methodChannel.invokeMethod("camera#onIdle", arguments);
  }

  @Override
  public void onCameraTrackingChanged(int currentMode) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("mode", currentMode);
    methodChannel.invokeMethod("map#onCameraTrackingChanged", arguments);
  }

  @Override
  public void onCameraTrackingDismissed() {
    this.myLocationTrackingMode = 0;
    methodChannel.invokeMethod("map#onCameraTrackingDismissed", new HashMap<>());
  }

  @Override
  public void onDidBecomeIdle() {
    methodChannel.invokeMethod("map#onIdle", new HashMap<>());
  }

  @Override
  public boolean onMapClick(@NonNull LatLng point) {
    PointF pointf = mapboxMap.getProjection().toScreenLocation(point);
    RectF rectF = new RectF(pointf.x - 10, pointf.y - 10, pointf.x + 10, pointf.y + 10);
    Feature feature = firstFeatureOnLayers(rectF);
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("lng", point.getLongitude());
    arguments.put("lat", point.getLatitude());
    if (feature != null) {
      arguments.put("id", feature.id());
      methodChannel.invokeMethod("feature#onTap", arguments);
    } else {
      methodChannel.invokeMethod("map#onMapClick", arguments);
    }
    return true;
  }

  @Override
  public boolean onMapLongClick(@NonNull LatLng point) {
    PointF pointf = mapboxMap.getProjection().toScreenLocation(point);
    final Map<String, Object> arguments = new HashMap<>(5);
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("lng", point.getLongitude());
    arguments.put("lat", point.getLatitude());
    methodChannel.invokeMethod("map#onMapLongClick", arguments);
    return true;
  }

  @Override
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    methodChannel.setMethodCallHandler(null);
    destroyMapViewIfNecessary();
    Lifecycle lifecycle = lifecycleProvider.getLifecycle();
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
    }
  }

  private void moveCamera(CameraUpdate cameraUpdate, MethodChannel.Result result) {
    if (cameraUpdate != null) {
      // camera transformation not handled yet
      mapboxMap.moveCamera(
          cameraUpdate,
          new OnCameraMoveFinishedListener() {
            @Override
            public void onFinish() {
              super.onFinish();
              result.success(true);
            }

            @Override
            public void onCancel() {
              super.onCancel();
              result.success(false);
            }
          });

      // moveCamera(cameraUpdate);
    } else {
      result.success(false);
    }
  }

  private void animateCamera(
      CameraUpdate cameraUpdate, Integer duration, MethodChannel.Result result) {
    final OnCameraMoveFinishedListener onCameraMoveFinishedListener =
        new OnCameraMoveFinishedListener() {
          @Override
          public void onFinish() {
            super.onFinish();
            result.success(true);
          }

          @Override
          public void onCancel() {
            super.onCancel();
            result.success(false);
          }
        };
    if (cameraUpdate != null && duration != null) {
      // camera transformation not handled yet
      mapboxMap.animateCamera(cameraUpdate, duration, onCameraMoveFinishedListener);
    } else if (cameraUpdate != null) {
      // camera transformation not handled yet
      mapboxMap.animateCamera(cameraUpdate, onCameraMoveFinishedListener);
    } else {
      result.success(false);
    }
  }

  private void destroyMapViewIfNecessary() {
    if (mapView == null) {
      return;
    }

    mapView.onStop();
    mapView.onDestroy();

    if (locationComponent != null) {
      locationComponent.setLocationComponentEnabled(false);
    }
    stopListeningForLocationUpdates();

    mapView = null;
  }

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onCreate(null);
  }

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onResume();
    if (myLocationEnabled) {
      startListeningForLocationUpdates();
    }
  }

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onPause();
  }

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onStop();
  }

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {
    owner.getLifecycle().removeObserver(this);
    if (disposed) {
      return;
    }
    destroyMapViewIfNecessary();
  }

  // MapboxMapOptionsSink methods

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    this.bounds = bounds;
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
    mapboxMap.setMinZoomPreference(min != null ? min : MapboxConstants.MINIMUM_ZOOM);
    mapboxMap.setMaxZoomPreference(max != null ? max : MapboxConstants.MAXIMUM_ZOOM);
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
    if (mapboxMap != null) {
      // ensure that location is trackable
      updateMyLocationEnabled();
    }
    if (this.myLocationTrackingMode == myLocationTrackingMode) {
      return;
    }
    this.myLocationTrackingMode = myLocationTrackingMode;
    if (mapboxMap != null && locationComponent != null) {
      updateMyLocationTrackingMode();
    }
  }

  @Override
  public void setMyLocationRenderMode(int myLocationRenderMode) {
    if (this.myLocationRenderMode == myLocationRenderMode) {
      return;
    }
    this.myLocationRenderMode = myLocationRenderMode;
    if (mapboxMap != null && locationComponent != null) {
      updateMyLocationRenderMode();
    }
  }

  public void setLogoViewMargins(int x, int y) {
    mapboxMap.getUiSettings().setLogoMargins(x, 0, 0, y);
  }

  @Override
  public void setCompassGravity(int gravity) {
    switch (gravity) {
      case 0:
        mapboxMap.getUiSettings().setCompassGravity(Gravity.TOP | Gravity.START);
        break;
      default:
      case 1:
        mapboxMap.getUiSettings().setCompassGravity(Gravity.TOP | Gravity.END);
        break;
      case 2:
        mapboxMap.getUiSettings().setCompassGravity(Gravity.BOTTOM | Gravity.START);
        break;
      case 3:
        mapboxMap.getUiSettings().setCompassGravity(Gravity.BOTTOM | Gravity.END);
        break;
    }
  }

  @Override
  public void setCompassViewMargins(int x, int y) {
    switch (mapboxMap.getUiSettings().getCompassGravity()) {
      case Gravity.TOP | Gravity.START:
        mapboxMap.getUiSettings().setCompassMargins(x, y, 0, 0);
        break;
      default:
      case Gravity.TOP | Gravity.END:
        mapboxMap.getUiSettings().setCompassMargins(0, y, x, 0);
        break;
      case Gravity.BOTTOM | Gravity.START:
        mapboxMap.getUiSettings().setCompassMargins(x, 0, 0, y);
        break;
      case Gravity.BOTTOM | Gravity.END:
        mapboxMap.getUiSettings().setCompassMargins(0, 0, x, y);
        break;
    }
  }

  @Override
  public void setAttributionButtonGravity(int gravity) {
    switch (gravity) {
      case 0:
        mapboxMap.getUiSettings().setAttributionGravity(Gravity.TOP | Gravity.START);
        break;
      default:
      case 1:
        mapboxMap.getUiSettings().setAttributionGravity(Gravity.TOP | Gravity.END);
        break;
      case 2:
        mapboxMap.getUiSettings().setAttributionGravity(Gravity.BOTTOM | Gravity.START);
        break;
      case 3:
        mapboxMap.getUiSettings().setAttributionGravity(Gravity.BOTTOM | Gravity.END);
        break;
    }
  }

  @Override
  public void setAttributionButtonMargins(int x, int y) {
    switch (mapboxMap.getUiSettings().getAttributionGravity()) {
      case Gravity.TOP | Gravity.START:
        mapboxMap.getUiSettings().setAttributionMargins(x, y, 0, 0);
        break;
      default:
      case Gravity.TOP | Gravity.END:
        mapboxMap.getUiSettings().setAttributionMargins(0, y, x, 0);
        break;
      case Gravity.BOTTOM | Gravity.START:
        mapboxMap.getUiSettings().setAttributionMargins(x, 0, 0, y);
        break;
      case Gravity.BOTTOM | Gravity.END:
        mapboxMap.getUiSettings().setAttributionMargins(0, 0, x, y);
        break;
    }
  }

  private void updateMyLocationEnabled() {
    if (this.locationComponent == null && myLocationEnabled) {
      enableLocationComponent(mapboxMap.getStyle());
    }

    if (myLocationEnabled) {
      startListeningForLocationUpdates();
    } else {
      stopListeningForLocationUpdates();
    }

    if (locationComponent != null) {
      locationComponent.setLocationComponentEnabled(myLocationEnabled);
    }
  }

  private void startListeningForLocationUpdates() {
    if (locationEngineCallback == null
        && locationComponent != null
        && locationComponent.getLocationEngine() != null) {
      locationEngineCallback =
          new LocationEngineCallback<LocationEngineResult>() {
            @Override
            public void onSuccess(LocationEngineResult result) {
              onUserLocationUpdate(result.getLastLocation());
            }

            @Override
            public void onFailure(@NonNull Exception exception) {}
          };
      locationComponent
          .getLocationEngine()
          .requestLocationUpdates(
              locationComponent.getLocationEngineRequest(), locationEngineCallback, null);
    }
  }

  private void stopListeningForLocationUpdates() {
    if (locationEngineCallback != null
        && locationComponent != null
        && locationComponent.getLocationEngine() != null) {
      locationComponent.getLocationEngine().removeLocationUpdates(locationEngineCallback);
      locationEngineCallback = null;
    }
  }

  private void updateMyLocationTrackingMode() {
    int[] mapboxTrackingModes =
        new int[] {
          CameraMode.NONE, CameraMode.TRACKING, CameraMode.TRACKING_COMPASS, CameraMode.TRACKING_GPS
        };
    locationComponent.setCameraMode(mapboxTrackingModes[this.myLocationTrackingMode]);
  }

  private void updateMyLocationRenderMode() {
    int[] mapboxRenderModes = new int[] {RenderMode.NORMAL, RenderMode.COMPASS, RenderMode.GPS};
    locationComponent.setRenderMode(mapboxRenderModes[this.myLocationRenderMode]);
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

  /**
   * Tries to find highest scale image for display type
   *
   * @param imageId
   * @param density
   * @return
   */
  private Bitmap getScaledImage(String imageId, float density) {
    AssetFileDescriptor assetFileDescriptor;

    // Split image path into parts.
    List<String> imagePathList = Arrays.asList(imageId.split("/"));
    List<String> assetPathList = new ArrayList<>();

    // "On devices with a device pixel ratio of 1.8, the asset .../2.0x/my_icon.png would be chosen.
    // For a device pixel ratio of 2.7, the asset .../3.0x/my_icon.png would be chosen."
    // Source: https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware
    for (int i = (int) Math.ceil(density); i > 0; i--) {
      String assetPath;
      if (i == 1) {
        // If density is 1.0x then simply take the default asset path
        assetPath = MapboxMapsPlugin.flutterAssets.getAssetFilePathByName(imageId);
      } else {
        // Build a resolution aware asset path as follows:
        // <directory asset>/<ratio>/<image name>
        // where ratio is 1.0x, 2.0x or 3.0x.
        StringBuilder stringBuilder = new StringBuilder();
        for (int j = 0; j < imagePathList.size() - 1; j++) {
          stringBuilder.append(imagePathList.get(j));
          stringBuilder.append("/");
        }
        stringBuilder.append(((float) i) + "x");
        stringBuilder.append("/");
        stringBuilder.append(imagePathList.get(imagePathList.size() - 1));
        assetPath = MapboxMapsPlugin.flutterAssets.getAssetFilePathByName(stringBuilder.toString());
      }
      // Build up a list of resolution aware asset paths.
      assetPathList.add(assetPath);
    }

    // Iterate over asset paths and get the highest scaled asset (as a bitmap).
    Bitmap bitmap = null;
    for (String assetPath : assetPathList) {
      try {
        // Read path (throws exception if doesn't exist).
        assetFileDescriptor = mapView.getContext().getAssets().openFd(assetPath);
        InputStream assetStream = assetFileDescriptor.createInputStream();
        bitmap = BitmapFactory.decodeStream(assetStream);
        assetFileDescriptor.close(); // Close for memory
        break; // If exists, break
      } catch (IOException e) {
        // Skip
      }
    }
    return bitmap;
  }

  boolean onMoveBegin(MoveGestureDetector detector) {
    // onMoveBegin gets called even during a move - move end is also not called unless this function
    // returns
    // true at least once. To avoid redundant queries only check for feature if the previous event
    // was ACTION_DOWN
    if (detector.getPreviousEvent().getActionMasked() == MotionEvent.ACTION_DOWN
        && detector.getPointersCount() == 1) {
      PointF pointf = detector.getFocalPoint();
      LatLng origin = mapboxMap.getProjection().fromScreenLocation(pointf);
      RectF rectF = new RectF(pointf.x - 10, pointf.y - 10, pointf.x + 10, pointf.y + 10);
      Feature feature = firstFeatureOnLayers(rectF);
      if (feature != null && startDragging(feature, origin)) {
        invokeFeatureDrag(pointf, "start");
        return true;
      }
    }
    return false;
  }

  private void invokeFeatureDrag(PointF pointf, String eventType) {
    LatLng current = mapboxMap.getProjection().fromScreenLocation(pointf);

    final Map<String, Object> arguments = new HashMap<>(9);
    arguments.put("id", draggedFeature.id());
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("originLng", dragOrigin.getLongitude());
    arguments.put("originLat", dragOrigin.getLatitude());
    arguments.put("currentLng", current.getLongitude());
    arguments.put("currentLat", current.getLatitude());
    arguments.put("eventType", eventType);
    arguments.put("deltaLng", current.getLongitude() - dragPrevious.getLongitude());
    arguments.put("deltaLat", current.getLatitude() - dragPrevious.getLatitude());
    dragPrevious = current;
    methodChannel.invokeMethod("feature#onDrag", arguments);
  }

  boolean onMove(MoveGestureDetector detector) {
    if (draggedFeature != null) {
      if (detector.getPointersCount() > 1) {
        stopDragging();
        return true;
      }
      PointF pointf = detector.getFocalPoint();
      invokeFeatureDrag(pointf, "drag");
      return false;
    }
    return true;
  }

  void removeLayer(String layerId) {
    if (style != null && layerId != null) {
      style.removeLayer(layerId);
      interactiveFeatureLayerIds.remove(layerId);
    }
  }

  void onMoveEnd(MoveGestureDetector detector) {
    PointF pointf = detector.getFocalPoint();
    invokeFeatureDrag(pointf, "end");
    stopDragging();
  }

  boolean startDragging(@NonNull Feature feature, @NonNull LatLng origin) {
    final boolean draggable =
        feature.hasNonNullValueForProperty("draggable")
            ? feature.getBooleanProperty("draggable")
            : false;
    if (draggable) {
      draggedFeature = feature;
      dragPrevious = origin;
      dragOrigin = origin;
      return true;
    }
    return false;
  }

  void stopDragging() {
    draggedFeature = null;
    dragOrigin = null;
    dragPrevious = null;
  }

  /** Simple Listener to listen for the status of camera movements. */
  public class OnCameraMoveFinishedListener implements MapboxMap.CancelableCallback {

    @Override
    public void onFinish() {}

    @Override
    public void onCancel() {}
  }

  private class MoveGestureListener implements MoveGestureDetector.OnMoveGestureListener {

    @Override
    public boolean onMoveBegin(MoveGestureDetector detector) {
      return MapboxMapController.this.onMoveBegin(detector);
    }

    @Override
    public boolean onMove(MoveGestureDetector detector, float distanceX, float distanceY) {
      return MapboxMapController.this.onMove(detector);
    }

    @Override
    public void onMoveEnd(MoveGestureDetector detector, float velocityX, float velocityY) {
      MapboxMapController.this.onMoveEnd(detector);
    }
  }
}
