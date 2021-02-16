import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';

import 'offline_region_map.dart';
import 'page.dart';

final LatLngBounds hawaii = LatLngBounds(
  southwest: const LatLng(17.26672, -161.14746),
  northeast: const LatLng(23.76523, -153.74267),
);

final LatLngBounds santiago = LatLngBounds(
  southwest: const LatLng(-33.5597, -70.49102),
  northeast: const LatLng(-33.33282, -153.74267),
);

final LatLngBounds auckland = LatLngBounds(
  southwest: const LatLng(-36.87838, 174.73205),
  northeast: const LatLng(-36.82838, 174.79745),
);

final OfflineRegionDefinition hawaiiRegion = OfflineRegionDefinition(
  bounds: hawaii,
  metadata: {'name': 'hawaii'},
  minZoom: 3.0,
  maxZoom: 8.0,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

final OfflineRegionDefinition santiagoRegion = OfflineRegionDefinition(
  bounds: santiago,
  metadata: {'name': 'santiago'},
  minZoom: 10.0,
  maxZoom: 16.0,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

final OfflineRegionDefinition aucklandRegion = OfflineRegionDefinition(
  bounds: auckland,
  metadata: {'name': 'auckland'},
  minZoom: 13.0,
  maxZoom: 16.0,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

class OfflineRegionListItem {
  OfflineRegionListItem({
    @required this.offlineRegion,
    @required this.downloadedId,
    @required this.isDownloading,
    @required this.name,
    @required this.estimatedTiles,
  });

  final OfflineRegionDefinition offlineRegion;
  final int downloadedId;
  final bool isDownloading;
  final String name;
  final int estimatedTiles;

  OfflineRegionListItem copyWith({
    int downloadedId,
    bool isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegion: offlineRegion,
        name: name,
        estimatedTiles: estimatedTiles,
        downloadedId: downloadedId,
        isDownloading: isDownloading ?? this.isDownloading,
      );

  bool get isDownloaded => downloadedId != null;
}

final List<OfflineRegionListItem> allRegions = [
  OfflineRegionListItem(
    offlineRegion: hawaiiRegion,
    downloadedId: null,
    isDownloading: false,
    name: 'Hawaii',
    estimatedTiles: 61,
  ),
  OfflineRegionListItem(
    offlineRegion: santiagoRegion,
    downloadedId: null,
    isDownloading: false,
    name: 'Santiago',
    estimatedTiles: 3580,
  ),
  OfflineRegionListItem(
    offlineRegion: aucklandRegion,
    downloadedId: null,
    isDownloading: false,
    name: 'Auckland',
    estimatedTiles: 202,
  ),
];

class OfflineRegionsPage extends ExamplePage {
  OfflineRegionsPage() : super(const Icon(Icons.map), 'Offline Regions');

  @override
  Widget build(BuildContext context) {
    return const OfflineRegionBody();
  }
}

class OfflineRegionBody extends StatefulWidget {
  const OfflineRegionBody();

  @override
  _OfflineRegionsBodyState createState() => _OfflineRegionsBodyState();
}

class _OfflineRegionsBodyState extends State<OfflineRegionBody> {
  List<OfflineRegionListItem> _items = List();

  @override
  void initState() {
    super.initState();
    _updateListOfRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          itemCount: _items.length,
          itemBuilder: (context, index) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.map),
                onPressed: () => _goToMap(_items[index]),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _items[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Est. tiles: ${_items[index].estimatedTiles}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _items[index].isDownloading
                  ? Container(
                      child: CircularProgressIndicator(),
                      height: 16,
                      width: 16,
                    )
                  : IconButton(
                      icon: Icon(
                        _items[index].isDownloaded
                            ? Icons.delete
                            : Icons.file_download,
                      ),
                      onPressed: _items[index].isDownloaded
                          ? () => _deleteRegion(_items[index], index)
                          : () => _downloadRegion(_items[index], index),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateListOfRegions() async {
    List<OfflineRegion> offlineRegions =
        await getListOfRegions(accessToken: MapsDemo.ACCESS_TOKEN);
    List<OfflineRegionListItem> regionItems = [];
    for (var item in allRegions) {
      final offlineRegion = offlineRegions.firstWhere(
          (offlineRegion) =>
              offlineRegion.metadata['name'] ==
              item.offlineRegion.metadata['name'],
          orElse: () => null);
      if (offlineRegion != null) {
        regionItems.add(item.copyWith(downloadedId: offlineRegion.id));
      } else {
        regionItems.add(item);
      }
    }
    setState(() {
      _items.clear();
      _items.addAll(regionItems);
    });
  }

  void _downloadRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    try {
      final downloadingRegion = await downloadOfflineRegion(
        item.offlineRegion,
        accessToken: MapsDemo.ACCESS_TOKEN,
      );
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: downloadingRegion.id,
            ));
      });
    } on Exception catch (_) {
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: null,
            ));
      });
      return;
    }
  }

  void _deleteRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    await deleteOfflineRegion(
      item.downloadedId,
      accessToken: MapsDemo.ACCESS_TOKEN,
    );

    setState(() {
      _items.removeAt(index);
      _items.insert(
          index,
          item.copyWith(
            isDownloading: false,
            downloadedId: null,
          ));
    });
  }

  _goToMap(OfflineRegionListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OfflineRegionMap(item),
      ),
    );
  }
}
