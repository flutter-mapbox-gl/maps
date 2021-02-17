part of mapbox_gl;

/// Description of region to be downloaded. Identifier will be generated when
/// the download is initiated.
class OfflineRegionDefinition {
  const OfflineRegionDefinition({
    @required this.bounds,
    @required this.metadata,
    @required this.mapStyleUrl,
    @required this.minZoom,
    @required this.maxZoom,
  });

  final LatLngBounds bounds;
  final Map<String, dynamic> metadata;
  final String mapStyleUrl;
  final double minZoom;
  final double maxZoom;

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['bounds'] = bounds.toList();
    data['metadata'] = metadata;
    data['mapStyleUrl'] = mapStyleUrl;
    data['minZoom'] = minZoom;
    data['maxZoom'] = maxZoom;
    return data;
  }

  @override
  String toString() =>
      "$runtimeType, bounds = $bounds, metadata = $metadata, mapStyleUrl = $mapStyleUrl, minZoom = $minZoom, maxZoom = $maxZoom";
}

/// Description of a downloaded region including its identifier.
class OfflineRegion extends OfflineRegionDefinition {
  const OfflineRegion({
    this.id,
    LatLngBounds bounds,
    Map<String, dynamic> metadata,
    String mapStyleUrl,
    double minZoom,
    double maxZoom,
  }) : super(
            bounds: bounds,
            metadata: metadata,
            mapStyleUrl: mapStyleUrl,
            minZoom: minZoom,
            maxZoom: maxZoom);

  final int id;

  factory OfflineRegion.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return OfflineRegion(
      id: json['id'],
      bounds: json['bounds'] != null
          ? fromList(
              json['bounds'],
            )
          : null,
      metadata: json['metadata'],
      mapStyleUrl: json['mapStyleUrl'],
      minZoom: json['minZoom'].toDouble(),
      maxZoom: json['maxZoom'].toDouble(),
    );
  }

  static LatLngBounds fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: latLngFromJson(json[0]),
      northeast: latLngFromJson(json[1]),
    );
  }

  static LatLng latLngFromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() =>
      "$runtimeType, id = $id, bounds = $bounds, metadata = $metadata, mapStyleUrl = $mapStyleUrl, minZoom = $minZoom, maxZoom = $maxZoom";
}
