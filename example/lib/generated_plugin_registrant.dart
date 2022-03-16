//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:device_info_plus_web/device_info_plus_web.dart';
import 'package:location_web/location_web.dart';
import 'package:mapbox_gl_web/mapbox_gl_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  DeviceInfoPlusPlugin.registerWith(registrar);
  LocationWebPlugin.registerWith(registrar);
  MapboxMapPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
