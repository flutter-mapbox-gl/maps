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

Future<dynamic> downloadOfflineRegion(DownloadRegionArgs args) =>
    _globalChannel.invokeMethod(
      'downloadOfflineRegion',
      json.encode(args._toJson()),
    );

void downloadOfflineRegionStream(
  DownloadRegionArgs args,
  Function(DownloadRegionStatus event) onEvent,
) async {
  downloadOfflineRegion(args);
  String channelName = 'downloadOfflineRegion_${args.id}';
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
        status = InProgress(jsonData['progress'] ?? 0.0);
        break;
      case 'success':
        status = Success();
        break;
    }
    onEvent(status ?? (throw 'Invalid event status ${jsonData['status']}'));
  });
}
