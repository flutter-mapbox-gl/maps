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
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.mapbox.android.core.location.LocationEngine;
import com.mapbox.android.core.location.LocationEngineCallback;
import com.mapbox.android.core.location.LocationEngineProvider;
import com.mapbox.android.core.location.LocationEngineResult;
import com.mapbox.android.telemetry.TelemetryEnabler;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
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
import com.mapbox.mapboxsdk.plugins.annotation.Annotation;
import com.mapbox.mapboxsdk.plugins.annotation.Circle;
import com.mapbox.mapboxsdk.plugins.annotation.CircleManager;
import com.mapbox.mapboxsdk.plugins.annotation.CircleOptions;
import com.mapbox.mapboxsdk.plugins.annotation.Fill;
import com.mapbox.mapboxsdk.plugins.annotation.FillManager;
import com.mapbox.mapboxsdk.plugins.annotation.FillOptions;
import com.mapbox.mapboxsdk.plugins.annotation.Line;
import com.mapbox.mapboxsdk.plugins.annotation.LineManager;
import com.mapbox.mapboxsdk.plugins.annotation.LineOptions;
import com.mapbox.mapboxsdk.plugins.annotation.OnAnnotationClickListener;
import com.mapbox.mapboxsdk.plugins.annotation.Symbol;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolManager;
import com.mapbox.mapboxsdk.plugins.annotation.SymbolOptions;
import com.mapbox.mapboxsdk.plugins.localization.LocalizationPlugin;
import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.Layer;
import com.mapbox.mapboxsdk.style.sources.ImageSource;

import com.mapbox.mapboxsdk.style.layers.LineLayer;
import com.mapbox.mapboxsdk.style.layers.CircleLayer;
import com.mapbox.mapboxsdk.style.layers.FillLayer;
import com.mapbox.mapboxsdk.style.layers.SymbolLayer;
import com.mapbox.mapboxsdk.style.layers.HillshadeLayer;
import com.mapbox.mapboxsdk.style.layers.RasterLayer;

import com.mapbox.mapboxsdk.style.layers.Property;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.PropertyValue;
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Collections;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

/**
 * Controller of a single MapboxMaps MapView instance.
 */
@SuppressLint("MissingPermission")
final class MapboxMapController
  implements DefaultLifecycleObserver,
  MapboxMap.OnCameraIdleListener,
  MapboxMap.OnCameraMoveListener,
  MapboxMap.OnCameraMoveStartedListener,
  MapView.OnDidBecomeIdleListener,
  OnAnnotationClickListener,
  MapboxMap.OnMapClickListener,
  MapboxMap.OnMapLongClickListener,
  MapboxMapOptionsSink,
  MethodChannel.MethodCallHandler,
  OnMapReadyCallback,
  OnCameraTrackingChangedListener,
  OnSymbolTappedListener,
  OnLineTappedListener,
  OnCircleTappedListener,
  OnFillTappedListener,
  PlatformView {
  private static final String TAG = "MapboxMapController";
  private final int id;
  private final MethodChannel methodChannel;
  private final MapboxMapsPlugin.LifecycleProvider lifecycleProvider;
  private MapView mapView;
  private MapboxMap mapboxMap;
  private final Map<String, SymbolController> symbols;
  private final Map<String, LineController> lines;
  private final Map<String, CircleController> circles;
  private final Map<String, FillController> fills;
  private SymbolManager symbolManager;
  private LineManager lineManager;
  private CircleManager circleManager;
  private FillManager fillManager;
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private int myLocationTrackingMode = 0;
  private int myLocationRenderMode = 0;
  private boolean disposed = false;
  private final float density;
  private MethodChannel.Result mapReadyResult;
  private final Context context;
  private final String styleStringInitial;
  private LocationComponent locationComponent = null;
  private LocationEngine locationEngine = null;
  private LocationEngineCallback<LocationEngineResult> locationEngineCallback = null;
  private LocalizationPlugin localizationPlugin;
  private Style style;
  private List<String> annotationOrder;
  private List<String> annotationConsumeTapEvents;
  private Set<String> featureLayerIdentifiers;
  private LatLngBounds bounds = null;
  private static final String annotationManagerNotCreatedErrorCode = "NO ANNOTATION MANAGER";
  private static final String annotationManagerNotCreatedErrorMessage = "To use %ss please add it to the annotation list";

  MapboxMapController(
    int id,
    Context context,
    BinaryMessenger messenger,
    MapboxMapsPlugin.LifecycleProvider lifecycleProvider,
    MapboxMapOptions options,
    String accessToken,
    String styleStringInitial,
    List<String> annotationOrder,
    List<String> annotationConsumeTapEvents) {
    MapBoxUtils.getMapbox(context, accessToken);
    this.id = id;
    this.context = context;
    this.styleStringInitial = styleStringInitial;
    this.mapView = new MapView(context, options);
    this.featureLayerIdentifiers = new HashSet<>();
    this.symbols = new HashMap<>();
    this.lines = new HashMap<>();
    this.circles = new HashMap<>();
    this.fills = new HashMap<>();
    this.density = context.getResources().getDisplayMetrics().density;
    this.lifecycleProvider = lifecycleProvider;
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/mapbox_maps_" + id);
    methodChannel.setMethodCallHandler(this);
    this.annotationOrder = annotationOrder;
    this.annotationConsumeTapEvents = annotationConsumeTapEvents;
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

  private SymbolController symbol(String symbolId) {
    final SymbolController symbol = symbols.get(symbolId);
    if (symbol == null) {
      throw new IllegalArgumentException("Unknown symbol: " + symbolId);
    }
    return symbol;
  }

  private LineBuilder newLineBuilder() {
    return new LineBuilder(lineManager);
  }

  private void removeLine(String lineId) {
    final LineController lineController = lines.remove(lineId);
    if (lineController != null) {
      lineController.remove(lineManager);
    }
  }

  private LineController line(String lineId) {
    final LineController line = lines.get(lineId);
    if (line == null) {
      throw new IllegalArgumentException("Unknown line: " + lineId);
    }
    return line;
  }

  private CircleBuilder newCircleBuilder() {
    return new CircleBuilder(circleManager);
  }

  private void removeCircle(String circleId) {
    final CircleController circleController = circles.remove(circleId);
    if (circleController != null) {
      circleController.remove(circleManager);
    }
  }

  private CircleController circle(String circleId) {
    final CircleController circle = circles.get(circleId);
    if (circle == null) {
      throw new IllegalArgumentException("Unknown circle: " + circleId);
    }
    return circle;
  }

  private FillBuilder newFillBuilder() {
    return new FillBuilder(fillManager);
  }

  private void removeFill(String fillId) {
    final FillController fillController = fills.remove(fillId);
    if (fillController != null) {
      fillController.remove(fillManager);
    }
  }

  private FillController fill(String fillId) {
    final FillController fill = fills.get(fillId);
    if (fill == null) {
      throw new IllegalArgumentException("Unknown fill: " + fillId);
    }
    return fill;
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

    mapView.addOnStyleImageMissingListener((id) -> {
      DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
      final Bitmap bitmap = getScaledImage(id, displayMetrics.density);
      if (bitmap != null) {
        mapboxMap.getStyle().addImage(id, bitmap);
      }
    });

    mapView.addOnDidBecomeIdleListener(this);

    setStyleString(styleStringInitial);
    // updateMyLocationEnabled();
  }

  @Override
  public void setStyleString(String styleString) {
    // Check if json, url, absolute path or asset path:
    if (styleString == null || styleString.isEmpty()) {
      Log.e(TAG, "setStyleString - string empty or null");
    } else if (styleString.startsWith("{") || styleString.startsWith("[")) {
      mapboxMap.setStyle(new Style.Builder().fromJson(styleString), onStyleLoadedCallback);
    } else if (styleString.startsWith("/")) {
      // Absolute path
      mapboxMap.setStyle(new Style.Builder().fromUri("file://" + styleString), onStyleLoadedCallback);
    } else if (
      !styleString.startsWith("http://") &&
      !styleString.startsWith("https://")&&
      !styleString.startsWith("mapbox://")) {
      // We are assuming that the style will be loaded from an asset here.
      String key = MapboxMapsPlugin.flutterAssets.getAssetFilePathByName(styleString);
      mapboxMap.setStyle(new Style.Builder().fromUri("asset://" + key), onStyleLoadedCallback);
    } else {
      mapboxMap.setStyle(new Style.Builder().fromUri(styleString), onStyleLoadedCallback);
    }
  }

  Style.OnStyleLoaded onStyleLoadedCallback = new Style.OnStyleLoaded() {
    @Override
    public void onStyleLoaded(@NonNull Style style) {
      MapboxMapController.this.style = style;

      // only add managers once to avoid issues with getLayerId after a style switch
      if(symbolManager == null && circleManager == null && lineManager == null && fillManager == null)
      {
        final List<String> orderReversed = new ArrayList<String>(annotationOrder);
        Collections.reverse(orderReversed);
        String belowLayer = null;
        for(String annotationType : orderReversed) {
          switch (annotationType) {
            case "AnnotationType.fill":
              belowLayer = enableFillManager(style, belowLayer);
              break;
            case "AnnotationType.line":
              belowLayer = enableLineManager(style, belowLayer);
              break;
            case "AnnotationType.circle":
              belowLayer = enableCircleManager(style, belowLayer);
              break;
            case "AnnotationType.symbol":
              belowLayer = enableSymbolManager(style, belowLayer);
              break;
            default:
              throw new IllegalArgumentException("Unknown annotation type: " + annotationType + ", must be either 'fill', 'line', 'circle' or 'symbol'");
          }
        }
      }

      if (myLocationEnabled) {
        enableLocationComponent(style);
      }

      if (null != bounds) {
        mapboxMap.setLatLngBoundsForCameraTarget(bounds);
      }
      
      // needs to be placed after SymbolManager#addClickListener,
      // is fixed with 0.6.0 of annotations plugin
      mapboxMap.addOnMapClickListener(MapboxMapController.this);
      mapboxMap.addOnMapLongClickListener(MapboxMapController.this);
	    localizationPlugin = new LocalizationPlugin(mapView, mapboxMap, style);

      methodChannel.invokeMethod("map#onStyleLoaded", null);
    }
  };

  @SuppressWarnings( {"MissingPermission"})
  private void enableLocationComponent(@NonNull Style style) {
    if (hasLocationPermission()) {
      locationEngine = LocationEngineProvider.getBestLocationEngine(context);
      LocationComponentOptions locationComponentOptions = LocationComponentOptions.builder(context)
        .trackingGesturesManagement(true)
        .build();
      locationComponent = mapboxMap.getLocationComponent();
      locationComponent.activateLocationComponent(context, style, locationComponentOptions);
      locationComponent.setLocationComponentEnabled(true);
      // locationComponent.setRenderMode(RenderMode.COMPASS); // remove or keep default?
      locationComponent.setLocationEngine(locationEngine);
      locationComponent.setMaxAnimationFps(30);
      updateMyLocationTrackingMode();
      setMyLocationTrackingMode(this.myLocationTrackingMode);
      updateMyLocationRenderMode();
      setMyLocationRenderMode(this.myLocationRenderMode);
      locationComponent.addOnCameraTrackingChangedListener(this);
    } else {
      Log.e(TAG, "missing location permissions");
    }
  }

  private void onUserLocationUpdate(Location location){
    if(location==null){
      return;
    }

    final Map<String, Object> userLocation = new HashMap<>(6);
    userLocation.put("position", new double[]{location.getLatitude(), location.getLongitude()});
    userLocation.put("speed", location.getSpeed());
    userLocation.put("altitude", location.getAltitude());
    userLocation.put("bearing", location.getBearing());
    userLocation.put("horizontalAccuracy", location.getAccuracy());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      userLocation.put("verticalAccuracy", (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) ? location.getVerticalAccuracyMeters() : null);
    }
    userLocation.put("timestamp", location.getTime());

    final Map<String, Object> arguments = new HashMap<>(1);
    arguments.put("userLocation", userLocation);
    methodChannel.invokeMethod("map#onUserLocationUpdated", arguments);
  }
  
  private void addGeoJsonSource(String sourceName, String source) {
    FeatureCollection featureCollection = FeatureCollection.fromJson(source);
    GeoJsonSource geoJsonSource = new GeoJsonSource(sourceName, featureCollection);

    style.addSource(geoJsonSource);
  }

  private void setGeoJsonSource(String sourceName, String source) {
    FeatureCollection featureCollection = FeatureCollection.fromJson(source);
    GeoJsonSource geoJsonSource = style.getSourceAs(sourceName);

    geoJsonSource.setGeoJson(featureCollection);
  }

  private void addSymbolLayer(String layerName,
                              String sourceName,
                              String belowLayerId,
                              String sourceLayer,
                              PropertyValue[] properties,
                              Expression filter) {
    SymbolLayer symbolLayer = new SymbolLayer(layerName, sourceName);
    symbolLayer.setProperties(properties);
     if(sourceLayer != null){
      symbolLayer.setSourceLayer(sourceLayer);
    }

    if(belowLayerId != null){
      style.addLayerBelow(symbolLayer, belowLayerId);
    }
    else
    {
      style.addLayer(symbolLayer);
    }
    featureLayerIdentifiers.add(layerName);
  }

  private void addLineLayer(String layerName,
                            String sourceName,
                            String belowLayerId,
                            String sourceLayer,
                            PropertyValue[] properties,
                            Expression filter) {
    LineLayer lineLayer = new LineLayer(layerName, sourceName);
    lineLayer.setProperties(properties);
     if(sourceLayer != null){
      lineLayer.setSourceLayer(sourceLayer);
    }

    if(belowLayerId != null){
      style.addLayerBelow(lineLayer, belowLayerId);
    }
    else
    {
      style.addLayer(lineLayer);
    }
    featureLayerIdentifiers.add(layerName);
  }

  private void addFillLayer(String layerName,
                            String sourceName,
                            String belowLayerId,
                            String sourceLayer,
                            PropertyValue[] properties,
                            Expression filter) {
    FillLayer fillLayer = new FillLayer(layerName, sourceName);
    fillLayer.setProperties(properties);
    if(sourceLayer != null){
      fillLayer.setSourceLayer(sourceLayer);
    }

    if(belowLayerId != null){
      style.addLayerBelow(fillLayer, belowLayerId);
    }
    else
    {
      style.addLayer(fillLayer);
    }
    featureLayerIdentifiers.add(layerName);
  }

  private void addCircleLayer(String layerName,
                            String sourceName,
                            String belowLayerId,
                            String sourceLayer,
                            PropertyValue[] properties,
                            Expression filter) {
    CircleLayer circleLayer = new CircleLayer(layerName, sourceName);
    circleLayer.setProperties(properties);
    if(sourceLayer != null){
      circleLayer.setSourceLayer(sourceLayer);
    }

    featureLayerIdentifiers.add(layerName);
    if(belowLayerId != null){
      style.addLayerBelow(circleLayer, belowLayerId);
    }
    else
    {
      style.addLayer(circleLayer);
    }
  }

  private void addRasterLayer(String layerName,
                            String sourceName,
                            String belowLayerId,
                            PropertyValue[] properties,
                            Expression filter) {
    RasterLayer layer = new RasterLayer(layerName, sourceName);
    layer.setProperties(properties);

    if(belowLayerId != null){
      style.addLayerBelow(layer, belowLayerId);
    }
    else
    {
      style.addLayer(layer);
    }
  }

    private void addHillshadeLayer(String layerName,
                            String sourceName,
                            String belowLayerId,
                            PropertyValue[] properties,
                            Expression filter) {
    HillshadeLayer layer = new HillshadeLayer(layerName, sourceName);
    layer.setProperties(properties);

    if(belowLayerId != null){
      style.addLayerBelow(layer, belowLayerId);
    }
    else
    {
      style.addLayer(layer);
    }
  }

  private String enableSymbolManager(@NonNull Style style, @Nullable String belowLayer) {
    if (symbolManager == null) {
      symbolManager = new SymbolManager(mapView, mapboxMap, style, belowLayer);
      symbolManager.setIconAllowOverlap(true);
      symbolManager.setIconIgnorePlacement(true);
      symbolManager.setTextAllowOverlap(true);
      symbolManager.setTextIgnorePlacement(true);
      symbolManager.addClickListener(MapboxMapController.this::onAnnotationClick);
    }
    return symbolManager.getLayerId();
  }

  private String enableLineManager(@NonNull Style style, @Nullable String belowLayer) {
    if (lineManager == null) {
      lineManager = new LineManager(mapView, mapboxMap, style, belowLayer);
      lineManager.addClickListener(MapboxMapController.this::onAnnotationClick);
    }
    return lineManager.getLayerId();
  }

  private String enableCircleManager(@NonNull Style style, @Nullable String belowLayer) {
    if (circleManager == null) {
      circleManager = new CircleManager(mapView, mapboxMap, style, belowLayer);
      circleManager.addClickListener(MapboxMapController.this::onAnnotationClick);
    }
    return circleManager.getLayerId();
  }

  private String enableFillManager(@NonNull Style style, @Nullable String belowLayer) {
    if (fillManager ==  null) {
      fillManager = new FillManager(mapView, mapboxMap, style, belowLayer);
      fillManager.addClickListener(MapboxMapController.this::onAnnotationClick);
    }
    return fillManager.getLayerId();
  }

  private Feature firstFeatureOnLayers(RectF in) {
    if(style != null){
      final List<Layer> layers = style.getLayers();
      final List<String> layersInOrder = new ArrayList<String>();
      for (Layer layer : layers){
        String id = layer.getId();
        if(featureLayerIdentifiers.contains(id))
          layersInOrder.add(id);
      }
      Collections.reverse(layersInOrder);

      for(String id: layersInOrder){
        List<Feature> features = mapboxMap.queryRenderedFeatures(in, id);
        if(!features.isEmpty()){
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
      case "map#update": {
        Convert.interpretMapboxMapOptions(call.argument("options"), this, context);
        result.success(Convert.toJson(getCameraPosition()));
        break;
      }
      case "map#updateMyLocationTrackingMode": {
        int myLocationTrackingMode = call.argument("mode");
        setMyLocationTrackingMode(myLocationTrackingMode);
        result.success(null);
        break;
      }
	    case "map#matchMapLanguageWithDeviceDefault": {
        try {
		      localizationPlugin.matchMapLanguageWithDeviceDefault();
			    result.success(null);
		    } catch (RuntimeException exception) {
		      Log.d(TAG, exception.toString());
			    result.error("MAPBOX LOCALIZATION PLUGIN ERROR", exception.toString(), null);
		    }
        break;
      }
	    case "map#setMapLanguage": {
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
      case "map#getVisibleRegion": {
        Map<String, Object> reply = new HashMap<>();
        VisibleRegion visibleRegion = mapboxMap.getProjection().getVisibleRegion();
        reply.put("sw", Arrays.asList(visibleRegion.nearLeft.getLatitude(), visibleRegion.nearLeft.getLongitude()));
        reply.put("ne", Arrays.asList(visibleRegion.farRight.getLatitude(), visibleRegion.farRight.getLongitude()));
        result.success(reply);
        break;
      }
      case "map#toScreenLocation": {
        Map<String, Object> reply = new HashMap<>();
        PointF pointf = mapboxMap.getProjection().toScreenLocation(new LatLng(call.argument("latitude"),call.argument("longitude")));
        reply.put("x", pointf.x);
        reply.put("y", pointf.y);
        result.success(reply);
        break;
      }
      case "map#toScreenLocationBatch": {
        double[] param = (double[])call.argument("coordinates");
        double[] reply = new double[param.length];

        for (int i = 0; i < param.length; i += 2) {
          PointF pointf = mapboxMap.getProjection().toScreenLocation(new LatLng(param[i], param[i + 1]));
          reply[i] = pointf.x;
          reply[i + 1] = pointf.y;
        }

        result.success(reply);
        break;
      }
      case "map#toLatLng": {
        Map<String, Object> reply = new HashMap<>();
        LatLng latlng = mapboxMap.getProjection().fromScreenLocation(new PointF( ((Double) call.argument("x")).floatValue(), ((Double) call.argument("y")).floatValue()));
        reply.put("latitude", latlng.getLatitude());
        reply.put("longitude", latlng.getLongitude());
        result.success(reply);
        break;
      }
      case "map#getMetersPerPixelAtLatitude": {
        Map<String, Object> reply = new HashMap<>();
        Double retVal = mapboxMap.getProjection().getMetersPerPixelAtLatitude((Double)call.argument("latitude"));
        reply.put("metersperpixel", retVal);
        result.success(reply);
        break;
      }
      case "camera#move": {
        final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
        if (cameraUpdate != null) {
          // camera transformation not handled yet
          mapboxMap.moveCamera(cameraUpdate, new OnCameraMoveFinishedListener(){
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
        }else {
          result.success(false);
        }
        break;
      }
      case "camera#animate": {
        final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"), mapboxMap, density);
        final Integer duration = call.argument("duration");

        final OnCameraMoveFinishedListener onCameraMoveFinishedListener = new OnCameraMoveFinishedListener(){
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
        break;
      }
      case "map#queryRenderedFeatures": {
        Map<String, Object> reply = new HashMap<>();
        List<Feature> features;

        String[] layerIds = ((List<String>) call.argument("layerIds")).toArray(new String[0]);

        List<Object> filter = call.argument("filter");
        JsonElement jsonElement = filter == null ? null : new Gson().toJsonTree(filter);
        JsonArray jsonArray = null;
        if (jsonElement != null && jsonElement.isJsonArray()) {
          jsonArray = jsonElement.getAsJsonArray();
        }
        Expression filterExpression = jsonArray == null ? null : Expression.Converter.convert(jsonArray);
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
      case "map#setTelemetryEnabled": {
        final boolean enabled = call.argument("enabled");
        Mapbox.getTelemetry().setUserTelemetryRequestState(enabled);
        result.success(null);
        break;
      }
      case "map#getTelemetryEnabled": {
        final TelemetryEnabler.State telemetryState = TelemetryEnabler.retrieveTelemetryStateFromPreferences();
        result.success(telemetryState == TelemetryEnabler.State.ENABLED);
        break;
      }
      case "map#invalidateAmbientCache": {
        OfflineManager fileSource = OfflineManager.getInstance(context);

        fileSource.invalidateAmbientCache(new OfflineManager.FileSourceCallback() {
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
      case "symbols#addAll": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        List<String> newSymbolIds = new ArrayList<String>();
        final List<Object> options = call.argument("options");
        List<SymbolOptions> symbolOptionsList = new ArrayList<SymbolOptions>();
        if (options != null) {
          SymbolBuilder symbolBuilder;
          for (Object o : options) {
            symbolBuilder =  new SymbolBuilder();
            Convert.interpretSymbolOptions(o, symbolBuilder);
            symbolOptionsList.add(symbolBuilder.getSymbolOptions());
          }
          if (!symbolOptionsList.isEmpty()) {
            List<Symbol> newSymbols = symbolManager.create(symbolOptionsList);
            String symbolId;
            for (Symbol symbol : newSymbols) {
              symbolId = String.valueOf(symbol.getId());
              newSymbolIds.add(symbolId);
              symbols.put(symbolId, new SymbolController(symbol, annotationConsumeTapEvents.contains("AnnotationType.symbol"), this));
            }
          }
        }
        result.success(newSymbolIds);
        break;
      }
      case "symbols#removeAll": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final ArrayList<String> symbolIds = call.argument("ids");
        SymbolController symbolController;

        List<Symbol> symbolList = new ArrayList<Symbol>();
        for(String symbolId : symbolIds){
            symbolController = symbols.remove(symbolId);
            if (symbolController != null) {
              symbolList.add(symbolController.getSymbol());
            }
        }
        if(!symbolList.isEmpty()) {
          symbolManager.delete(symbolList);
        }
        result.success(null);
        break;
      }
      case "symbol#update": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final String symbolId = call.argument("symbol");
        final SymbolController symbol = symbol(symbolId);
        Convert.interpretSymbolOptions(call.argument("options"), symbol);
        symbol.update(symbolManager);
        result.success(null);
        break;
      }
      case "symbol#getGeometry": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final String symbolId = call.argument("symbol");
        final SymbolController symbol = symbol(symbolId);
        final LatLng symbolLatLng = symbol.getGeometry();
        Map<String, Double> hashMapLatLng = new HashMap<>();
        hashMapLatLng.put("latitude", symbolLatLng.getLatitude());
        hashMapLatLng.put("longitude", symbolLatLng.getLongitude());
        result.success(hashMapLatLng);
      }
      case "symbolManager#iconAllowOverlap": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final Boolean value = call.argument("iconAllowOverlap");
        symbolManager.setIconAllowOverlap(value);
        result.success(null);
        break;
      }
      case "symbolManager#iconIgnorePlacement": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final Boolean value = call.argument("iconIgnorePlacement");
        symbolManager.setIconIgnorePlacement(value);
        result.success(null);
        break;
      }
      case "symbolManager#textAllowOverlap": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final Boolean value = call.argument("textAllowOverlap");
        symbolManager.setTextAllowOverlap(value);
        result.success(null);
        break;
      }
      case "symbolManager#textIgnorePlacement": {
        if(symbolManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "symbol"), null);
          return;
        }
        final Boolean iconAllowOverlap = call.argument("textIgnorePlacement");
        symbolManager.setTextIgnorePlacement(iconAllowOverlap);
        result.success(null);
        break;
      }
      case "line#add": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        final LineBuilder lineBuilder = newLineBuilder();
        Convert.interpretLineOptions(call.argument("options"), lineBuilder);
        final Line line = lineBuilder.build();
        final String lineId = String.valueOf(line.getId());
        lines.put(lineId, new LineController(line,  annotationConsumeTapEvents.contains("AnnotationType.line"), this));
        result.success(lineId);
        break;
      }
      case "line#remove": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        final String lineId = call.argument("line");
        removeLine(lineId);
        result.success(null);
        break;
      }
      case "line#addAll": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        List<String> newIds = new ArrayList<String>();
        final List<Object> options = call.argument("options");
        List<LineOptions> optionList = new ArrayList<LineOptions>();
        if (options != null) {
          LineBuilder builder;
          for (Object o : options) {
            builder = newLineBuilder();
            Convert.interpretLineOptions(o, builder);
            optionList.add(builder.getLineOptions());
          }
          if (!optionList.isEmpty()) {
            List<Line> newLines = lineManager.create(optionList);
            String id;
            for (Line line : newLines) {
              id = String.valueOf(line.getId());
              newIds.add(id);
              lines.put(id, new LineController(line, true, this));
            }
          }
        }
        result.success(newIds);
        break;
      }
      case "line#removeAll": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        final ArrayList<String> ids = call.argument("ids");
        LineController lineController;

        List<Line> toBeRemoved = new ArrayList<Line>();
        for(String id : ids){
            lineController = lines.remove(id);
            if (lineController != null) {
              toBeRemoved.add(lineController.getLine());
            }
        }
        if(!toBeRemoved.isEmpty()) {
          lineManager.delete(toBeRemoved);
        }
        result.success(null);
        break;
      }
      case "line#update": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        final String lineId = call.argument("line");
        final LineController line = line(lineId);
        Convert.interpretLineOptions(call.argument("options"), line);
        line.update(lineManager);
        result.success(null);
        break;
      }
      case "line#getGeometry": {
        if(lineManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "line"), null);
          return;
        }
        final String lineId = call.argument("line");
        final LineController line = line(lineId);
        final List<LatLng> lineLatLngs = line.getGeometry();
        final List<Object> resultList = new ArrayList<>();
        for (LatLng latLng: lineLatLngs){
          Map<String, Double> hashMapLatLng = new HashMap<>();
          hashMapLatLng.put("latitude", latLng.getLatitude());
          hashMapLatLng.put("longitude", latLng.getLongitude());
          resultList.add(hashMapLatLng);
        }
        result.success(resultList);
        break;
      }
      case "circle#add": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        final CircleBuilder circleBuilder = newCircleBuilder();
        Convert.interpretCircleOptions(call.argument("options"), circleBuilder);
        final Circle circle = circleBuilder.build();
        final String circleId = String.valueOf(circle.getId());
        circles.put(circleId, new CircleController(circle,  annotationConsumeTapEvents.contains("AnnotationType.circle"), this));
        result.success(circleId);
        break;
      }
      case "circle#addAll": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        List<String> newIds = new ArrayList<String>();
        final List<Object> options = call.argument("options");
        List<CircleOptions> optionList = new ArrayList<CircleOptions>();
        if (options != null) {
          CircleBuilder builder;
          for (Object o : options) {
            builder = newCircleBuilder();
            Convert.interpretCircleOptions(o, builder);
            optionList.add(builder.getCircleOptions());
          }
          if (!optionList.isEmpty()) {
            List<Circle> newCircles = circleManager.create(optionList);
            String id;
            for (Circle circle : newCircles) {
              id = String.valueOf(circle.getId());
              newIds.add(id);
              circles.put(id, new CircleController(circle, true, this));
            }
          }
        }
        result.success(newIds);
        break;
      }
      case "circle#removeAll": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        final ArrayList<String> ids = call.argument("ids");
        CircleController circleController;

        List<Circle> toBeRemoved = new ArrayList<Circle>();
        for(String id : ids){
            circleController = circles.remove(id);
            if (circleController != null) {
              toBeRemoved.add(circleController.getCircle());
            }
        }
        if(!toBeRemoved.isEmpty()) {
          circleManager.delete(toBeRemoved);
        }
        result.success(null);
        break;
      }
      case "circle#remove": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        final String circleId = call.argument("circle");
        removeCircle(circleId);
        result.success(null);
        break;
      }
      case "circle#update": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        Log.e(TAG, "update circle");
        final String circleId = call.argument("circle");
        final CircleController circle = circle(circleId);
        Convert.interpretCircleOptions(call.argument("options"), circle);
        circle.update(circleManager);
        result.success(null);
        break;
      }
      case "circle#getGeometry": {
        if(circleManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "circle"), null);
          return;
        }
        final String circleId = call.argument("circle");
        final CircleController circle = circle(circleId);
        final LatLng circleLatLng = circle.getGeometry();
        Map<String, Double> hashMapLatLng = new HashMap<>();
        hashMapLatLng.put("latitude", circleLatLng.getLatitude());
        hashMapLatLng.put("longitude", circleLatLng.getLongitude());
        result.success(hashMapLatLng);
        break;
      }
      case "fill#add": {
        if(fillManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "fill"), null);
          return;
        }
        final FillBuilder fillBuilder = newFillBuilder();
        Convert.interpretFillOptions(call.argument("options"), fillBuilder);
        final Fill fill = fillBuilder.build();
        final String fillId = String.valueOf(fill.getId());
        fills.put(fillId, new FillController(fill,  annotationConsumeTapEvents.contains("AnnotationType.fill"), this));
        result.success(fillId);
        break;
      }

      case "fill#addAll": {
        if(fillManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "fill"), null);
          return;
        }
        List<String> newIds = new ArrayList<String>();
        final List<Object> options = call.argument("options");
        List<FillOptions> optionList = new ArrayList<FillOptions>();
        if (options != null) {
          FillBuilder builder;
          for (Object o : options) {
            builder = newFillBuilder();
            Convert.interpretFillOptions(o, builder);
            optionList.add(builder.getFillOptions());
          }
          if (!optionList.isEmpty()) {
            List<Fill> newFills = fillManager.create(optionList);
            String id;
            for (Fill fill : newFills) {
              id = String.valueOf(fill.getId());
              newIds.add(id);
              fills.put(id, new FillController(fill, true, this));
            }
          }
        }
        result.success(newIds);
        break;
      }
      case "fill#removeAll": {
        if(fillManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "fill"), null);
          return;
        }
        final ArrayList<String> ids = call.argument("ids");
        FillController fillController;

        List<Fill> toBeRemoved = new ArrayList<Fill>();
        for(String id : ids){
            fillController = fills.remove(id);
            if (fillController != null) {
              toBeRemoved.add(fillController.getFill());
            }
        }
        if(!toBeRemoved.isEmpty()) {
          fillManager.delete(toBeRemoved);
        }
        result.success(null);
        break;
      }
      case "fill#remove": {
        if(fillManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "fill"), null);
          return;
        }
        final String fillId = call.argument("fill");
        removeFill(fillId);
        result.success(null);
        break;
      }
      case "fill#update": {
        if(fillManager == null){
          result.error(annotationManagerNotCreatedErrorCode, String.format(annotationManagerNotCreatedErrorCode, "fill"), null);
          return;
        }
        final String fillId = call.argument("fill");
        final FillController fill = fill(fillId);
        Convert.interpretFillOptions(call.argument("options"), fill);
        fill.update(fillManager);
        result.success(null);
        break;
      }
      case "source#addGeoJson": {
        final String sourceId = call.argument("sourceId");
        final String geojson = call.argument("geojson");
        addGeoJsonSource(sourceId, geojson);
        result.success(null);
        break;
      }
      case "source#setGeoJson": {
        final String sourceId = call.argument("sourceId");
        final String geojson = call.argument("geojson");
        setGeoJsonSource(sourceId, geojson);
        result.success(null);
        break;
      }
      case "symbolLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final String sourceLayer = call.argument("sourceLayer");
        final PropertyValue[] properties = LayerPropertyConverter.interpretSymbolLayerProperties(call.argument("properties"));
        addSymbolLayer(layerId, sourceId, belowLayerId, sourceLayer, properties, null);
        result.success(null);
        break;
      }
      case "lineLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final String sourceLayer = call.argument("sourceLayer");
        final PropertyValue[] properties = LayerPropertyConverter.interpretLineLayerProperties(call.argument("properties"));
        addLineLayer(layerId, sourceId, belowLayerId, sourceLayer,  properties, null);
        result.success(null);
        break;
      }
      case "fillLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final String sourceLayer = call.argument("sourceLayer");
        final PropertyValue[] properties = LayerPropertyConverter.interpretFillLayerProperties(call.argument("properties"));
        addFillLayer(layerId, sourceId, belowLayerId, sourceLayer,  properties, null);
        result.success(null);
        break;
      }
      case "circleLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final String sourceLayer = call.argument("sourceLayer");
        final PropertyValue[] properties = LayerPropertyConverter.interpretCircleLayerProperties(call.argument("properties"));
        addCircleLayer(layerId, sourceId, belowLayerId, sourceLayer,  properties, null);
        result.success(null);
        break;
      }
      case "rasterLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final PropertyValue[] properties = LayerPropertyConverter.interpretRasterLayerProperties(call.argument("properties"));
        addRasterLayer(layerId, sourceId, belowLayerId, properties, null);
        result.success(null);
        break;
      }
      case "hillshadeLayer#add": {
        final String sourceId = call.argument("sourceId");
        final String layerId = call.argument("layerId");
        final String belowLayerId = call.argument("belowLayerId");
        final PropertyValue[] properties = LayerPropertyConverter.interpretHillshadeLayerProperties(call.argument("properties"));
        addHillshadeLayer(layerId, sourceId, belowLayerId, properties, null);
        result.success(null);
        break;
      }
      case "locationComponent#getLastLocation": {
        Log.e(TAG, "location component: getLastLocation");
        if (this.myLocationEnabled && locationComponent != null && locationEngine != null) {
          Map<String, Object> reply = new HashMap<>();
          locationEngine.getLastLocation(new LocationEngineCallback<LocationEngineResult>() {
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
      case "style#addImage": {
        if(style==null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        style.addImage(call.argument("name"), BitmapFactory.decodeByteArray(call.argument("bytes"),0,call.argument("length")), call.argument("sdf"));
        result.success(null);
        break;
      }
      case "style#addImageSource": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        List<LatLng> coordinates = Convert.toLatLngList(call.argument("coordinates"), false);
        style.addSource(new ImageSource(call.argument("imageSourceId"), new LatLngQuad(coordinates.get(0), coordinates.get(1), coordinates.get(2), coordinates.get(3)), BitmapFactory.decodeByteArray(call.argument("bytes"), 0, call.argument("length"))));
        result.success(null);
        break;
      }
      case "style#addSource":{
        final String id = Convert.toString(call.argument("sourceId"));
        final Map<String, Object> properties = (Map<String, Object>) call.argument("properties");
        SourcePropertyConverter.addSource(id, properties, style);
        result.success(null);
        break;
      }
      
      case "style#removeSource": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        style.removeSource((String) call.argument("sourceId"));
        result.success(null);
        break;
      }
      case "style#setSource": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        style.removeSource((String) call.argument("sourceId"));
        result.success(null);
        break;
      }
      case "style#addLayer": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        style.addLayer(new RasterLayer(call.argument("imageLayerId"), call.argument("imageSourceId")));
        result.success(null);
        break;
      }
      case "style#addLayerBelow": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        style.addLayerBelow(new RasterLayer(call.argument("imageLayerId"), call.argument("imageSourceId")), call.argument("belowLayerId"));
        result.success(null);
        break;
      }
      case "style#removeLayer": {
        if (style == null) {
          result.error("STYLE IS NULL", "The style is null. Has onStyleLoaded() already been invoked?", null);
        }
        String layerId = call.argument("layerId");
        style.removeLayer(layerId);
        featureLayerIdentifiers.remove(layerId);

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
  public boolean onAnnotationClick(Annotation annotation) {
    if (annotation instanceof Symbol) {
      final SymbolController symbolController = symbols.get(String.valueOf(annotation.getId()));
      if (symbolController != null) {
        return symbolController.onTap();
      }
    }

    if (annotation instanceof Line) {
      final LineController lineController = lines.get(String.valueOf(annotation.getId()));
      if (lineController != null) {
        return lineController.onTap();
      }
    }

    if (annotation instanceof Circle) {
      final CircleController circleController = circles.get(String.valueOf(annotation.getId()));
      if (circleController != null) {
        return circleController.onTap();
      }
    }
    if (annotation instanceof Fill) {
      final FillController fillController = fills.get(String.valueOf(annotation.getId()));
      if (fillController != null) {
        return fillController.onTap();
      }
    }
    return false;
  }

  @Override
  public void onSymbolTapped(Symbol symbol) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("symbol", String.valueOf(symbol.getId()));
    methodChannel.invokeMethod("symbol#onTap", arguments);
  }

  @Override
  public void onLineTapped(Line line) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("line", String.valueOf(line.getId()));
    methodChannel.invokeMethod("line#onTap", arguments);
  }

  @Override
  public void onCircleTapped(Circle circle) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("circle", String.valueOf(circle.getId()));
    methodChannel.invokeMethod("circle#onTap", arguments);
  }

  @Override
  public void onFillTapped(Fill fill) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("fill", String.valueOf(fill.getId()));
    methodChannel.invokeMethod("fill#onTap", arguments);
  }

  @Override
  public boolean onMapClick(@NonNull LatLng point) {
    PointF pointf = mapboxMap.getProjection().toScreenLocation(point);
    RectF rectF = new RectF(
      pointf.x - 10,
      pointf.y - 10,
      pointf.x + 10,
      pointf.y + 10
    );
    Feature feature = firstFeatureOnLayers(rectF);
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("lng", point.getLongitude());
    arguments.put("lat", point.getLatitude());
    if(feature != null){
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

  private void destroyMapViewIfNecessary() {
    if (mapView == null) {
      return;
    }

    if (locationComponent != null) {
      locationComponent.setLocationComponentEnabled(false);
    }
    if (symbolManager != null) {
      symbolManager.onDestroy();
    }
    if (lineManager != null) {
      lineManager.onDestroy();
    }
    if (circleManager != null) {
      circleManager.onDestroy();
    }
    if (fillManager != null) {
      fillManager.onDestroy();
    }
    stopListeningForLocationUpdates();

    mapView.onDestroy();
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
    if(myLocationEnabled){
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
    switch(gravity) {
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
    switch(mapboxMap.getUiSettings().getCompassGravity())
    {
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
    switch(gravity) {
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
    switch(mapboxMap.getUiSettings().getAttributionGravity())
    {
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
    if(this.locationComponent == null && myLocationEnabled){
      enableLocationComponent(mapboxMap.getStyle());
    }

    if(myLocationEnabled){
      startListeningForLocationUpdates();
    }else {
      stopListeningForLocationUpdates();
    }

    locationComponent.setLocationComponentEnabled(myLocationEnabled);
  }

  private void startListeningForLocationUpdates(){
    if(locationEngineCallback == null && locationComponent!=null && locationComponent.getLocationEngine()!=null){
      locationEngineCallback = new LocationEngineCallback<LocationEngineResult>() {
        @Override
        public void onSuccess(LocationEngineResult result) {
          onUserLocationUpdate(result.getLastLocation());
        }

        @Override
        public void onFailure(@NonNull Exception exception) {
        }
      };
      locationComponent.getLocationEngine().requestLocationUpdates(locationComponent.getLocationEngineRequest(), locationEngineCallback , null);
    }
  }

  private void stopListeningForLocationUpdates(){
    if(locationEngineCallback != null && locationComponent!=null && locationComponent.getLocationEngine()!=null){
      locationComponent.getLocationEngine().removeLocationUpdates(locationEngineCallback);
      locationEngineCallback = null;
    }
  }

  private void updateMyLocationTrackingMode() {
    int[] mapboxTrackingModes = new int[] {CameraMode.NONE, CameraMode.TRACKING, CameraMode.TRACKING_COMPASS, CameraMode.TRACKING_GPS};
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
        stringBuilder.append(imagePathList.get(imagePathList.size()-1));
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

  /**
   * Simple Listener to listen for the status of camera movements.
   */
  public class OnCameraMoveFinishedListener implements MapboxMap.CancelableCallback{
    @Override
    public void onFinish() {
    }

    @Override
    public void onCancel() {
    }
  }
}
