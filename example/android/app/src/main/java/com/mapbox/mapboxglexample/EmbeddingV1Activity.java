package com.mapbox.mapboxglexample;

import android.os.Bundle;

import com.mapbox.mapboxgl.MapboxMapsPlugin;

import io.flutter.app.FlutterActivity;

public class EmbeddingV1Activity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MapboxMapsPlugin.registerWith(registrarFor("com.mapbox.mapboxgl.MapboxMapsPlugin"));
  }
}