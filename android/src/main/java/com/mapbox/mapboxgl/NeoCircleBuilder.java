package com.mapbox.mapboxgl;

import androidx.annotation.NonNull;

import com.mapbox.geojson.Feature;
import com.mapbox.geojson.LineString;
import com.mapbox.geojson.Point;
import com.mapbox.geojson.Polygon;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.turf.TurfMeta;
import com.mapbox.turf.TurfTransformation;

import java.util.Map;

import static com.mapbox.turf.TurfConstants.UNIT_KILOMETERS;


class NeoCircleBuilder {

    static Feature createNeoCircleFeature(Map<?, ?> options, LatLng geometry, int circlePrecision) {

        final float radiusInKm = Convert.toFloat(options.get("radius")) / 1000;

        Polygon polygonArea = getTurfPolygon(Point.fromLngLat(geometry.getLongitude(), geometry.getLatitude()), radiusInKm, circlePrecision);
        Polygon finalPolygon = Polygon.fromOuterInner(
                LineString.fromLngLats(TurfMeta.coordAll(polygonArea, false)));

        Feature feature = Feature.fromGeometry(finalPolygon);

        if (options.get("fill-color") != null) {
            final String fillColor = Convert.toString(options.get("fill-color"));
            feature.addStringProperty("fill-color", fillColor);
        }
        if (options.get("fill-opacity") != null) {
            final float fillOpacity = Convert.toFloat(options.get("fill-opacity"));
            feature.addNumberProperty("fill-opacity", fillOpacity);
        }

        if (options.get("border-opacity") != null) {
            final float borderOpacity = Convert.toFloat(options.get("border-opacity"));
            feature.addNumberProperty("border-opacity", borderOpacity);
        }

        if (options.get("border-color") != null) {
            final String borderColor = Convert.toString(options.get("border-color"));
            feature.addStringProperty("border-color", borderColor);
        }

        if (options.get("border-width") != null) {
            final float borderWidth = Convert.toFloat(options.get("border-width"));
            feature.addNumberProperty("border-width", borderWidth);
        }

        return feature;
    }

    static Polygon getTurfPolygon(@NonNull Point centerPoint, double radius,
                                  int steps) {
        return TurfTransformation.circle(centerPoint, radius, steps, UNIT_KILOMETERS);
    }
}