package com.mapbox.mapboxgl.models;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.offline.OfflineRegion;
import com.mapbox.mapboxsdk.offline.OfflineRegionDefinition;
import com.mapbox.mapboxsdk.offline.OfflineTilePyramidRegionDefinition;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OfflineRegionData {
    @SerializedName("id")
    public long id;
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

    public OfflineRegionData(long id, List<List<Double>> bounds, Map<String, Object> metadata, String mapStyleUrl, double minZoom, double maxZoom) {
        this.id = id;
        this.bounds = bounds;
        this.metadata = metadata;
        this.mapStyleUrl = mapStyleUrl;
        this.minZoom = minZoom;
        this.maxZoom = maxZoom;
    }

    public long getId() {
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

    public void setMetadata(Map<String, Object> metadata) {
        this.metadata = metadata;
    }

    public void setMetadataBytes(byte[] metadataBytes) {
        this.metadata = parseMetadataBytes(metadataBytes);
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

    public byte[] prepareMetadata() {
        return new Gson().toJson((metadata == null) ? new HashMap() : metadata).getBytes();
    }

    public OfflineRegionDefinition generateRegionDefinition(float pixelDensity) {
        // Create a bounding box for the offline region
        return new OfflineTilePyramidRegionDefinition(
                getMapStyleUrl(),
                getBounds(),
                getMinZoom(),
                getMaxZoom(),
                pixelDensity);
    }

    public static OfflineRegionData fromOfflineRegion(OfflineRegion region) {
        OfflineRegionDefinition definition = region.getDefinition();
        return new OfflineRegionData(
                region.getID(),
                getBoundsAsList(definition.getBounds()),
                parseMetadataBytes(region.getMetadata()),
                definition.getStyleURL(),
                definition.getMinZoom(),
                definition.getMaxZoom()
        );
    }

    private static Map<String, Object> parseMetadataBytes(byte[] metadataBytes) {
        Map<String, Object> metadata = null;
        if (metadataBytes != null) {
            metadata = new Gson().fromJson(new String(metadataBytes), HashMap.class);
        }
        return (metadata == null) ? new HashMap() : metadata;
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
