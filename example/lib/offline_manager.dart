import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'page.dart';

class OfflineManagerPage extends ExamplePage {
  OfflineManagerPage() : super(const Icon(Icons.portable_wifi_off), 'Offline Manager');

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
  MethodChannel offlineMC;

  @override
  void initState() {
    super.initState();
    offlineMC = const MethodChannel('plugins.flutter.io/offline_map');
    offlineMC.setMethodCallHandler(_handleMethodOffline);

  }

  Future<dynamic> _handleMethodOffline(MethodCall call) async {
    switch (call.method) {
      case "retrieveDownloadedTileNames":
        var names = call.arguments;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            var downloadedTiles = (names.length == 0) ? [] : names;
            return AlertDialogWidget(
                downloadedTiles,
                offlineMC);
          },
        );
        return new Future.value("");
    }
  }

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
                    )
                ),
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
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.menu),
                            color: Colors.white,
                            onPressed: () {
                              // retrieve list of names
                              offlineMC.invokeMethod("offline#getDownloadedTiles");


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
        )
    );
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
          "downloadName" : widget.downloadController.text
        };
        offlineMC.invokeMethod("offline#downloadOnClick", args);
      },
    );

    // set up the AlertDialog
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

// *** Alert Dialog Box ***//
class AlertDialogWidget extends StatefulWidget {
  final List<dynamic> downloadedTiles;
  final MethodChannel mapBoxglMC;
  AlertDialogWidget(this.downloadedTiles, this.mapBoxglMC, {Key key}) : super(key: key);

  @override
  _AlertDialogWidgetState createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<AlertDialogWidget> {
  String _index = "0";


  List<Widget> createColumn(List<dynamic> names) {
    List<Widget> col = [];
//    for (String name in names) {
    for (var i=0;i<names.length;++i) {
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
        widget.mapBoxglMC.invokeMethod("offline#deleteDownloadedTiles",args);
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {Navigator.of(context).pop();},
    );
    Widget navToButton = FlatButton(
      child: Text("Navigate To"),
      onPressed: () {
        final Map<String, int> args = <String, int>{
          "indexToNavigate": int.parse(_index)
        };
        widget.mapBoxglMC.invokeMethod("offline#navigateToRegion",args);
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