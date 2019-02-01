package com.mapbox.mapboxgl;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.graphics.RectF;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.mapbox.mapboxgl.MapboxGlPlugin.CREATED;
import static com.mapbox.mapboxgl.MapboxGlPlugin.DESTROYED;
import static com.mapbox.mapboxgl.MapboxGlPlugin.PAUSED;
import static com.mapbox.mapboxgl.MapboxGlPlugin.RESUMED;
import static com.mapbox.mapboxgl.MapboxGlPlugin.STARTED;
import static com.mapbox.mapboxgl.MapboxGlPlugin.STOPPED;
import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.common.PluginRegistry;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;


import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;

import com.mapbox.geojson.Feature;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.constants.Style;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.ProjectedMeters;
import com.mapbox.mapboxsdk.maps.MapboxMapOptions;
import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.Layer;

import static com.mapbox.mapboxsdk.style.layers.Property.NONE;
import static com.mapbox.mapboxsdk.style.layers.Property.VISIBLE;
import static com.mapbox.mapboxsdk.style.layers.PropertyFactory.visibility;

import com.mapbox.mapboxsdk.location.LocationComponent;
import com.mapbox.mapboxsdk.location.LocationComponentOptions;
import com.mapbox.mapboxsdk.location.modes.CameraMode;
import com.mapbox.mapboxsdk.location.modes.RenderMode;

import com.mapbox.android.core.permissions.PermissionsManager;

import android.support.v4.content.ContextCompat;
import com.mapbox.mapboxgl.R;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import android.graphics.PointF;

public class FlutterMapView
    implements PlatformView, MethodCallHandler, OnMapReadyCallback, MapboxMap.OnMapClickListener,
    Application.ActivityLifecycleCallbacks{
  private final MethodChannel methodChannel;
  private final MapView mapView;
  private MapboxMap mapboxMap;
  private final PluginRegistry.Registrar registrar;
  private final AtomicInteger activityState;
  private final int registrarActivityHashCode;
  private boolean disposed = false;
  Context context;

  FlutterMapView(Context context, AtomicInteger state, PluginRegistry.Registrar registrar, int id) {
    try {
      ApplicationInfo ai = registrar.activity().getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      Bundle bundle = ai.metaData;
      String token = bundle.getString("com.mapbox.token");
      Mapbox.getInstance(context,token);
    } catch (Exception e) {
        Log.e("MBGL", "Please configure <meta-data android:name=\"com.mapbox.token\" android:value=\"YOUR_MAPBOX_TOKEN\"/> in your AndroidManifest.xml file.");
    }

    this.context = context;
    MapboxMapOptions mbmo = null;
    mapView = new MapView(context, mbmo);
    mapView.getMapAsync(this);
    MapView.LayoutParams lp = new MapView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT);
    mapView.setLayoutParams(lp);
    methodChannel = new MethodChannel(registrar.messenger(), "com.mapbox/mapboxgl_" + id);
    methodChannel.setMethodCallHandler(this);
    this.registrar = registrar;
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(this);
    activityState = state;
    this.registrarActivityHashCode = registrar.activity().hashCode();
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
        // Nothing to do, the activity has been completely destroyed.
        break;
      default:
        throw new IllegalArgumentException(
                "Cannot interpret " + activityState.get() + " as an activity state");
    }
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(this);
    mapView.getMapAsync(this);
  }

  @Override
  public void onMapReady(MapboxMap mbMap) {
    Log.d("MBGL","onMapReady");
    mapboxMap = mbMap;

    mapboxMap.addOnMapClickListener(this);
  }

  @SuppressWarnings({"MissingPermission"})
  private void enableLocationComponent() {
    // Check if permissions are enabled and if not request
    if (PermissionsManager.areLocationPermissionsGranted(context)) {

      LocationComponentOptions options = LocationComponentOptions.builder(context)
      .trackingGesturesManagement(true)
      // .accuracyColor(ContextCompat.getColor(context, R.color.mapboxGreen))
      // .accuracyColor(0x3887BE)
      .build();

      // Get an instance of the component
      LocationComponent locationComponent = mapboxMap.getLocationComponent();

      // Activate with options
      locationComponent.activateLocationComponent(context, options);

      // Enable to make component visible
      locationComponent.setLocationComponentEnabled(true);

      // Set the component's camera mode
      locationComponent.setCameraMode(CameraMode.TRACKING);
      locationComponent.setRenderMode(RenderMode.COMPASS);
    }
  }

  @Override
  public void onMapClick(@NonNull LatLng point) {
    PointF pointf = mapboxMap.getProjection().toScreenLocation(point);
    final Map<String, Object> arguments = new HashMap<>(5);
    arguments.put("x", pointf.x);
    arguments.put("y", pointf.y);
    arguments.put("lng", point.getLongitude());
    arguments.put("lat", point.getLatitude());
    methodChannel.invokeMethod("onTap", arguments);// map#onTap
  }

  // todo: MUST DEAL HERE WITH LIFECYCLE METHODS!

  @Override
  public View getView() {
    return mapView;
  }

  @Override
  public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
    switch (methodCall.method) {

    case "showUserLocation": {
      enableLocationComponent();
      break;
    }
    case "setStyleUrl": {
      String styleUrl = (String) methodCall.arguments;
      mapboxMap.setStyleUrl(styleUrl);
      result.success(null);
      break;
    }

    case "getStyleUrl": {
      Map<String, Object> reply = new HashMap<>();
      reply.put("styleUrl", mapboxMap.getStyleUrl());
      result.success(reply);
      break;
    }

    //
    // Camera API
    //

    case "easeTo": {
      CameraPosition cameraPosition = parseCamera(methodCall.argument("camera"));
      int duration = intParamOfCall(methodCall, "duration");
      CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
      mapboxMap.easeCamera(cameraUpdate, duration, true);
      result.success(null);
      break;
    }

    case "flyTo": {
      CameraPosition cameraPosition = parseCamera(methodCall.argument("camera"));
      int duration = intParamOfCall(methodCall, "duration");
      CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
      mapboxMap.animateCamera(cameraUpdate, duration);
      result.success(null);
      break;
    }

    case "jumpTo": {
      CameraPosition cameraPosition = parseCamera(methodCall.argument("camera"));
      CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
      mapboxMap.moveCamera(cameraUpdate);
      result.success(null);
      break;
    }

    case "zoom": {

      double zoom = doubleParamOfCall(methodCall, "zoom");
      int duration = intParamOfCall(methodCall, "duration");

      CameraPosition cameraPosition = new CameraPosition.Builder().zoom(zoom).build();
      CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
      mapboxMap.easeCamera(cameraUpdate, duration, true);
      result.success(null);
      break;
    }

    case "queryRenderedFeatures": {
        Map<String, Object> reply = new HashMap<>();
        List<Feature> features;
        String[] layerIds = stringListParamOfCall(methodCall,"layerIds");
        String filter = stringParamOfCall(methodCall,"filter");
        Expression filterExpression = filter == null ? null : new Expression(filter);
        if (methodCall.hasArgument("x")) {
            PointF pixel = screenPointParamOfCall(methodCall);
            features = mapboxMap.queryRenderedFeatures(pixel, filterExpression, layerIds);
        } else {
            RectF rectF = screenRectParamOfCall(methodCall);
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

      case "setLayerProperty": {

        setLayerProperty(methodCall,result);
        break;
      }




    // case "zoomBy": {
    // double zoomBy = doubleParamOfCall(methodCall, "zoomBy");
    // float x = floatParamOfCall(methodCall, "x");
    // float y = floatParamOfCall(methodCall, "y");
    // long duration = longParamOfCall(methodCall, "duration");
    // mapboxMap.zoom(mapboxMap.getZoom() + zoomBy, new PointF(x, y), duration);
    // result.success(null);
    // break;
    // }

    // case "getZoom": {
    // Map<String, Object> reply = new HashMap<>();
    // reply.put("zoom", mapboxMap.getZoom());
    // result.success(reply);
    // break;
    // }

    // case "getMinZoom": {
    // Map<String, Object> reply = new HashMap<>();
    // reply.put("zoom", mapboxMap.getMinZoom());
    // result.success(reply);
    // break;
    // }

    // case "setMinZoom": {
    // double zoom = doubleParamOfCall(methodCall, "zoom");
    // mapboxMap.setMinZoom(zoom);
    // result.success(null);
    // break;
    // }

    // case "getMaxZoom": {
    // Map<String, Object> reply = new HashMap<>();
    // reply.put("zoom", mapboxMap.getMaxZoomLevel());
    // result.success(reply);
    // break;
    // }

    // case "setMaxZoom": {
    // double zoom = doubleParamOfCall(methodCall, "zoom");
    // mapboxMap.setMaxZoomPreference(zoom);
    // result.success(null);
    // break;
    // }

    default:
      result.notImplemented();
    }

  }


  void setLayerProperty(MethodCall methodCall, MethodChannel.Result result){

    //dart code:
//    await _channel.invokeMethod(
//            'propertyName',
//            <String, Object>{
//            'layer': layer,
//            'propertyName': propertyName,
//            'value': value,
//            'options': options, //if we cannot transfer a map, we should convert this to JSON
//        },
//      );

    Log.d("dddd","setLayerProperty");
    String layerId = stringParamOfCall(methodCall, "layer");
    String propertyName = stringParamOfCall(methodCall, "propertyName");

    Layer layer = mapboxMap.getLayer(layerId);

    if(layer==null){
      result.error("0","layer "+layerId+" not found.",null);
      return;
    }

    if(propertyName.equals("visibility")){
      String value = "";
      try {
        value = (String) methodCall.argument("value");
      }
      catch (ClassCastException cce){
        result.error("0","cast exception thrown - value of visibility should be a String. in layer:"+layerId+".",null);
        return;
      }
      if(value.equals("visible"))
        layer.setProperties(visibility(VISIBLE));
      else if(value.equals("none"))
        layer.setProperties(visibility(NONE));
      else{
        result.error("0","value of visibility should be 'visible' or 'none', received value:"+value+".",null);
        return;
      }
    }
    else{
      result.error("0","property "+propertyName+" not implemented.",null);
      return;
    }

    result.success(null);
  }


  // Utils. should be refractored.
  private boolean booleanParamOfCall(MethodCall call, String param) {
    return Boolean.parseBoolean(call.argument(param));
  }

  private double doubleParamOfCall(MethodCall call, String param) {
    return ((Number) call.argument(param)).doubleValue();
  }

  private float floatParamOfCall(MethodCall call, String param) {
    return ((Number) call.argument(param)).floatValue();
  }

  private int intParamOfCall(MethodCall call, String param) {
    return ((Number) call.argument(param)).intValue();
  }

  private long longParamOfCall(MethodCall call, String param) {
    return ((Number) call.argument(param)).longValue();
  }

  private String stringParamOfCall(MethodCall call, String param) {
    return (String) call.argument(param);
  }

    private PointF screenPointParamOfCall(MethodCall call) {
        Double x = call.argument("x");
        Double y = call.argument("y");
        return new PointF(x.floatValue(), y.floatValue());
    }

    private RectF screenRectParamOfCall(MethodCall call) {
        Double left = call.argument("left");
        Double top = call.argument("top");
        Double right = call.argument("right");
        Double bottom = call.argument("bottom");
        return new RectF(left.floatValue(), top.floatValue(), right.floatValue(), bottom.floatValue());
    }

  private String[] stringListParamOfCall(MethodCall call, String param) {
      ArrayList<String> arrayList = (ArrayList<String>) call.argument(param);
      return arrayList == null ? null : arrayList.toArray(new String[arrayList.size()]);
  }


  private MapboxMapOptions parseOptions(Map<String, Object> options) {

    String style = (String) options.get("style");
    if (style == null) {
      style = Style.MAPBOX_STREETS;
    }
    MapboxMapOptions mapOptions = new MapboxMapOptions().styleUrl(style);

    Map<String, Object> camera = (Map<String, Object>) options.get("camera");
    if (camera != null) {
      mapOptions.camera(parseCamera(camera));
    }
    return mapOptions;
  }

  private CameraPosition parseCamera(Map<String, Object> camera) {
    CameraPosition.Builder cameraPosition = new CameraPosition.Builder();

    LatLng target = parseLatLng((Map<String, Object>) camera.get("target"));
    if (target != null) {
      cameraPosition.target(target);
    }

    Double zoom = (Double) camera.get("zoom");
    if (zoom != null) {
      cameraPosition.zoom(zoom);
    }

    Double bearing = (Double) camera.get("bearing");
    if (bearing != null) {
      cameraPosition.bearing(bearing);
    }

    Double tilt = (Double) camera.get("tilt");
    if (tilt != null) {
      cameraPosition.tilt(tilt);
    }

    return cameraPosition.build();
  }

  private LatLng parseLatLng(Map<String, Object> target) {
    if (target.containsKey("lat") && target.containsKey("lng")) {
      return new LatLng(((Number) target.get("lat")).doubleValue(), ((Number) target.get("lng")).doubleValue());
    }
    return null;
  }



  @Override
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    mapView.onDestroy();
    registrar.activity().getApplication().unregisterActivityLifecycleCallbacks(this);
  }





  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    Log.d("dddd","onactivitycreated");
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onCreate(savedInstanceState);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    Log.d("dddd","onActivityStarted");
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onActivityResumed(Activity activity) {
    Log.d("dddd","onActivityResumed");
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



}
