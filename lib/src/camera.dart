part of mapbox_gl;

class Camera {
  final LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;

  Camera({this.target, this.zoom, this.bearing, this.tilt});

  Camera copyWith({LatLng target, double zoom, double bearing, double tilt}) {
    LatLng newTarget = target ?? this.target;
    double newZoom = zoom ?? this.zoom;
    double newBearing = bearing ?? this.bearing;
    double newTilt = tilt ?? this.tilt;

    return new Camera(target: newTarget, zoom: newZoom, bearing: newBearing, tilt: newTilt);
  }

  Map<String, Object> toMap() {
    return {
      "target": (target != null) ? target.toMap() : null,
      "zoom": zoom,
      "bearing": bearing,
      "tilt": tilt
    };
  }
}
