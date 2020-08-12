// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mapbox_gl;

final MethodChannel _globalChannel =
    MethodChannel('plugins.flutter.io/mapbox_gl');

/// Copy tiles db file passed in to the tiles cache directory (sideloaded) to
/// make tiles available offline.
Future<void> installOfflineMapTiles(String tilesDb) async {
  await _globalChannel.invokeMethod(
    'installOfflineMapTiles',
    <String, dynamic>{
      'tilesdb': tilesDb,
    },
  );
}

Future<List<OfflineRegion>> getListOfRegions({String accessToken}) async {
  String regionsJson = await _globalChannel.invokeMethod(
    'getListOfRegions',
    <String, dynamic>{
      'accessToken': accessToken,
    },
  );
  Iterable regions = json.decode(regionsJson);
  return regions.map((region) => OfflineRegion.fromJson(region)).toList();
}

Future<dynamic> deleteOfflineRegion(int id, {String accessToken}) =>
    _globalChannel.invokeMethod(
      'deleteOfflineRegion',
      <String, dynamic>{
        'id': id,
        'accessToken': accessToken,
      },
    );

Future<dynamic> downloadOfflineRegion(
  OfflineRegion region, {
  String accessToken,
}) {
  final Map<String, dynamic> jsonMap = region._toJson()
    ..putIfAbsent('accessToken', () => accessToken);

  return _globalChannel.invokeMethod(
    'downloadOfflineRegion',
    json.encode(jsonMap),
  );
}

void downloadOfflineRegionStream(
  OfflineRegion region,
  Function(DownloadRegionStatus event) onEvent, {
  String accessToken,
}) async {
  downloadOfflineRegion(region, accessToken: accessToken);
  String channelName = 'downloadOfflineRegion_${region.id}';
  EventChannel(channelName).receiveBroadcastStream().handleError((error) {
    if (error is PlatformException) {
      onEvent(Error(error));
      return Error(error);
    }
    var unknownError = Error(
      PlatformException(
        code: 'UnknowException',
        message:
            'This error is unhandled by plugin. Please contact us if needed.',
        details: error,
      ),
    );
    onEvent(unknownError);
    return unknownError;
  }).listen((data) {
    final Map<String, dynamic> jsonData = json.decode(data);
    DownloadRegionStatus status;
    switch (jsonData['status']) {
      case 'start':
        status = InProgress(0.0);
        break;
      case 'progress':
        final dynamic value = jsonData['progress'];
        double progress = 0.0;

        if (value is int) {
          progress = value.toDouble();
        }

        if (value is double) {
          progress = value;
        }

        status = InProgress(progress);
        break;
      case 'success':
        status = Success();
        break;
    }
    onEvent(status ?? (throw 'Invalid event status ${jsonData['status']}'));
  });
}
