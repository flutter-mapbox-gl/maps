package com.mapbox.mapboxgl;

import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.mapboxsdk.plugins.annotation.LineManager;

public class LineManagerBuilder implements LineManagerOptionsSink {
    private LineManager lineManager;

    LineManagerBuilder(MapView mapView, MapboxMap mapboxMap, Style mapboxStyle) {
        this.lineManager = new LineManager(mapView, mapboxMap, mapboxStyle);
    }

    public LineManager build() {
        return lineManager;
    }

    @Override
    public void setLineCap(String lineCap) {
        lineManager.setLineCap(lineCap);
    }

    @Override
    public void setLineMiterLimit(Float lineMiterLimit) {
        lineManager.setLineMiterLimit(lineMiterLimit);
    }

    @Override
    public void setLineRoundLimit(Float lineRoundLimit) {
        lineManager.setLineRoundLimit(lineRoundLimit);
    }

    @Override
    public void setLineTranslate(Float[] lineTranslate) {
        lineManager.setLineTranslate(lineTranslate);
    }

    @Override
    public void setLineTranslateAnchor(String lineTranslateAnchor) {
        lineManager.setLineTranslateAnchor(lineTranslateAnchor);
    }

    @Override
    public void setLineDashArray(Float[] lineDashArray) {
        lineManager.setLineDasharray(lineDashArray);
    }
}
