part of mapbox_gl_web;

abstract class MapboxMapOptionsSink {
  // TODO: dddd replace with CameraPosition.Builder target
  void setCameraTargetBounds(LatLngBounds? bounds);

  void setCompassEnabled(bool compassEnabled);

  // TODO: styleString is not actually a part of options. consider moving
  void setStyleString(String? styleString);

  void setMinMaxZoomPreference(num? min, num? max);

  void setRotateGesturesEnabled(bool rotateGesturesEnabled);

  void setScrollGesturesEnabled(bool scrollGesturesEnabled);

  void setTiltGesturesEnabled(bool tiltGesturesEnabled);

  void setTrackCameraPosition(bool trackCameraPosition);

  void setZoomGesturesEnabled(bool zoomGesturesEnabled);

  void setMyLocationEnabled(bool myLocationEnabled);

  void setMyLocationTrackingMode(int myLocationTrackingMode);

  void setMyLocationRenderMode(int myLocationRenderMode);

  void setLogoViewMargins(int x, int y);

  void setCompassAlignment(CompassViewPosition position);

  void setCompassViewMargins(int x, int y);

  void setAttributionButtonAlignment(AttributionButtonPosition position);

  void setAttributionButtonMargins(int x, int y);
}
