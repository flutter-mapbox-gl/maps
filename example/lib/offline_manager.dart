import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'page.dart';

class OfflineManagerPage extends ExamplePage {
  OfflineManagerPage()
      : super(const Icon(Icons.portable_wifi_off), 'Offline Manager');

  @override
  Widget build(BuildContext context) {
    return new OfflineManagerMap();
  }
}

class OfflineManagerMap extends StatefulWidget {
  OfflineManagerMap();
  final downloadController = TextEditingController();
  @override
  State createState() => OfflineManagerMapState();
}

class OfflineManagerMapState extends State<OfflineManagerMap> {
  MapboxMapController mapController;

//  LatLng _sourcePosition;
  MethodChannel _offlineMC;
  EventChannel _downloadTileProgress =
      const EventChannel('plugins.flutter.io/offline_tile_progress');
//  Stream<double> _downloadProgressStream;

  @override
  void initState() {
    super.initState();
    _offlineMC = const MethodChannel('plugins.flutter.io/offline_map');
    _offlineMC.setMethodCallHandler(_handleMethodOffline);
  }

  Future<dynamic> _handleMethodOffline(MethodCall call) async {
    switch (call.method) {
      case "retrieveDownloadedTileNames":
        var names = call.arguments;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            var downloadedTiles = (names.length == 0) ? [] : names;
            return ListAlertDialogWidget(downloadedTiles, _offlineMC);
          },
        );
        return new Future.value("");
    }
  }

//  Stream<double> get downloadProgress {
//    if (_downloadProgressStream == null) {
//      _downloadProgressStream = _downloadTileProgress
//          .receiveBroadcastStream()
//          .map<double>((val) => val);
//    }
//    return _downloadProgressStream;
//  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  CameraPosition _initCameraPosition() {
    return CameraPosition(
        // Default location
        target: LatLng(-33.852, 151.211),
        zoom: 14.0);
  }

  @protected
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
            child: new Stack(
          children: <Widget>[
            new Container(
                child: MapboxMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initCameraPosition(),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.Tracking,
              myLocationRenderMode: MyLocationRenderMode.GPS,
            )),
          ],
        )),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            color: Colors.black87,
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(1.0),
                    child: InkWell(
                      customBorder: new CircleBorder(),
                      onTap: () {},
                      splashColor: Colors.red,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.file_download),
                            color: Colors.white,
                            onPressed: () {
                              showDownloadAlertDialog(context);
                            },
                          ),
                          Text(
                            "Download",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(1.0),
                    child: InkWell(
                      customBorder: new CircleBorder(),
                      onTap: () {},
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.menu),
                            color: Colors.white,
                            onPressed: () {
                              // retrieve list of names
                              _offlineMC
                                  .invokeMethod("offline#getDownloadedTiles");
                            },
                          ),
                          Text(
                            "List",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  showDownloadAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget downloadButton = FlatButton(
      child: Text("Download"),
      onPressed: () {
        Navigator.of(context).pop();
        final Map<String, String> args = <String, String>{
          "downloadName": widget.downloadController.text
        };
        _offlineMC.invokeMethod("offline#downloadOnClick", args);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialogDownloadProgressWidget(_downloadTileProgress);
          },
        );
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Name New Region"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Download the map region you are currently viewing"),
            SizedBox(height: 30),
            TextFormField(
              controller: widget.downloadController,
              decoration: InputDecoration(
                hintText: "Enter Name",
//                errorText: validateDownloadTileName(widget.downloadController.text),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ]),
      actions: [
        cancelButton,
        downloadButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// *** List Tiles AlertDialog ***
class ListAlertDialogWidget extends StatefulWidget {
  final List<dynamic> downloadedTiles;
  final MethodChannel mapBoxglMC;
  ListAlertDialogWidget(this.downloadedTiles, this.mapBoxglMC, {Key key})
      : super(key: key);

  @override
  _AlertDialogWidgetState createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<ListAlertDialogWidget> {
  String _index = "0";

  List<Widget> createColumn(List<dynamic> names) {
    List<Widget> col = [];
//    for (String name in names) {
    for (var i = 0; i < names.length; ++i) {
      col.add(ListTile(
        title: Text(names[i].toString()),
        leading: Radio(
          value: i.toString(),
          groupValue: _index,
          onChanged: (String value) {
            setState(() {
              _index = value;
            });
          },
        ),
      ));
    }

    return col;
  }

  Widget build(BuildContext context) {
    // set up the buttons
    Widget deleteButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        final Map<String, int> args = <String, int>{
          "indexToDelete": int.parse(_index)
        };
        widget.mapBoxglMC.invokeMethod("offline#deleteDownloadedTiles", args);
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget navToButton = FlatButton(
      child: Text("Navigate To"),
      onPressed: () {
        final Map<String, int> args = <String, int>{
          "indexToNavigate": int.parse(_index)
        };
        widget.mapBoxglMC.invokeMethod("offline#navigateToRegion", args);
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Downloaded Tiles"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: createColumn(widget.downloadedTiles)),
      actions: [
        deleteButton,
        cancelButton,
        navToButton,
      ],
    );
    return alert;
  }
}

// *** Progress Bar ***
class AlertDialogDownloadProgressWidget extends StatefulWidget {
//  final List<dynamic> downloadedTiles;
//  final MethodChannel mapBoxglMC;
  final EventChannel downloadTileProgress;

  AlertDialogDownloadProgressWidget(this.downloadTileProgress, {Key key})
      : super(key: key);

  @override
  AlertDialogDownloadProgressState createState() =>
      AlertDialogDownloadProgressState();
}

class AlertDialogDownloadProgressState
    extends State<AlertDialogDownloadProgressWidget> {
  double _progress = 0;
  Stream<double> downloadProgressStream;

  Stream<double> get downloadProgress {
    if (downloadProgressStream == null) {
      downloadProgressStream = widget.downloadTileProgress
          .receiveBroadcastStream()
          .map<double>((val) => val);
    }
    return downloadProgressStream;
  }

  Widget build(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget streamBuilder = StreamBuilder(
        stream: downloadProgress,
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            // Close Dialog after 3 seconds
            if(snapshot.data>=1.0){
              Timer(Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            }
            return LinearProgressIndicator(
              backgroundColor: Colors.white10,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              value: snapshot.data,
            );

          }else{
            return Text("Downloading Failed");
          }

        });
    AlertDialog alert = AlertDialog(
      title: Text("Downloading"),
      content: streamBuilder,
      actions: [
        cancelButton,
      ],
    );
    return alert;
  }
}

class _LinearProgressIndicatorApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LinearProgressIndicatorAppState();
  }
}

class _LinearProgressIndicatorAppState
    extends State<_LinearProgressIndicatorApp> {
  double _progress = 0;

  void startTimer() {
    new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_progress == 1) {
            timer.cancel();
          } else {
            _progress += 0.2;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Woolha.com Flutter Tutorial'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LinearProgressIndicator(
                backgroundColor: Colors.cyanAccent,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                value: _progress,
              ),
              RaisedButton(
                child: Text('Start timer'),
                onPressed: () {
                  setState(() {
                    _progress = 0;
                  });
                  startTimer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
