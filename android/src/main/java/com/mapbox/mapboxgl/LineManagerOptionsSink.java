package com.mapbox.mapboxgl;

public interface LineManagerOptionsSink {

    void setLineCap(String lineCap);

    void setLineMiterLimit(Float lineMiterLimit);

    void setLineRoundLimit(Float lineRoundLimit);

    void setLineTranslate(Float[] lineTranslate);

    void setLineTranslateAnchor(String lineTranslateAnchor);

    void setLineDashArray(Float[] lineDashArray);
}
