package com.mapbox.mapboxgl.utils;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import com.mapbox.mapboxgl.MapboxMapController;

public class AccesToken {

  public static String getAccessToken(@NonNull Context context) {
    try {
      ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      Bundle bundle = ai.metaData;
      return bundle.getString("com.mapbox.token");
    } catch (PackageManager.NameNotFoundException e) {
      Log.e(MapboxMapController.TAG, "Failed to load meta-data, NameNotFound: " + e.getMessage());
    } catch (NullPointerException e) {
      Log.e(MapboxMapController.TAG, "Failed to load meta-data, NullPointer: " + e.getMessage());
    }
    return null;
  }
}
