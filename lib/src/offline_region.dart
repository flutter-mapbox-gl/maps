part of mapbox_gl;

class OfflineRegion {
  const OfflineRegion({
    @required this.id,
    @required this.bounds,
    @required this.metadata,
    @required this.mapStyleUrl,
    @required this.minZoom,
    @required this.maxZoom,
  });

  final int id;
  final LatLngBounds bounds;
  final Map<String, dynamic> metadata;
  final String mapStyleUrl;
  final double minZoom;
  final double maxZoom;

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

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['bounds'] = bounds.toList();
    data['metadata'] = metadata;
    data['mapStyleUrl'] = mapStyleUrl;
    data['minZoom'] = minZoom;
    data['maxZoom'] = maxZoom;
    return data;
  }

  @override
  String toString() =>
      "$runtimeType, id = $id, bounds = $bounds, metadata = $metadata, mapStyleUrl = $mapStyleUrl, minZoom = $minZoom, maxZoom = $maxZoom";
}
