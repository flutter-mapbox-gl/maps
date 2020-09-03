package com.mapbox.mapboxgl;

import com.mapbox.geojson.Feature;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.Map;


class NeoCircleBuilder {

    static Feature createNeoCircleFeature(Map<?, ?> options, float radius) {

        final LatLng latLng = Convert.toLatLng(options.get("geometry"));

        Feature feature = Feature.fromGeometry(Point.fromLngLat(latLng.getLongitude(), latLng.getLatitude()));

        if (options.get("circleColor") != null) {
            final String circleColor = Convert.toString(options.get("circleColor"));
            feature.addStringProperty("circle-color", circleColor);
        }
        if (options.get("circleOpacity") != null) {
            final float circleOpacity = Convert.toFloat(options.get("circleOpacity"));
            feature.addNumberProperty("circle-opacity", circleOpacity);
        }

        if (options.get("circleStrokeWidth") != null) {
            final float circleStrokeWidth = Convert.toFloat(options.get("circleStrokeWidth"));
            feature.addNumberProperty("circle-stroke-width", circleStrokeWidth * 18);
        }

        if (options.get("circleStrokeColor") != null) {
            final String circleStrokeColor = Convert.toString(options.get("circleStrokeColor"));
            feature.addStringProperty("circle-stroke-color", circleStrokeColor);
        }

        if (options.get("circleStrokeOpacity") != null) {
            final float circleStrokeOpacity = Convert.toFloat(options.get("circleStrokeOpacity"));
            feature.addNumberProperty("circle-stroke-opacity", circleStrokeOpacity);
        }

        feature.addNumberProperty("radius", radius * 75);

        return feature;
    }
}