part of mapbox_gl;

/// Description of region to be downloaded. Identifier will be generated when
/// the download is initiated.
class OfflineRegionDefinition {
  const OfflineRegionDefinition({
    @required this.bounds,
    @required this.mapStyleUrl,
    @required this.minZoom,
    @required this.maxZoom,
    this.includeIdeographs = false,
  });

  final LatLngBounds bounds;
  final String mapStyleUrl;
  final double minZoom;
  final double maxZoom;
  final bool includeIdeographs;

  @override
  String toString() =>
      "$runtimeType, bounds = $bounds, mapStyleUrl = $mapStyleUrl, minZoom = $minZoom, maxZoom = $maxZoom";

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['bounds'] = bounds.toList();
    data['mapStyleUrl'] = mapStyleUrl;
    data['minZoom'] = minZoom;
    data['maxZoom'] = maxZoom;
    data['includeIdeographs'] = includeIdeographs;
    return data;
  }

  factory OfflineRegionDefinition.fromMap(Map<String, dynamic> map) {
    return OfflineRegionDefinition(
      bounds: map['bounds'] != null
          ? _latLngBoundsFromList(
              map['bounds'],
            )
          : null,
      mapStyleUrl: map['mapStyleUrl'],
      // small integers may deserialize to Int
      minZoom: map['minZoom'].toDouble(),
      maxZoom: map['maxZoom'].toDouble(),
      includeIdeographs: map['includeIdeographs'] ?? false,
    );
  }

  static LatLngBounds _latLngBoundsFromList(List<dynamic> json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: _latLngFromList(json[0]),
      northeast: _latLngFromList(json[1]),
    );
  }

  static LatLng _latLngFromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }
}

/// Description of a downloaded region including its identifier.
class OfflineRegion {
  const OfflineRegion({
    this.id,
    this.definition,
    this.metadata,
  });

  final int id;
  final OfflineRegionDefinition definition;
  final Map<String, dynamic> metadata;

  factory OfflineRegion.fromMap(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return OfflineRegion(
      id: json['id'],
      definition: OfflineRegionDefinition.fromMap(json['definition']),
      metadata: json['metadata'],
    );
  }

  @override
  String toString() =>
      "$runtimeType, id = $id, definition = $definition, metadata = $metadata";
}
