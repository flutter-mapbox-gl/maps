package com.mapbox.mapboxgl;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineManager;
import com.mapbox.mapboxsdk.offline.OfflineRegion;
import com.mapbox.mapboxsdk.offline.OfflineRegionDefinition;
import com.mapbox.mapboxsdk.offline.OfflineTilePyramidRegionDefinition;
import com.mapbox.mapboxsdk.offline.OfflineRegionError;
import com.mapbox.mapboxsdk.offline.OfflineRegionStatus;

import java.util.Arrays;
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
                List<Map<String, Object>> regionsArgs = new ArrayList<>();
                for (OfflineRegion offlineRegion : offlineRegions) {
                    regionsArgs.add(offlineRegionToMap(offlineRegion));
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

    static void setOfflineTileCountLimit(MethodChannel.Result result, Context context, long limit){
        OfflineManager.getInstance(context).setOfflineMapboxTileCountLimit(limit);
        result.success(null);
    }

    static void downloadRegion(
        MethodChannel.Result result,
        Context context,
        Map<String, Object> definitionMap,
        Map<String, Object> metadataMap,
        OfflineChannelHandlerImpl channelHandler
    ) {
        float pixelDensity = context.getResources().getDisplayMetrics().density;
        OfflineRegionDefinition definition = mapToRegionDefinition(definitionMap, pixelDensity);
        String metadata = "{}";
        if (metadataMap != null) {
            metadata = new Gson().toJson(metadataMap);
        }
        AtomicBoolean isComplete = new AtomicBoolean(false);
        //Download region
        OfflineManager.getInstance(context).createOfflineRegion(definition, metadata.getBytes(), new OfflineManager.CreateOfflineRegionCallback() {
            private OfflineRegion _offlineRegion;

            @Override
            public void onCreate(OfflineRegion offlineRegion) {
                Map<String, Object> regionData = offlineRegionToMap(offlineRegion);
                result.success(new Gson().toJson(regionData));

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
                        deleteRegion(null, context, _offlineRegion.getID());
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
                List<Map<String, Object>> regionsArgs = new ArrayList<>();
                for (OfflineRegion offlineRegion : offlineRegions) {
                    regionsArgs.add(offlineRegionToMap(offlineRegion));
                }
                result.success(new Gson().toJson(regionsArgs));
            }

            @Override
            public void onError(String error) {
                result.error("RegionListError", error, null);
            }
        });
    }

    static void updateRegionMetadata(MethodChannel.Result result, Context context, long id, Map<String, Object> metadataMap) {
        OfflineManager.getInstance(context).listOfflineRegions(new OfflineManager.ListOfflineRegionsCallback() {
            @Override
            public void onList(OfflineRegion[] offlineRegions) {
                for (OfflineRegion offlineRegion : offlineRegions) {
                    if (offlineRegion.getID() != id) continue;

                    String metadata = "{}";
                    if (metadataMap != null) {
                        metadata = new Gson().toJson(metadataMap);
                    }
                    offlineRegion.updateMetadata(metadata.getBytes(), new OfflineRegion.OfflineRegionUpdateMetadataCallback() {
                        @Override
                        public void onUpdate(byte[] metadataBytes) {
                            Map<String, Object> regionData = offlineRegionToMap(offlineRegion);
                            regionData.put("metadata", metadataBytesToMap(metadataBytes));

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

    private static OfflineRegionDefinition mapToRegionDefinition(Map<String, Object> map, float pixelDensity) {
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            Log.d(TAG, entry.getKey());
            Log.d(TAG, entry.getValue().toString());
        }
        // Create a bounding box for the offline region
        return new OfflineTilePyramidRegionDefinition(
                (String) map.get("mapStyleUrl"),
                listToBounds((List<List<Double>>) map.get("bounds")),
                ((Number) map.get("minZoom")).doubleValue(),
                ((Number) map.get("maxZoom")).doubleValue(),
                pixelDensity,
                (Boolean) map.get("includeIdeographs")
                );
    }

    private static LatLngBounds listToBounds(List<List<Double>> bounds) {
        return new LatLngBounds.Builder()
                .include(new LatLng(bounds.get(1).get(0), bounds.get(1).get(1))) //Northeast
                .include(new LatLng(bounds.get(0).get(0), bounds.get(0).get(1))) //Southwest
                .build();
    }

    private static Map<String, Object> offlineRegionToMap(OfflineRegion region) {
        Map<String, Object> result = new HashMap();
        result.put("id", region.getID());
        result.put("definition", offlineRegionDefinitionToMap(region.getDefinition()));
        result.put("metadata", metadataBytesToMap(region.getMetadata()));
        return result;
    }

    private static Map<String, Object> offlineRegionDefinitionToMap(OfflineRegionDefinition definition) {
        Map<String, Object> result = new HashMap();
        result.put("mapStyleUrl", definition.getStyleURL());
        result.put("bounds", boundsToList(definition.getBounds()));
        result.put("minZoom", definition.getMinZoom());
        result.put("maxZoom", definition.getMaxZoom());
        result.put("includeIdeographs", definition.getIncludeIdeographs());
        return result;
    }

    private static List<List<Double>> boundsToList(LatLngBounds bounds) {
        List<List<Double>> boundsList = new ArrayList<>();
        List<Double> northeast = Arrays.asList(bounds.getLatNorth(), bounds.getLonEast());
        List<Double> southwest = Arrays.asList(bounds.getLatSouth(), bounds.getLonWest());
        boundsList.add(southwest);
        boundsList.add(northeast);
        return boundsList;
    }

    private static Map<String, Object> metadataBytesToMap(byte[] metadataBytes) {
        if (metadataBytes != null) {
            return new Gson().fromJson(new String(metadataBytes), HashMap.class);
        }
        return new HashMap();
    }
}
