part of mapbox_gl_platform_interface;

class SnapshotOptions {
  final double width;
  final double height;

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
      double? pitch,
      double? heading,
      this.styleUri,
      this.styleJson,
      bool? withLogo,
      bool? writeToDisk})
      : this.withLogo = withLogo ?? false,
        this.writeToDisk = writeToDisk ?? true,
        this.pitch = pitch ?? 0,
        this.heading = heading ?? 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('width', Platform.isAndroid ? width.toInt() : width);
    addIfPresent('height', Platform.isAndroid ? height.toInt() : height);

    if (bounds != null) {
      if (Platform.isAndroid) {
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
      } else {
        final list = [
          [
            bounds!.southwest.latitude,
            bounds!.southwest.longitude,
          ],
          [
            bounds!.northeast.latitude,
            bounds!.northeast.longitude,
          ]
        ];
        addIfPresent("bounds", list);
      }
    }
    if (centerCoordinate != null && zoomLevel != null) {
      if (Platform.isAndroid) {
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
      } else {
        final list = [
          centerCoordinate!.latitude,
          centerCoordinate!.longitude,
        ];
        addIfPresent('centerCoordinate', list);
      }

      addIfPresent('zoomLevel', zoomLevel);
    }
    addIfPresent('pitch', pitch);
    addIfPresent('heading', heading);
    addIfPresent('styleUri', styleUri);
    addIfPresent('styleJson', styleJson);
    addIfPresent('withLogo', withLogo);
    addIfPresent('writeToDisk', writeToDisk);
    return json;
  }
}
