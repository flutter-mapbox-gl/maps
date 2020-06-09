import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'offline_regions.dart';

class OfflineRegionMap extends StatefulWidget {
  OfflineRegionMap(this.item);

  final OfflineRegionListItem item;

  @override
  _OfflineRegionMapState createState() => _OfflineRegionMapState();
}

class _OfflineRegionMapState extends State<OfflineRegionMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Region: ${widget.item.name}'),
      ),
      body: MapboxMap(
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: widget.item.offlineRegion.minZoom,
        ),
        minMaxZoomPreference: MinMaxZoomPreference(
          widget.item.offlineRegion.minZoom,
          widget.item.offlineRegion.maxZoom,
        ),
        styleString: widget.item.offlineRegion.mapStyleUrl,
        cameraTargetBounds: CameraTargetBounds(
          widget.item.offlineRegion.bounds,
        ),
      ),
    );
  }

  LatLng get _center {
    final bounds = widget.item.offlineRegion.bounds;
    final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }
}
