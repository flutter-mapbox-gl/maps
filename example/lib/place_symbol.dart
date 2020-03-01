// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      SymbolOptions(
        iconSize: 1.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    controller.updateSymbol(_selectedSymbol, changes);
  }

  void _add(String iconImage) {
    controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          center.latitude + sin(_symbolCount * pi / 6.0) / 20.0,
          center.longitude + cos(_symbolCount * pi / 6.0) / 20.0,
        ),
        iconImage: iconImage,
      ),
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

  void _changeIconOffset() {
    Offset currentAnchor = _selectedSymbol.options.iconOffset;
    if (currentAnchor == null) {
      // default value
      currentAnchor = Offset(0.0, 0.0);
    }
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _updateSelectedSymbol(SymbolOptions(iconOffset: newAnchor));
  }

  Future<void> _changeIconAnchor() async {
    String current = _selectedSymbol.options.iconAnchor;
    if (current == null || current == 'center') {
      current = 'bottom';
    } else {
      current = 'center';
    }
    _updateSelectedSymbol(
      SymbolOptions(iconAnchor: current),
    );
  }

  Future<void> _toggleDraggable() async {
    bool draggable = _selectedSymbol.options.draggable;
    if (draggable == null) {
      // default value
      draggable = false;
    }

    _updateSelectedSymbol(
      SymbolOptions(draggable: !draggable),
    );
  }

  Future<void> _changeAlpha() async {
    double current = _selectedSymbol.options.iconOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    double current = _selectedSymbol.options.iconRotate;
    if (current == null) {
      // default value
      current = 0;
    }
    _updateSelectedSymbol(
      SymbolOptions(iconRotate: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    double current = _selectedSymbol.options.iconOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  Future<void> _changeZIndex() async {
    int current = _selectedSymbol.options.zIndex;
    if (current == null) {
      // default value
      current = 0;
    }
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
                          onPressed: () =>
                              (_symbolCount == 12) ? null : _add("airport-15"),
                        ),
                        FlatButton(
                          child: const Text('add (custom icon)'),
                          onPressed: () => (_symbolCount == 12)
                              ? null
                              : _add("assets/symbols/custom-icon.png"),
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedSymbol == null) ? null : _remove,
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
                          child: const Text('change icon offset'),
                          onPressed:
                              (_selectedSymbol == null) ? null : _changeIconOffset,
                        ),
                        FlatButton(
                          child: const Text('change icon anchor'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _changeIconAnchor,
                        ),
                        FlatButton(
                          child: const Text('toggle draggable'),
                          onPressed: (_selectedSymbol == null)
                              ? null
                              : _toggleDraggable,
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
