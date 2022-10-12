import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class HttpHeadersPage extends ExamplePage {
  HttpHeadersPage() : super(const Icon(Icons.map), 'HTTP headers');

  @override
  Widget build(BuildContext context) {
    return const HttpHeaders();
  }
}

class HttpHeaders extends StatefulWidget {
  const HttpHeaders();

  @override
  State createState() => _HttpHeadersState();
}

class _HttpHeadersState extends State<HttpHeaders> {
  MapboxMapController? mapController;
  HttpServer? server;
  StreamSubscription<HttpRequest>? subscription;
  late Random _random;
  late String _customAccessToken;

  @override
  initState() {
    super.initState();

    _random = Random();
    _customAccessToken = _getRandomAccessToken();
    setHttpHeaders({_authorizationHeader: 'Bearer $_customAccessToken'}, allowMutableHeadersAndFilterOnIOS: true);

    HttpServer.bind(_localServerAddress, _localServerPort).then((server) {
      setState(() {
        this.server = server;
        subscription = server.listen(_onRequestRecieved);
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    server?.close();
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _onRequestRecieved(HttpRequest request) {
    final authorizationHeader = request.headers.value(_authorizationHeader);
    if (authorizationHeader?.contains(_customAccessToken) ?? false) {
      print("Authorized for ${request.uri.path}: $_customAccessToken");
      if (request.uri.path.contains('style.json')) {
        request.response.statusCode = 200;
        request.response.write(_customStyle);
        request.response.close();
        return;
      } else if (request.uri.path.contains('.pbf') ||
          request.uri.path.contains('sprites')) {        
        request.response.statusCode = 200;
        request.response.close();
        return;
      }
    }
    print("Unauthorized for ${request.uri.path}: Expected $_customAccessToken, got $authorizationHeader");
    request.response.statusCode = 401;
    request.response.close();
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      return Container(child: Text("Loading local server ..."));
    }
    return new Scaffold(
      body: MapboxMap(
        accessToken: MapsDemo.ACCESS_TOKEN,
        styleString: 'http://$_localServerAddress:$_localServerPort/style.json',
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
        onStyleLoadedCallback: onStyleLoadedCallback,
        gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      ].toSet(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _customAccessToken = _getRandomAccessToken();
          print("Reported headers: ${await getHttpHeaders(allowMutableHeadersAndFilterOnIOS: true)}");
          setHttpHeaders({_authorizationHeader: 'Bearer $_customAccessToken'}, allowMutableHeadersAndFilterOnIOS: true);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  String _getRandomAccessToken() => _random.nextInt(1000000000).toString();

  void onStyleLoadedCallback() {}
}

final _localServerAddress = InternetAddress.loopbackIPv4.host;
const _localServerPort = 8000;
const _authorizationHeader = 'Authorization';
final _customStyle = jsonEncode({
  "version": 8,
  "name": "local",
  "sources": {
    "local": {
      "type": "vector",
      "tiles": ["http://$_localServerAddress:$_localServerPort/{z}/{x}/{y}.pbf"]
    }
  },
  "sprite": "http://$_localServerAddress:$_localServerPort/sprites",
  "glyphs":
      "http://$_localServerAddress:$_localServerPort/fonts/{fontstack}/{range}.pbf?key={key}",
  "layers": [
    {
      "id": "background",
      "type": "background",
      "paint": {"background-color": "rgba(0, 255, 0, 1)"}
    },
    {
      "id": "water",
      "type": "fill",
      "source": "local",
      "source-layer": "water",
      "paint": {"fill-color": "rgb(158,189,255)"}
    }
  ],
  "id": "local"
});
