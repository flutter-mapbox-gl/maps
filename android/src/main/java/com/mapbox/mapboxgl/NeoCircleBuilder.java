package com.mapbox.mapboxgl;

import androidx.annotation.NonNull;

import com.mapbox.geojson.Feature;
import com.mapbox.geojson.LineString;
import com.mapbox.geojson.Point;
import com.mapbox.geojson.Polygon;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.turf.TurfMeta;
import com.mapbox.turf.TurfTransformation;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static com.mapbox.turf.TurfConstants.UNIT_KILOMETERS;


class NeoCircleBuilder {


    static Feature createNeoCircleFeature(Map<?, ?> options, float radius) {

        final LatLng latLng = Convert.toLatLng(options.get("geometry"));

        Polygon basePolygon = createCirclePolygon(latLng, (int) radius);

        Polygon finalPolygon = Polygon.fromOuterInner(LineString.fromLngLats(TurfMeta.coordAll(basePolygon, false)));

        Feature feature = Feature.fromGeometry(finalPolygon);

        if (options.get("circleColor") != null) {
            final String circleColor = Convert.toString(options.get("circleColor"));
            feature.addStringProperty("fill-color", circleColor);
        }
        if (options.get("circleOpacity") != null) {
            final float circleOpacity = Convert.toFloat(options.get("circleOpacity"));
            feature.addNumberProperty("fill-opacity", circleOpacity);
        }

//        if (options.get("circleColor") != null) {
//            final float circleColor = Convert.toFloat(options.get("circleColor"));
//            feature.addNumberProperty("fill-outline-color", circleColor);
//        }

//        feature.addNumberProperty("maxzoom", 22);

        return feature;
    }

    static Polygon getTurfPolygon(@NonNull Point centerPoint, @NonNull double radius,
                                  @NonNull int steps, @NonNull String units) {
        return TurfTransformation.circle(centerPoint, radius, steps, units);
    }


    private static Polygon createCirclePolygon(LatLng center, int radiusInMeters) {
        Point point = Point.fromLngLat(center.getLongitude(), center.getLatitude());
        int radiusInKm = radiusInMeters / 1000;
        return getTurfPolygon(point, radiusInKm, 180, UNIT_KILOMETERS);
    }

}