part of mapbox_gl_platform_interface;

abstract class Annotation {
  String get id;
  Map<String, dynamic> toGeoJson();

  Annotation translate(LatLng delta);
  bool get draggable;
}
