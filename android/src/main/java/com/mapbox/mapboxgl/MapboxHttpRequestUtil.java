package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.module.http.HttpRequestUtil;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import okhttp3.OkHttpClient;
import okhttp3.Request;

abstract class MapboxHttpRequestUtil {

  public static void setHttpHeaders(Map<String, String> headers, MethodChannel.Result result) {
    HttpRequestUtil.setOkHttpClient(getOkHttpClient(headers, result).build());
    result.success(null);
  }

  private static OkHttpClient.Builder getOkHttpClient(
      Map<String, String> headers, MethodChannel.Result result) {
    try {
      return new OkHttpClient.Builder()
          .addNetworkInterceptor(
              chain -> {
                Request.Builder builder = chain.request().newBuilder();
                for (Map.Entry<String, String> header : headers.entrySet()) {
                  if (header.getKey() == null || header.getKey().trim().isEmpty()) {
                    continue;
                  }
                  if (header.getValue() == null || header.getValue().trim().isEmpty()) {
                    builder.removeHeader(header.getKey());
                  } else {
                    builder.header(header.getKey(), header.getValue());
                  }
                }
                return chain.proceed(builder.build());
              });
    } catch (Exception e) {
      result.error(
          "OK_HTTP_CLIENT_ERROR",
          "An unexcepted error happened during creating http " + "client" + e.getMessage(),
          null);
      throw new RuntimeException(e);
    }
  }
}
