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

final OfflineRegion hawaiiRegion = OfflineRegion(
  id: 0,
  bounds: hawaii,
  metadata: null,
  minZoom: 3,
  maxZoom: 8,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

final OfflineRegion santiagoRegion = OfflineRegion(
  id: 1,
  bounds: santiago,
  metadata: null,
  minZoom: 10,
  maxZoom: 16,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

final OfflineRegion aucklandRegion = OfflineRegion(
  id: 2,
  bounds: auckland,
  metadata: null,
  minZoom: 13,
  maxZoom: 16,
  mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
);

class OfflineRegionListItem {
  OfflineRegionListItem({
    @required this.offlineRegion,
    @required this.isDownloaded,
    @required this.isDownloading,
    @required this.name,
    @required this.estimatedTiles,
  });

  final OfflineRegion offlineRegion;
  final bool isDownloaded;
  final bool isDownloading;
  final String name;
  final int estimatedTiles;

  OfflineRegionListItem copyWith({
    bool isDownloaded,
    bool isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegion: offlineRegion,
        name: name,
        estimatedTiles: estimatedTiles,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        isDownloading: isDownloading ?? this.isDownloading,
      );
}

final List<OfflineRegionListItem> allRegions = [
  OfflineRegionListItem(
    offlineRegion: hawaiiRegion,
    isDownloaded: false,
    isDownloading: false,
    name: 'Hawaii',
    estimatedTiles: 61,
  ),
  OfflineRegionListItem(
    offlineRegion: santiagoRegion,
    isDownloaded: false,
    isDownloading: false,
    name: 'Santiago',
    estimatedTiles: 3580,
  ),
  OfflineRegionListItem(
    offlineRegion: aucklandRegion,
    isDownloaded: false,
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
    List<int> storedRegionsIds = (await getListOfRegions(
      accessToken: MapsDemo.ACCESS_TOKEN,
    ))
        .map((region) => region.id)
        .toList();
    List<OfflineRegionListItem> regions = [];
    for (var region in allRegions) {
      if (storedRegionsIds.contains(region.offlineRegion.id)) {
        regions.add(region.copyWith(isDownloaded: true));
      } else {
        regions.add(region);
      }
    }
    setState(() {
      _items.clear();
      _items.addAll(regions);
    });
  }

  void _downloadRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    try {
      await downloadOfflineRegion(
        item.offlineRegion,
        accessToken: MapsDemo.ACCESS_TOKEN,
      );
    } on Exception catch (_) {
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              isDownloaded: false,
            ));
      });
      return;
    }

    setState(() {
      _items.removeAt(index);
      _items.insert(
          index,
          item.copyWith(
            isDownloading: false,
            isDownloaded: true,
          ));
    });
  }

  void _deleteRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    await deleteOfflineRegion(
      item.offlineRegion.id,
      accessToken: MapsDemo.ACCESS_TOKEN,
    );

    setState(() {
      _items.removeAt(index);
      _items.insert(
          index,
          item.copyWith(
            isDownloading: false,
            isDownloaded: false,
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
