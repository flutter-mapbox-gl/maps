package com.mapbox.mapboxgl.models;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;

import java.util.List;
import java.util.Map;

public class DownloadRegionArgs {
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

    @NonNull
    @Override
    public String toString() {
        return "id = " + id + ", bounds = " + getBounds()
                + ", metadata = " + metadata + ", mapStyleUrl = "
                + mapStyleUrl + ", minZoom = " + minZoom + ", maxZoom = " + maxZoom;
    }
}
