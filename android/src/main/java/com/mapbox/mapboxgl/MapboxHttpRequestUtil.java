package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.module.http.HttpRequestUtil;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import java.util.List;
import okhttp3.OkHttpClient;
import okhttp3.Request;

abstract class MapboxHttpRequestUtil {

  public static void setHttpHeaders(Map<String, String> headers, List<String> filter, MethodChannel.Result result) {
    HttpRequestUtil.setOkHttpClient(getOkHttpClient(headers, filter, result).build());
    MapboxHttpRequestUtil.headers = headers;
    MapboxHttpRequestUtil.filter = filter;
    result.success(null);
  }

  public static void getHttpHeader(MethodChannel.Result result) {
    result(MapboxHttpRequestUtil.headers);
  }

  private static Map<String, String> headers = null;
  private static List<String> filter = null;

  private static OkHttpClient.Builder getOkHttpClient(
      Map<String, String> headers, List<String> filter, MethodChannel.Result result) {
    try {
      return new OkHttpClient.Builder()
          .addNetworkInterceptor(
              chain -> {
                Request request = chain.request();
                Request.Builder builder = request.newBuilder();
                boolean useHeaders = true;
                if (filter != null) {
                  useHeaders = false;
                  for (String pattern : filter) {
                    if (request.url().toString().contains(pattern)) {
                      useHeaders = true;
                      break;
                    }
                  }
                }
                if (useHeaders) {
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
