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

enum DragEventType { start, drag, end }

Future<dynamic> setOffline(
  bool offline, {
  String? accessToken,
}) =>
    _globalChannel.invokeMethod(
      'setOffline',
      <String, dynamic>{
        'offline': offline,
        'accessToken': accessToken,
      },
    );

/// Sets custom header specified in [headers] for uris which contain strings,
/// specified in [filter].
///
/// If [filter] is omitted, headers are applied to all requests. 
/// An non-null empty [filter] will result in no headers being applied to any request.
/// 
/// On iOS by default changes to headers are not possible once they are set and
/// filters can't be applied as well.
/// You can use [allowMutableHeadersAndFilterOnIOS] to be able to change headers (e.g. when access
/// token is invalidated) and filters to prevent leaking authentication headers. This enforces the
/// use of swizzling and should be used with great care, since it swaps methods of exising classes
/// and may change upon native SDK upgrade. Use with caution.
Future<void> setHttpHeaders(Map<String, String> headers, {List<String>? filter, bool allowMutableHeadersAndFilterOnIOS = false}) {
  return _globalChannel.invokeMethod(
    'setHttpHeaders',
    <String, dynamic>{
      'headers': headers,
      'filter': filter,
      'allowMutableHeadersAndFilterOnIOS': Platform.isIOS ? allowMutableHeadersAndFilterOnIOS : false,
    },
  );
}

/// Gets custom headers that are used in Mapbox queries.
///
/// If [allowMutableHeadersAndFilterOnIOS] is used on iOS, headers are reported only after they are 
/// actually used in a request. This provides a proven way of checking whether setting headers works
/// and must be used the same way as [setHttpHeaders] is called as it involves swizzling. For more
/// information look at [setHttpHeaders] documentation. Use with caution.
Future<Map<String, String>?> getHttpHeaders({bool allowMutableHeadersAndFilterOnIOS = false}) async {
  final result = await _globalChannel.invokeMethod<Map<dynamic, dynamic>>(
    'getHttpHeaders',
    <String, dynamic>{
      'allowMutableHeadersAndFilterOnIOS': Platform.isIOS ? allowMutableHeadersAndFilterOnIOS : false,
    },
  );
  return result?.map((key, value) => MapEntry<String, String>(key.toString(), value.toString())) ?? <String, String>{};
}

Future<List<OfflineRegion>> mergeOfflineRegions(
  String path, {
  String? accessToken,
}) async {
  String regionsJson = await _globalChannel.invokeMethod(
    'mergeOfflineRegions',
    <String, dynamic>{
      'path': path,
      'accessToken': accessToken,
    },
  );
  Iterable regions = json.decode(regionsJson);
  return regions.map((region) => OfflineRegion.fromMap(region)).toList();
}

Future<List<OfflineRegion>> getListOfRegions({String? accessToken}) async {
  String regionsJson = await _globalChannel.invokeMethod(
    'getListOfRegions',
    <String, dynamic>{
      'accessToken': accessToken,
    },
  );
  Iterable regions = json.decode(regionsJson);
  return regions.map((region) => OfflineRegion.fromMap(region)).toList();
}

Future<OfflineRegion> updateOfflineRegionMetadata(
  int id,
  Map<String, dynamic> metadata, {
  String? accessToken,
}) async {
  final regionJson = await _globalChannel.invokeMethod(
    'updateOfflineRegionMetadata',
    <String, dynamic>{
      'id': id,
      'accessToken': accessToken,
      'metadata': metadata,
    },
  );

  return OfflineRegion.fromMap(json.decode(regionJson));
}

Future<dynamic> setOfflineTileCountLimit(int limit, {String? accessToken}) =>
    _globalChannel.invokeMethod(
      'setOfflineTileCountLimit',
      <String, dynamic>{
        'limit': limit,
        'accessToken': accessToken,
      },
    );

Future<dynamic> deleteOfflineRegion(int id, {String? accessToken}) =>
    _globalChannel.invokeMethod(
      'deleteOfflineRegion',
      <String, dynamic>{
        'id': id,
        'accessToken': accessToken,
      },
    );

Future<OfflineRegion> downloadOfflineRegion(
  OfflineRegionDefinition definition, {
  Map<String, dynamic> metadata = const {},
  String? accessToken,
  Function(DownloadRegionStatus event)? onEvent,
}) async {
  String channelName =
      'downloadOfflineRegion_${DateTime.now().microsecondsSinceEpoch}';

  final result = await _globalChannel
      .invokeMethod('downloadOfflineRegion', <String, dynamic>{
    'accessToken': accessToken,
    'channelName': channelName,
    'definition': definition.toMap(),
    'metadata': metadata,
  });

  if (onEvent != null) {
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
      DownloadRegionStatus? status;
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

  return OfflineRegion.fromMap(json.decode(result));
}
