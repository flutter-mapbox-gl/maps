package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.mapbox.mapboxgl.models.OfflineRegionData;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineManager;
import com.mapbox.mapboxsdk.offline.OfflineRegion;
import com.mapbox.mapboxsdk.offline.OfflineRegionDefinition;
import com.mapbox.mapboxsdk.offline.OfflineRegionError;
import com.mapbox.mapboxsdk.offline.OfflineRegionStatus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel;

abstract class OfflineManagerUtils {
    private static final String TAG = "OfflineManagerUtils";

    static void mergeRegions(MethodChannel.Result result, Context context, String path) {
        OfflineManager.getInstance(context).mergeOfflineRegions(path, new OfflineManager.MergeOfflineRegionsCallback() {
            public void onMerge(OfflineRegion[] offlineRegions) {
                if (result == null) return;
                List<OfflineRegionData> regionsArgs = new ArrayList<>();
                for (OfflineRegion offlineRegion : offlineRegions) {
                    regionsArgs.add(OfflineRegionData.fromOfflineRegion(offlineRegion));
                }
                String json = new Gson().toJson(regionsArgs);
                result.success(json);
            }

            public void onError(String error) {
                if (result == null) return;
                result.error("mergeOfflineRegions Error", error, null);
            }
        });
    }

    static void downloadRegion(
        MethodChannel.Result result,
        Context context,
        OfflineRegionData offlineRegionData,
        OfflineChannelHandlerImpl channelHandler
    ) {
        // Define the offline region
        float pixelDensity = context.getResources().getDisplayMetrics().density;
        OfflineRegionDefinition definition = offlineRegionData.generateRegionDefinition(pixelDensity);
        //Prepare metadata
        byte[] metadata = offlineRegionData.prepareMetadata();
        //Tracker of result
        AtomicBoolean isComplete = new AtomicBoolean(false);
        //Download region
        OfflineManager.getInstance(context).createOfflineRegion(definition, metadata, new OfflineManager.CreateOfflineRegionCallback() {
            private OfflineRegion _offlineRegion;

            @Override
            public void onCreate(OfflineRegion offlineRegion) {
                OfflineRegionData data = OfflineRegionData.fromOfflineRegion(offlineRegion);
                result.success(new Gson().toJson(data));

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
                    }

                    @Override
                    public void mapboxTileCountLimitExceeded(long limit) {
                        Log.e(TAG, "Mapbox tile count limit exceeded: " + limit);
                        //Reset downloading state
                        _offlineRegion.setDownloadState(OfflineRegion.STATE_INACTIVE);
                        isComplete.set(true);
                        channelHandler.onError("mapboxTileCountLimitExceeded", "Mapbox tile count limit exceeded: " + limit, null);
                        //Mapbox even after crash and not downloading fully region still keeps part of it in database, so we have to remove it
                        deleteRegion(null, context, offlineRegionData.getId());
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

    static void regionsList(MethodChannel.Result result, Context context) {
        OfflineManager.getInstance(context).listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                List<OfflineRegionData> regionsArgs = new ArrayList<>();
                for (OfflineRegion offlineRegion : offlineRegions) {
                    regionsArgs.add(OfflineRegionData.fromOfflineRegion(offlineRegion));
                }
                result.success(new Gson().toJson(regionsArgs));
            }

            @Override
            public void onError(String error) {
                result.error("RegionListError", error, null);
            }
        });
    }

    static void updateRegionMetadata(MethodChannel.Result result, Context context, long id, Map<String, Object> metadata) {
        OfflineManager.getInstance(context).listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                for (OfflineRegion offlineRegion : offlineRegions) {
                    if (offlineRegion.getID() != id) continue;

                    final OfflineRegionData regionData = OfflineRegionData.fromOfflineRegion(offlineRegion);
                    regionData.setMetadata(metadata);

                    offlineRegion.updateMetadata(regionData.prepareMetadata(), new OfflineRegion.OfflineRegionUpdateMetadataCallback() {
                        @Override
                        public void onUpdate(byte[] metadataBytes) {
                            regionData.setMetadataBytes(metadataBytes);
                            if (result == null) return;
                            result.success(new Gson().toJson(regionData));
                        }

                        @Override
                        public void onError(String error) {
                            if (result == null) return;
                            result.error("UpdateMetadataError", error, null);
                        }
                    });
                    return;
                }
                if (result == null) return;
                result.error("UpdateMetadataError", "There is no region with given id to update.", null);
            }

            @Override
            public void onError(String error) {
                if (result == null) return;
                result.error("RegionListError", error, null);
            }
        });
    }

    static void deleteRegion(MethodChannel.Result result, Context context, long id) {
        OfflineManager.getInstance(context).listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                for (OfflineRegion offlineRegion : offlineRegions) {
                    if (offlineRegion.getID() != id) continue;

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
}
