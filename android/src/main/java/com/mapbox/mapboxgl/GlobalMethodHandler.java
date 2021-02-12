package com.mapbox.mapboxgl;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.mapbox.mapboxgl.models.OfflineRegionData;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class GlobalMethodHandler implements MethodChannel.MethodCallHandler {
    private static final String TAG = GlobalMethodHandler.class.getSimpleName();
    private static final String DATABASE_NAME = "mbgl-offline.db";
    private static final int BUFFER_SIZE = 1024 * 2;

    @Nullable
    private PluginRegistry.Registrar registrar;
    @Nullable
    private FlutterPlugin.FlutterAssets flutterAssets;
    @NonNull
    private final Context context;

    GlobalMethodHandler(@NonNull PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        this.context = registrar.activeContext();
    }

    GlobalMethodHandler(@NonNull Context context, @NonNull FlutterPlugin.FlutterAssets assets) {
        this.context = context;
        this.flutterAssets = assets;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "installOfflineMapTiles":
                String tilesDb = methodCall.argument("tilesdb");
                installOfflineMapTiles(tilesDb);
                result.success(null);
                break;
            case "downloadOfflineRegion":
                //Get download region arguments from caller
                Gson gson = new Gson();
                OfflineRegionData args = gson.fromJson(methodCall.arguments.toString(), OfflineRegionData.class);

                //Start downloading
                OfflineManagerUtils.downloadRegion(args, result, registrar, gson.fromJson(methodCall.arguments.toString(), JsonObject.class).get("accessToken").getAsString());
                break;
            case "getListOfRegions":
                OfflineManagerUtils.regionsList(result, registrar.context(), new Gson().fromJson(methodCall.arguments.toString(), JsonObject.class).get("accessToken").getAsString());
                break;
            case "deleteOfflineRegion":
                OfflineManagerUtils.deleteRegion(result, registrar.context(), (int) methodCall.argument("id"), new Gson().fromJson(methodCall.arguments.toString(), JsonObject.class).get("accessToken").getAsString());
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void installOfflineMapTiles(String tilesDb) {
        final File dest = new File(context.getFilesDir(), DATABASE_NAME);
        try (InputStream input = openTilesDbFile(tilesDb);
             OutputStream output = new FileOutputStream(dest)) {
            copy(input, output);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private InputStream openTilesDbFile(String tilesDb) throws IOException {
        if (tilesDb.startsWith("/")) { // Absolute path.
            return new FileInputStream(new File(tilesDb));
        } else {
            String assetKey;
            if (registrar != null) {
                assetKey = registrar.lookupKeyForAsset(tilesDb);
            } else if(flutterAssets != null) {
                assetKey = flutterAssets.getAssetFilePathByName(tilesDb);
            } else {
                throw new IllegalStateException();
            }
            return registrar.activeContext().getAssets().open(assetKey);
        }
    }

    private String extractAccessToken(MethodCall methodCall, String fallbackValue) {
        if (methodCall.hasArgument("accessToken")) {
            return methodCall.argument("accessToken");
        }

        return fallbackValue;
    }

    private static void copy(InputStream input, OutputStream output) throws IOException {
        final byte[] buffer = new byte[BUFFER_SIZE];
        final BufferedInputStream in = new BufferedInputStream(input, BUFFER_SIZE);
        final BufferedOutputStream out = new BufferedOutputStream(output, BUFFER_SIZE);
        int count = 0;
        int n = 0;
        try {
            while ((n = in.read(buffer, 0, BUFFER_SIZE)) != -1) {
                out.write(buffer, 0, n);
                count += n;
            }
            out.flush();
        } finally {
            try {
                out.close();
            } catch (IOException e) {
                Log.e(TAG, e.getMessage(), e);
            }
            try {
                in.close();
            } catch (IOException e) {
                Log.e(TAG, e.getMessage(), e);
            }
        }
    }
}