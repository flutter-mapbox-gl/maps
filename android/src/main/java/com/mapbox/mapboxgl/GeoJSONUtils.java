package com.mapbox.mapboxgl;

import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import com.mapbox.geojson.Geometry;
import com.mapbox.geojson.GeometryCollection;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.turf.TurfMeasurement;
import java.util.ArrayList;
import java.util.List;

public class GeoJSONUtils {
  public static LatLng toLatLng(Point point) {
    if (point == null) {
      return null;
    }
    return new LatLng(point.latitude(), point.longitude());
  }

  private static GeometryCollection toGeometryCollection(List<Feature> features) {
    ArrayList<Geometry> geometries = new ArrayList<>();
    geometries.ensureCapacity(features.size());
    for (Feature feature : features) {
      geometries.add(feature.geometry());
    }
    return GeometryCollection.fromGeometries(geometries);
  }

  public static LatLngBounds toLatLngBounds(FeatureCollection featureCollection) {
    List<Feature> features = featureCollection.features();

    double[] bbox = TurfMeasurement.bbox(toGeometryCollection(features));

    return LatLngBounds.from(bbox[3], bbox[2], bbox[1], bbox[0]);
  }
}
