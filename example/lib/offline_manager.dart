import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl_example/main.dart';
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
  EventChannel _downloadTileProgress =
      const EventChannel('plugins.flutter.io/offline_tile_progress');

  @override
  void initState() {
    super.initState();
  }

  void _onTileRetrieve(Future<List> names) async {
    List futureNames = await names;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var downloadedTiles = (futureNames.length == 0) ? [] : futureNames;
        return ListAlertDialogWidget(downloadedTiles, mapController);
      },
    );
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.setDownloadTileLimit(2500);
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
                  accessToken: MapsDemo.ACCESS_TOKEN,
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
                              _onTileRetrieve(mapController.getDownloadedTiles());
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
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget downloadButton = FlatButton(
      child: Text("Download"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        mapController.downloadOnClick(widget.downloadController.text);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialogDownloadProgressWidget(
                _downloadTileProgress, mapController);
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
  final MapboxMapController mapController;
  ListAlertDialogWidget(this.downloadedTiles, this.mapController, {Key key})
      : super(key: key);

  @override
  _AlertDialogWidgetState createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<ListAlertDialogWidget> {
  String _index = "0";

  List<Widget> createColumn(List<dynamic> names) {
    List<Widget> col = [];
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
        widget.mapController.deleteDownloadedTiles(int.parse(_index));
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget navToButton = FlatButton(
      child: Text("Navigate To"),
      onPressed: () {
        widget.mapController.navigateToRegion(int.parse(_index));
        Navigator.of(context, rootNavigator: true).pop();
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
  final EventChannel downloadTileProgress;
  final MapboxMapController mapController;
  AlertDialogDownloadProgressWidget(
      this.downloadTileProgress, this.mapController,
      {Key key})
      : super(key: key);

  @override
  AlertDialogDownloadProgressState createState() =>
      AlertDialogDownloadProgressState();
}

class AlertDialogDownloadProgressState
    extends State<AlertDialogDownloadProgressWidget> {
  Stream<String> downloadProgressStream;
  Stream<String> get downloadProgress {
    if (downloadProgressStream == null) {
      downloadProgressStream = widget.downloadTileProgress
          .receiveBroadcastStream()
          .map<String>((val) => val);
    }
    return downloadProgressStream;
  }

  Widget build(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Stop"),
      onPressed: () {
//        widget.mapController.cancelDownloadingTiles();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget streamBuilder = StreamBuilder(
        stream: downloadProgress,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            var progress = double.tryParse(snapshot.data);
            if (progress == null) {
              return Text("Error: ${snapshot.data}");
            }

            if (progress >= 1.0) {
              // Download Completed
              return Text('Downloaded!');
            }
            return LinearProgressIndicator(
              backgroundColor: Colors.white10,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              value: progress,
            );
          } else {
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
