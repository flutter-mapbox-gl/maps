package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.mapbox.mapboxgl.models.OfflineRegionData;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineManager;
import com.mapbox.mapboxsdk.offline.OfflineRegion;
import com.mapbox.mapboxsdk.offline.OfflineRegionError;
import com.mapbox.mapboxsdk.offline.OfflineRegionStatus;
import com.mapbox.mapboxsdk.offline.OfflineTilePyramidRegionDefinition;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

abstract class OfflineManagerUtils {
    private static final String TAG = "OfflineManagerUtils";

    static void downloadRegion(OfflineRegionData offlineRegionData, MethodChannel.Result result, PluginRegistry.Registrar registrar, String accessToken) {
        //Initialize Mapbox
        MapBoxUtils.getMapbox(registrar.context(), accessToken);
        //Prepare channel
        String channelName = "downloadOfflineRegion_" + offlineRegionData.getId();
        OfflineChannelHandlerImpl channelHandler = new OfflineChannelHandlerImpl(registrar.messenger(), channelName);
        // Set up the OfflineManager
        OfflineManager offlineManager = OfflineManager.getInstance(registrar.context());
        // Define the offline region
        OfflineTilePyramidRegionDefinition definition = generateRegionDefinition(offlineRegionData, registrar.context());
        //Prepare metadata
        byte[] metadata = prepareMetadata(offlineRegionData);
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
                channelHandler.onStart();
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
                            channelHandler.onSuccess();
                            result.success(null);
                        } else {
                            Log.i(TAG, "Region download progress = " + progress);
                            channelHandler.onProgress(progress);
                        }
                    }

                    @Override
                    public void onError(OfflineRegionError error) {
                        Log.e(TAG, "onError reason: " + error.getReason());
                        Log.e(TAG, "onError message: " + error.getMessage());
                        //Reset downloading state
                        _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                        isComplete.set(true);
                        channelHandler.onError("Downloading error", error.getMessage(), error.getReason());
                        result.error("Downloading error", error.getMessage(), error.getReason());
                    }

                    @Override
                    public void mapboxTileCountLimitExceeded(long limit) {
                        Log.e(TAG, "Mapbox tile count limit exceeded: " + limit);
                        //Reset downloading state
                        _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                        isComplete.set(true);
                        channelHandler.onError("mapboxTileCountLimitExceeded", "Mapbox tile count limit exceeded: " + limit, null);
                        result.error("mapboxTileCountLimitExceeded", "Mapbox tile count limit exceeded: " + limit, null);
                        //Mapbox even after crash and not downloading fully region still keeps part of it in database, so we have to remove it
                        deleteRegion(null, registrar.context(), offlineRegionData.getId(), accessToken);
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
                channelHandler.onError("mapboxInvalidRegionDefinition", error, null);
                result.error("mapboxInvalidRegionDefinition", error, null);
            }
        });
    }

    static void regionsList(MethodChannel.Result result, Context context, String accessToken) {
        //Initialize Mapbox
        MapBoxUtils.getMapbox(context, accessToken);
        // Set up the OfflineManager
        OfflineManager offlineManager = OfflineManager.getInstance(context);
        offlineManager.listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                List<OfflineRegionData> regionsArgs = new ArrayList<>();
                for (OfflineRegion offlineRegion : offlineRegions) {
                    OfflineTilePyramidRegionDefinition definition = (OfflineTilePyramidRegionDefinition) offlineRegion.getDefinition();
                    OfflineRegionData regionArgs = OfflineRegionData.fromOfflineRegion(definition, offlineRegion.getMetadata());
                    if (regionArgs != null) {
                        regionsArgs.add(regionArgs);
                    }
                }
                result.success(new Gson().toJson(regionsArgs));
            }

            @Override
            public void onError(String error) {
                result.error("RegionListError", error, null);
            }
        });
    }

    static void deleteRegion(MethodChannel.Result result, Context context, int id, String accessToken) {
        //Initialize Mapbox
        MapBoxUtils.getMapbox(context, accessToken);
        // Set up the OfflineManager
        OfflineManager offlineManager = OfflineManager.getInstance(context);
        Gson gson = new Gson();
        offlineManager.listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                for (OfflineRegion offlineRegion : offlineRegions) {
                    String json = new String(offlineRegion.getMetadata());
                    Map<String, Object> map = new HashMap<>();
                    map = gson.fromJson(json, map.getClass());
                    if (!map.containsKey("id")) continue;
                    int regionId = ((Double) map.get("id")).intValue();
                    if (regionId != id) continue;

                    offlineRegion.delete(new OfflineRegion.OfflineRegionDeleteCallback() {
                        @Override
                        public void onDelete() {
                            if (result == null) return;
                            result.success(null);
                        }

                        @Override
                        public void onError(String error) {
                            if (result == null) return;
                            result.error("DeleteRegionError", error, null);
                        }
                    });
                    return;
                }
                if (result == null) return;
                result.error("DeleteRegionError", "There is no region with given id to delete.", null);
            }

            @Override
            public void onError(String error) {
                if (result == null) return;
                result.error("RegionListError", error, null);
            }
        });
    }

    private static double calculateDownloadingProgress(long requiredResourceCount, long completedResourceCount) {
        return requiredResourceCount > 0
                ? (100.0 * completedResourceCount / requiredResourceCount) :
                0.0;
    }

    private static byte[] prepareMetadata(OfflineRegionData args) {
        //Make copy of received metadata
        Map<String, Object> metadata;
        if (args.getMetadata() == null) {
            metadata = new HashMap<>();
        } else {
            metadata = new HashMap<>(args.getMetadata());
        }
        //Add id to metadata
        metadata.put("id", args.getId());
        return new Gson().toJson(metadata).getBytes();
    }

    private static OfflineTilePyramidRegionDefinition generateRegionDefinition(OfflineRegionData args, Context context) {
        // Create a bounding box for the offline region
        LatLngBounds latLngBounds = args.getBounds();
        return new OfflineTilePyramidRegionDefinition(
                args.getMapStyleUrl(),
                latLngBounds,
                args.getMinZoom(),
                args.getMaxZoom(),
                context.getResources().getDisplayMetrics().density);
    }
}
