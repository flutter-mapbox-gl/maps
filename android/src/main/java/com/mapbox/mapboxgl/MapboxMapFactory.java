package com.mapbox.mapboxgl;

import android.content.Context;

import com.mapbox.mapboxsdk.camera.CameraPosition;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class MapboxMapFactory extends PlatformViewFactory {

  private final BinaryMessenger messenger;
  private final MapboxMapsPlugin.LifecycleProvider lifecycleProvider;

  public MapboxMapFactory(BinaryMessenger messenger, MapboxMapsPlugin.LifecycleProvider lifecycleProvider) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
    this.lifecycleProvider = lifecycleProvider;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    Map<String, Object> params = (Map<String, Object>) args;
    final MapboxMapBuilder builder = new MapboxMapBuilder();

    Convert.interpretMapboxMapOptions(params.get("options"), builder);
    if (params.containsKey("initialCameraPosition")) {
      CameraPosition position = Convert.toCameraPosition(params.get("initialCameraPosition"));
      builder.setInitialCameraPosition(position);
    }
    return builder.build(id, context, messenger, lifecycleProvider, (String) params.get("accessToken"));
  }
}
