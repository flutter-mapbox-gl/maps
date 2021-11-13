// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl_example/custom_marker.dart';
import 'package:mapbox_gl_example/full_map.dart';
import 'package:mapbox_gl_example/offline_regions.dart';
import 'package:mapbox_gl_example/place_batch.dart';
import 'package:mapbox_gl_example/layer.dart';

import 'animate_camera.dart';
import 'annotation_order_maps.dart';
import 'full_map.dart';
import 'line.dart';
import 'local_style.dart';
import 'map_ui.dart';
import 'move_camera.dart';
import 'click_annotations.dart';
import 'page.dart';
import 'place_circle.dart';
import 'place_source.dart';
import 'place_symbol.dart';
import 'place_fill.dart';
import 'scrolling_map.dart';

final List<ExamplePage> _allPages = <ExamplePage>[
  MapUiPage(),
  FullMapPage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceSymbolPage(),
  PlaceSourcePage(),
  LinePage(),
  LocalStylePage(),
  LayerPage(),
  PlaceCirclePage(),
  PlaceFillPage(),
  ScrollingMapPage(),
  OfflineRegionsPage(),
  AnnotationOrderPage(),
  CustomMarkerPage(),
  BatchAddPage(),
  ClickAnnotationPage()
];

class MapsDemo extends StatelessWidget {
  // FIXME: You need to pass in your access token via the command line argument
  // --dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE
  // It is also possible to pass it in while running the app via an IDE by
  // passing the same args there.
  //
  // Alternatively you can replace `String.fromEnvironment("ACCESS_TOKEN")`
  // in the following line with your access token directly.
  static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");

  void _pushPage(BuildContext context, ExamplePage page) async {
    if (!kIsWeb) {
      final location = Location();
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != PermissionStatus.granted) {
        await location.requestPermission();
      }
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MapboxMaps examples')),
      body: ACCESS_TOKEN.isEmpty || ACCESS_TOKEN.contains("YOUR_TOKEN")
          ? buildAccessTokenWarning()
          : ListView.separated(
              itemCount: _allPages.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (_, int index) => ListTile(
                leading: _allPages[index].leading,
                title: Text(_allPages[index].title),
                onTap: () => _pushPage(context, _allPages[index]),
              ),
            ),
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Please pass in your access token with",
            "--dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE",
            "passed into flutter run or add it to args in vscode's launch.json",
          ]
              .map((text) => Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}
