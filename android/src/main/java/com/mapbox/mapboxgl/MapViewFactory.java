package com.mapbox.mapboxgl;

import android.content.Context;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.PluginRegistry;

public class MapViewFactory extends PlatformViewFactory {
    private final AtomicInteger mActivityState;
    private final PluginRegistry.Registrar registrar;

    public MapViewFactory(AtomicInteger state, PluginRegistry.Registrar registrar) {
        super(StandardMessageCodec.INSTANCE);
        mActivityState = state;
        this.registrar = registrar;
    }

    @Override
    public PlatformView create(Context context, int id, Object o) {
        FlutterMapView fmv = new FlutterMapView(context, mActivityState, registrar, id);
        fmv.init();
        return fmv;
    }
}