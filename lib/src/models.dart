part of mapbox_gl;

class ScreenPoint {
  double x;
  double y;
  ScreenPoint(this.x, this.y);
}

class MapboxMapOptions {
  final String style;
  final Camera camera;

  MapboxMapOptions({this.style, this.camera});

  Map<String, Object> toMap() {
    return {"style": style, "camera": camera.toMap()};
  }
}

class Layer {}


class LatLng {
  final double lat;
  final double lng;

  LatLng({@required this.lat, @required this.lng});

  Map<String, Object> toMap() {
    return {"lat": lat, "lng": lng};
  }

  @override
  String toString() {
    return 'LatLng{lat: $lat, lng: $lng}';
  }
}