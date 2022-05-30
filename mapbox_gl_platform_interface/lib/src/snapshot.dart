part of mapbox_gl_platform_interface;

class SnapshotOptions {
  final int width;
  final int height;

  final LatLng? centerCoordinate;
  final LatLngBounds? bounds;

  final double? zoomLevel;
  final double? pitch;
  final double? heading;

  final String? styleUri;
  final String? styleJson;

  final bool withLogo;
  final bool writeToDisk;

  SnapshotOptions(
      {required this.width,
      required this.height,
      this.centerCoordinate,
      this.bounds,
      this.zoomLevel,
      this.pitch,
      this.heading,
      this.styleUri,
      this.styleJson,
      bool? withLogo,
      bool? writeToDisk})
      : this.withLogo = withLogo ?? false,
        this.writeToDisk = writeToDisk ?? false;

  dynamic toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('width', width);
    addIfPresent('height', height);

    if (bounds != null) {
      final featureCollection = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "properties": {},
            "geometry": {
              "type": "Point",
              "coordinates": [
                bounds!.northeast.longitude,
                bounds!.northeast.latitude
              ]
            }
          },
          {
            "type": "Feature",
            "properties": {},
            "geometry": {
              "type": "Point",
              "coordinates": [
                bounds!.southwest.longitude,
                bounds!.southwest.latitude
              ]
            }
          }
        ]
      };
      addIfPresent("bounds", featureCollection.toString());
    }
    if (centerCoordinate != null &&
        zoomLevel != null &&
        heading != null &&
        pitch != null) {

      final feature = {
        "type": "Feature",
        "properties": {},
        "geometry": {
          "type": "Point",
          "coordinates": [
            centerCoordinate!.longitude,
            centerCoordinate!.latitude
          ]
        }
      };
      addIfPresent('centerCoordinate', feature.toString());
      addIfPresent('zoomLevel', zoomLevel);
      addIfPresent('pitch', pitch);
      addIfPresent('heading', heading);
      debugPrint("${feature}");
    }

    addIfPresent('styleUri', styleUri);
    addIfPresent('styleJson', styleJson);
    addIfPresent('withLogo', withLogo);
    addIfPresent('writeToDisk', writeToDisk);
    return json;
  }
}
