package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import com.mapbox.mapboxgl.models.DownloadRegionArgs;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineManager;
import com.mapbox.mapboxsdk.offline.OfflineRegion;
import com.mapbox.mapboxsdk.offline.OfflineRegionError;
import com.mapbox.mapboxsdk.offline.OfflineRegionStatus;
import com.mapbox.mapboxsdk.offline.OfflineTilePyramidRegionDefinition;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

interface OfflineManagerStatusHandler {
    void onError(OfflineRegionError error);

    void onError(String error);

    void onSuccess();

    void onProgressUpdate();
}

abstract class OfflineManagerUtils {
    private static final String TAG = "OfflineManagerUtils";

    static void downloadRegion(DownloadRegionArgs args, MethodChannel.Result result, PluginRegistry.Registrar registrar) {
        //Initialize Mapbox
        MapBoxUtils.getMapbox(registrar.context());
        // Set up the OfflineManager
        OfflineManager offlineManager = OfflineManager.getInstance(registrar.context());
        // Define the offline region
        OfflineTilePyramidRegionDefinition definition = generateRegionDefinition(args, registrar.context());
        //Prepare metadata
        byte[] metadata = prepareMetadata(args);
        //Tracker of result
        AtomicBoolean isComplete = new AtomicBoolean(false);
        //Download region
        offlineManager.createOfflineRegion(definition, metadata, new OfflineManager.CreateOfflineRegionCallback() {
            private OfflineRegion _offlineRegion;

            @Override
            public void onCreate(OfflineRegion offlineRegion) {
                _offlineRegion = offlineRegion;
                //Start downloading region
                _offlineRegion.setDownloadState(OfflineRegion.STATE_ACTIVE);
                //Observe downloading state
                OfflineRegion.OfflineRegionObserver observer = new OfflineRegion.OfflineRegionObserver() {
                    @Override
                    public void onStatusChanged(OfflineRegionStatus status) {
                        //Calculate progress of downloading
                        double progress = calculateDownloadingProgress(status.getRequiredResourceCount(), status.getCompletedResourceCount());
                        //Check if downloading is complete
                        if (status.isComplete()) {
                            Log.i(TAG, "Region downloaded successfully.");
                            //Reset downloading state
                            _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                            //This can be called multiple times, and result can be called only once, so there is need to prevent it
                            if (isComplete.get()) return;
                            isComplete.set(true);
                            result.success(null);
                        } else {
                            Log.i(TAG, "Region download progress = " + progress);
                        }
                    }

                    @Override
                    public void onError(OfflineRegionError error) {
                        Log.e(TAG, "onError reason: " + error.getReason());
                        Log.e(TAG, "onError message: " + error.getMessage());
                        //Reset downloading state
                        _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                        isComplete.set(true);
                        result.error("Downloading error", error.getMessage(), error.getReason());
                    }

                    @Override
                    public void mapboxTileCountLimitExceeded(long limit) {
                        Log.e(TAG, "Mapbox tile count limit exceeded: " + limit);
                        //Reset downloading state
                        _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                        isComplete.set(true);
                        result.error("mapboxTileCountLimitExceeded", "Mapbox tile count limit exceeded: " + limit, null);
                    }
                };
                _offlineRegion.setObserver(observer);
            }

            /**
             * This will be call if given region definition is invalid
             * @param error
             **/
            @Override
            public void onError(String error) {
                Log.e(TAG, "Error: " + error);
                //Reset downloading state
                _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                result.error("mapboxInvalidRegionDefinition", error, null);
            }
        });
    }

    private static double calculateDownloadingProgress(long requiredResourceCount, long completedResourceCount) {
        return requiredResourceCount >= 0
                ? (100.0 * completedResourceCount / requiredResourceCount) :
                0.0;
    }

    private static byte[] prepareMetadata(DownloadRegionArgs args) {
        //Make copy of received metadata
        Map<String, Object> metadata = new HashMap<>(args.getMetadata());
        //Add id to metadata
        metadata.put("id", args.getId());
        return metadata.toString().getBytes();
    }

    private static OfflineTilePyramidRegionDefinition generateRegionDefinition(DownloadRegionArgs args, Context context) {
        // Create a bounding box for the offline region
        LatLngBounds latLngBounds = args.getBounds();
        Log.i(TAG, "Bound = " + latLngBounds);
        return new OfflineTilePyramidRegionDefinition(
                args.getMapStyleUrl(),
                latLngBounds,
                args.getMinZoom(),
                args.getMaxZoom(),
                context.getResources().getDisplayMetrics().density);
    }
}
