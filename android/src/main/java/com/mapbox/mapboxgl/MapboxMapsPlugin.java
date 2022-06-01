// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.mapbox.mapboxgl;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Plugin for controlling a set of MapboxMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using MapboxMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class MapboxMapsPlugin implements FlutterPlugin, ActivityAware {

  private static final String VIEW_TYPE = "plugins.flutter.io/mapbox_gl";

  static FlutterAssets flutterAssets;
  private Lifecycle lifecycle;

  public MapboxMapsPlugin() {
    // no-op
  }

  // New Plugin APIs

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    flutterAssets = binding.getFlutterAssets();

    MethodChannel methodChannel =
        new MethodChannel(binding.getBinaryMessenger(), "plugins.flutter.io/mapbox_gl");
    methodChannel.setMethodCallHandler(new GlobalMethodHandler(binding));

    binding
        .getPlatformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.io/mapbox_gl",
            new MapboxMapFactory(
                binding.getBinaryMessenger(),
                new LifecycleProvider() {
                  @Nullable
                  @Override
                  public Lifecycle getLifecycle() {
                    return lifecycle;
                  }
                }));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // no-op
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
  }

  // Old Plugin APIs

  public static void registerWith(Registrar registrar) {
    final Activity activity = registrar.activity();
    if (activity == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }
    if (activity instanceof LifecycleOwner) {
      registrar
          .platformViewRegistry()
          .registerViewFactory(
              VIEW_TYPE,
              new MapboxMapFactory(
                  registrar.messenger(),
                  new LifecycleProvider() {
                    @Override
                    public Lifecycle getLifecycle() {
                      return ((LifecycleOwner) activity).getLifecycle();
                    }
                  }));
    } else {
      registrar
          .platformViewRegistry()
          .registerViewFactory(
              VIEW_TYPE,
              new MapboxMapFactory(registrar.messenger(), new ProxyLifecycleProvider(activity)));
    }

    MethodChannel methodChannel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/mapbox_gl");
    methodChannel.setMethodCallHandler(new GlobalMethodHandler(registrar));
  }

  private static final class ProxyLifecycleProvider
      implements Application.ActivityLifecycleCallbacks, LifecycleOwner, LifecycleProvider {

    private final LifecycleRegistry lifecycle = new LifecycleRegistry(this);
    private final int registrarActivityHashCode;

    private ProxyLifecycleProvider(Activity activity) {
      this.registrarActivityHashCode = activity.hashCode();
      activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
    }

    @Override
    public void onActivityStarted(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START);
    }

    @Override
    public void onActivityResumed(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
    }

    @Override
    public void onActivityPaused(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    }

    @Override
    public void onActivityStopped(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      activity.getApplication().unregisterActivityLifecycleCallbacks(this);
      lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
      return lifecycle;
    }
  }

  interface LifecycleProvider {
    @Nullable
    Lifecycle getLifecycle();
  }

  /** Provides a static method for extracting lifecycle objects from Flutter plugin bindings. */
  public static class FlutterLifecycleAdapter {

    /**
     * Returns the lifecycle object for the activity a plugin is bound to.
     *
     * <p>Returns null if the Flutter engine version does not include the lifecycle extraction code.
     * (this probably means the Flutter engine version is too old).
     */
    @NonNull
    public static Lifecycle getActivityLifecycle(
        @NonNull ActivityPluginBinding activityPluginBinding) {
      HiddenLifecycleReference reference =
          (HiddenLifecycleReference) activityPluginBinding.getLifecycle();
      return reference.getLifecycle();
    }
  }
}
