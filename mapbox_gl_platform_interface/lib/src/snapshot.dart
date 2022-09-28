part of mapbox_gl_platform_interface;

/// Set of options for taking map snapshot
class SnapshotOptions {
  /// Dimensions of the snapshot
  /// The width of the image
  final double width;

  /// Dimensions of the snapshot
  /// The height of the image
  final double height;

  /// If you want to take snapshot with camera position option
  ///
  /// Current center coordinate of camera position
  final LatLng? centerCoordinate;

  /// The coordinate rectangle that encompasses the bounds to capture. This is applied after the camera position
  final LatLngBounds? bounds;

  /// If you want to take snapshot with camera position option
  ///
  /// Zoom level of camera position
  final double? zoomLevel;

  /// If you want to take snapshot with camera position option
  ///
  /// Pitch toward the horizon measured in degrees, with 0 degrees resulting in a two-dimensional map
  final double? pitch;

  /// If you want to take snapshot with camera position option
  ///
  /// Heading measured in degrees clockwise from true north
  final double? heading;

  /// URL of the map style to snapshot. The URL may be a full HTTP or HTTPS URL, a Mapbox style URL
  final String? styleUri;

  /// StyleJson of the map style to snapshot
  final String? styleJson;

  /// Android Only: The flag indicating to show the Mapbox logo
  final bool withLogo;

  /// True: Save snapshot in cache and return path
  /// False: Return base64 value
  final bool writeToDisk;

  ///The [width] and [height] arguments must not be null
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
