package com.mapbox.mapboxgl;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import com.mapbox.mapboxsdk.Mapbox;

abstract class MapBoxUtils {
  private static final String TAG = "MapboxMapController";

  static Mapbox getMapbox(Context context, String accessToken) {
    return Mapbox.getInstance(context, accessToken == null ? getAccessToken(context) : accessToken);
  }

  private static String getAccessToken(@NonNull Context context) {
    try {
      ApplicationInfo ai =
          context
              .getPackageManager()
              .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      Bundle bundle = ai.metaData;
      String token = bundle.getString("com.mapbox.token");
      if (token == null || token.isEmpty()) {
        throw new NullPointerException();
      }
      return token;
    } catch (Exception e) {
      Log.e(
          TAG,
          "Failed to find an Access Token in the Application meta-data. Maps may not load"
              + " correctly. Please refer to the installation guide at"
              + " https://github.com/tobrun/flutter-mapbox-gl#mapbox-access-token for"
              + " troubleshooting advice."
              + e.getMessage());
    }
    return null;
  }
}
