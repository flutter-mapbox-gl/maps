package com.mapbox.mapboxgl;

import androidx.annotation.Nullable;
import com.google.gson.Gson;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;

public class OfflineChannelHandlerImpl implements EventChannel.StreamHandler {
  private EventChannel.EventSink sink;
  private Gson gson = new Gson();

  OfflineChannelHandlerImpl(BinaryMessenger messenger, String channelName) {
    EventChannel eventChannel = new EventChannel(messenger, channelName);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    sink = null;
  }

  void onError(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (sink == null) return;
    sink.error(errorCode, errorMessage, errorDetails);
  }

  void onSuccess() {
    if (sink == null) return;
    Map<String, Object> body = new HashMap<>();
    body.put("status", "success");
    sink.success(gson.toJson(body));
  }

  void onStart() {
    if (sink == null) return;
    Map<String, Object> body = new HashMap<>();
    body.put("status", "start");
    sink.success(gson.toJson(body));
  }

  void onProgress(double progress) {
    if (sink == null) return;
    Map<String, Object> body = new HashMap<>();
    body.put("status", "progress");
    body.put("progress", progress);
    sink.success(gson.toJson(body));
  }
}
