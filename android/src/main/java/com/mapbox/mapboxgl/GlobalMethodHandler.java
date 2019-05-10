package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class GlobalMethodHandler implements MethodChannel.MethodCallHandler {
    private static final String TAG = GlobalMethodHandler.class.getSimpleName();
    private static final String DATABASE_NAME = "mbgl-offline.db";
    private static final int BUFFER_SIZE = 1024 * 2;
    private final PluginRegistry.Registrar registrar;

    GlobalMethodHandler(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "installOfflineMapTiles":
                String tilesDb = methodCall.argument("tilesdb");
                String assetKey = registrar.lookupKeyForAsset(tilesDb);
                installOfflineMapTiles(assetKey);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void installOfflineMapTiles(String assetKey) {
        final Context context = registrar.activeContext();
        try {
            File dest = new File(context.getFilesDir(), DATABASE_NAME);
            copy(context.getAssets().open(assetKey),
                    new FileOutputStream(dest));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static int copy(InputStream input, OutputStream output) throws IOException {
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
        return count;
    }
}