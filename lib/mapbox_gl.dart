// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library mapbox_gl;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';

export 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart'
    show
        LatLng,
        LatLngBounds,
        LatLngQuad,
        CameraPosition,
        UserLocation,
        UserHeading,
        CameraUpdate,
        ArgumentCallbacks,
        Symbol,
        SymbolOptions,
        CameraTargetBounds,
        MinMaxZoomPreference,
        MapboxStyles,
        MyLocationTrackingMode,
        MyLocationRenderMode,
        CompassViewPosition,
        AttributionButtonPosition,
        Circle,
        CircleOptions,
        Line,
        LineOptions,
        Fill,
        FillOptions;

part 'src/controller.dart';
part 'src/mapbox_map.dart';
part 'src/global.dart';
part 'src/offline_region.dart';
part 'src/download_region_status.dart';
part 'src/layer_expressions.dart';
part 'src/layer_properties.dart';
part 'src/color_tools.dart';
