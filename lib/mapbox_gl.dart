library mapbox_gl;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';


part 'src/controller.dart';
part 'src/flutter_mapbox_view.dart';
part 'src/camera.dart';
part 'src/models.dart';

// import 'dart:async';

// import 'package:flutter/services.dart';

// class MapboxGl {
//   static const MethodChannel _channel =
//       const MethodChannel('mapbox_gl');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }
