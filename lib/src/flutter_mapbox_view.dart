part of mapbox_gl;

typedef MapViewCreatedCallback(MapViewController controller);

class MapView extends StatefulWidget {
  final MapViewCreatedCallback onMapViewCreated;
  final OnMapTapCallback onTap;

  const MapView({
    Key key,
    this.onMapViewCreated,
    this.onTap,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.mapbox/mapboxgl',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text('$defaultTargetPlatform is not yet supported by the MapBox plugin');
  }

// const ttt = widget.OnMapTapCallback();

  void _onPlatformViewCreated(int id) {
    MapViewController controller = MapViewController(
      id,
      onTap: widget.onTap,
    );
    if (widget.onMapViewCreated != null) widget.onMapViewCreated(controller);
  }
}
