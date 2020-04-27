import 'package:flutter/material.dart';

import 'offline_regions.dart';

class OfflineRegionMap extends StatelessWidget {
  OfflineRegionMap(this.item);

  final OfflineRegionListItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Region: ${item.name}'),
      ),
    );
  }
}
