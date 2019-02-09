// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'page.dart';

class PlaceSymbolPage extends Page {
  PlaceSymbolPage() : super(const Icon(Icons.place), 'Place symbol');

  @override
  Widget build(BuildContext context) {
    return const PlaceSymbolBody();
  }
}

class PlaceSymbolBody extends StatefulWidget {
  const PlaceSymbolBody();

  @override
  State<StatefulWidget> createState() => PlaceSymbolBodyState();
}

class PlaceSymbolBodyState extends State<PlaceSymbolBody> {
  PlaceSymbolBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  MapboxMapController controller;
  int _symbolCount = 0;
  Symbol _selectedSymbol;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  @override
  void dispose() {
    controller?.onSymbolTapped?.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
//      _updateSelectedSymbol(
//        const SymbolOptions(icon: BitmapDescriptor.defaultSymbol),
//      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    /* _updateSelectedSymbol(
      SymbolOptions(
        icon: BitmapDescriptor.defaultSymbolWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );*/
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    controller.updateSymbol(_selectedSymbol, changes);
  }

  void _add() {
    controller.addSymbol(
      SymbolOptions(
          geometry: LatLng(
            center.latitude + sin(_symbolCount * pi / 6.0) / 20.0,
            center.longitude + cos(_symbolCount * pi / 6.0) / 20.0,
          ),
          iconImage: "airport-15"),
    );
    setState(() {
      _symbolCount += 1;
    });
  }

  void _remove() {
    controller.removeSymbol(_selectedSymbol);
    setState(() {
      _selectedSymbol = null;
      _symbolCount -= 1;
    });
  }

  void _changePosition() {
    final LatLng current = _selectedSymbol.options.geometry;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _updateSelectedSymbol(
      SymbolOptions(
        geometry: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeAnchor() {
    final Offset currentAnchor = _selectedSymbol.options.iconOffset;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _updateSelectedSymbol(SymbolOptions(iconOffset: newAnchor));
  }

  Future<void> _changeInfoAnchor() async {
    //final Offset currentAnchor = _selectedSymbol.options.infoWindowAnchor;
    //final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    //_updateSelectedSymbol(SymbolOptions(infoWindowAnchor: newAnchor));
  }

  Future<void> _toggleDraggable() async {
    // _updateSelectedSymbol(
    //  SymbolOptions(draggable: !_selectedSymbol.options.draggable),
    //);
  }

  Future<void> _toggleFlat() async {
    // only supported as part of symbol manager, not per symbol
    //_updateSelectedSymbol(SymbolOptions(flat: !_selectedSymbol.options.flat));
  }

  Future<void> _changeInfo() async {
//    final InfoWindowText currentInfo = _selectedSymbol.options.infoWindowText;
//    _updateSelectedSymbol(SymbolOptions(
//      infoWindowText: InfoWindowText(
//        currentInfo.title,
//        currentInfo.snippet + '*',
//      ),
//    ));
  }

  Future<void> _changeAlpha() async {
    final double current = _selectedSymbol.options.iconOpacity;
    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    final double current = _selectedSymbol.options.iconRotate;
    _updateSelectedSymbol(
      SymbolOptions(iconRotate: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    _updateSelectedSymbol(
      SymbolOptions(
          iconOpacity: _selectedSymbol.options.iconOpacity == 0.0 ? 0.0 : 1.0),
    );
  }

  Future<void> _changeZIndex() async {
    final int current = _selectedSymbol.options.zIndex;
    _updateSelectedSymbol(
      SymbolOptions(zIndex: current == 12 ? 0 : current + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: MapboxMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('add'),
                          onPressed: (_symbolCount == 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedSymbol == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('change info'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _changeInfo,
                        ),
                        FlatButton(
                          child: const Text('change info anchor'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _changeInfoAnchor,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change alpha'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _changeAlpha,
                        ),
                        FlatButton(
                          child: const Text('change anchor'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _changeAnchor,
                        ),
                        FlatButton(
                          child: const Text('toggle draggable'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _toggleDraggable,
                        ),
                        FlatButton(
                          child: const Text('toggle flat'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _toggleFlat,
                        ),
                        FlatButton(
                          child: const Text('change position'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _changePosition,
                        ),
                        FlatButton(
                          child: const Text('change rotation'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _changeRotation,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('change zIndex'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _changeZIndex,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
