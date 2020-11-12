package com.mapbox.mapboxgl.models;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineTilePyramidRegionDefinition;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OfflineRegionData {
    @SerializedName("id")
    private int id;
    @SerializedName("bounds")
    private List<List<Double>> bounds;
    @SerializedName("metadata")
    private Map<String, Object> metadata;
    @SerializedName("mapStyleUrl")
    private String mapStyleUrl;
    @SerializedName("minZoom")
    private double minZoom;
    @SerializedName("maxZoom")
    private double maxZoom;

    public OfflineRegionData(int id, List<List<Double>> bounds, Map<String, Object> metadata, String mapStyleUrl, double minZoom, double maxZoom) {
        this.id = id;
        this.bounds = bounds;
        this.metadata = metadata;
        this.mapStyleUrl = mapStyleUrl;
        this.minZoom = minZoom;
        this.maxZoom = maxZoom;
    }

    public int getId() {
        return id;
    }

    public LatLngBounds getBounds() {
        return new LatLngBounds.Builder()
                .include(new LatLng(bounds.get(1).get(0), bounds.get(1).get(1))) //Northeast
                .include(new LatLng(bounds.get(0).get(0), bounds.get(0).get(1))) //Southwest
                .build();
    }

    public Map<String, Object> getMetadata() {
        return metadata;
    }

    public String getMapStyleUrl() {
        return mapStyleUrl;
    }

    public double getMinZoom() {
        return minZoom;
    }

    public double getMaxZoom() {
        return maxZoom;
    }

    @Nullable
    public static OfflineRegionData fromOfflineRegion(OfflineTilePyramidRegionDefinition region, byte[] metadata) {
        Gson gson = new Gson();
        String json = new String(metadata);
        Map<String, Object> map = new HashMap<>();
        map = gson.fromJson(json, map.getClass());
        if (!map.containsKey("id")) return null;
        int id = ((Double) map.get("id")).intValue();
        map.remove("id");
        return new OfflineRegionData(
                id,
                getBoundsAsList(region.getBounds()),
                map,
                region.getStyleURL(),
                region.getMinZoom(),
                region.getMaxZoom()
        );
    }

    private static List<List<Double>> getBoundsAsList(LatLngBounds bounds) {
        List<List<Double>> boundsList = new ArrayList<>();
        List<Double> northeast = Arrays.asList(bounds.getLatNorth(), bounds.getLonEast());
        List<Double> southwest = Arrays.asList(bounds.getLatSouth(), bounds.getLonWest());
        boundsList.add(southwest);
        boundsList.add(northeast);
        return boundsList;
    }

    @NonNull
    @Override
    public String toString() {
        return "id = " + id + ", bounds = " + getBounds()
                + ", metadata = " + metadata + ", mapStyleUrl = "
                + mapStyleUrl + ", minZoom = " + minZoom + ", maxZoom = " + maxZoom;
    }
}
