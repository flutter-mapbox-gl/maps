library mapbox_gl_web;

import 'dart:async';
// FIXED HERE: https://github.com/dart-lang/linter/pull/1985
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:js';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';
import 'package:mapbox_gl_dart/mapbox_gl_dart.dart' hide Point;
import 'package:mapbox_gl_dart/mapbox_gl_dart.dart' as mapbox show Point;

part 'src/convert.dart';
part 'src/mapbox_map_plugin.dart';
part 'src/options_sink.dart';
part 'src/symbol_manager.dart';
part 'src/mapbox_map_controller.dart';
