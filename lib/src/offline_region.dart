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
          ? LatLngBounds.fromList(
              json['bounds'],
            )
          : null,
      metadata: json['metadata'],
      mapStyleUrl: json['mapStyleUrl'],
      minZoom: json['minZoom'],
      maxZoom: json['maxZoom'],
    );
  }

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['bounds'] = bounds._toList();
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
