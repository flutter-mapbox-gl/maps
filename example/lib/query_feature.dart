import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class QueryFeature extends ExamplePage {
  QueryFeature() : super(const Icon(Icons.map), 'Query rendered features');

  @override
  Widget build(BuildContext context) {
    return FullMap();
  }
}

class FullMap extends StatefulWidget {
  FullMap({Key? key}) : super(key: key);

  @override
  State<FullMap> createState() => _FullMapState();
}

class _FullMapState extends State<FullMap> {
  MapboxMapController? controller;

  final sourceId = 'NenDiaLy2N5N';
  final layerId = 'CongTrinhTonGiaoTinNguong';
  final sourceLayer = 'CongTrinhTonGiaoTinNguong';

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFeatureTapped.add(_onFeatureTap);
  }

  _onStyleLoadedCallback() {
    controller?.addGeoJsonSource(sourceId, _features);
    rootBundle.load('assets/symbols/custom-icon.png').then((byteData) {
      var bytes = byteData.buffer.asUint8List();
      controller?.addImage('icon', bytes).then((value) {
        controller?.addSymbolLayer(
          sourceId,
          layerId,
          const SymbolLayerProperties(
            iconImage: 'icon',
            iconAnchor: 'bottom',
            textField: '{ten}',
            textColor: '#601B1B',
            textSize: 12,
            textAnchor: 'top',
            textHaloBlur: 0.5,
            textHaloWidth: 0.5,
            textHaloColor: 'rgba(255, 255, 255, 1)',
          ),
          sourceLayer: sourceLayer,
        );
      });
    });
  }

  _queryInRect() async {
    final latLngBounds = await controller?.getVisibleRegion();

    final points = await controller?.toScreenLocationBatch([
      latLngBounds!.southwest,
      latLngBounds.northeast,
    ]);
    final filter = [
      Expressions.smallerOrEqual,
      'Đền',
      ['get', 'ten'],
    ];
    final rect = Rect.fromPoints(
        Offset(points?.first.x as double, points?.first.y as double),
        Offset(points?.last.x as double, points?.last.y as double));
    final object = await controller?.queryRenderedFeaturesInRect(
      rect,
      [layerId],
      filter,
    );

    var snackBar = SnackBar(
      content: Text('# features: ${object?.length}'),
    );

    if (object == null || object.isEmpty) {
      snackBar = SnackBar(
        content: Text('QueryRenderedFeaturesInRect: No features found!'),
      );
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _onFeatureTap(
    dynamic featureId,
    Point<double> point,
    LatLng latLng,
  ) {
    final snackBar = SnackBar(
      content: Text(
        'Tapped feature with id $featureId',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapboxMap(
            styleString: MapboxStyles.EMPTY,
            accessToken: MapsDemo.ACCESS_TOKEN,
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
            onStyleLoadedCallback: _onStyleLoadedCallback,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton(
              onPressed: _queryInRect,
              child: Text('QueryRenderedFeaturesInRect filter by ten <= Đền'),
            ),
          )
        ],
      ),
    );
  }
}

const _kInitialPosition = CameraPosition(
  target: LatLng(21.1243424, 105.497546),
  zoom: 13.0,
);

const _features = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.1",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50484084, 21.13757161]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 1,
        "madoituong": "BP03",
        "ten": "Đền Chúa Bản Tỉnh",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.2",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49988233, 21.14436791]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 2,
        "madoituong": "BP03",
        "ten": "Đền Giáp",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.3",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50034321, 21.14113785]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 3,
        "madoituong": "BP03",
        "ten": "Đền Kiếp Bạc",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.4",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50425331, 21.13881287]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 4,
        "madoituong": "BP03",
        "ten": "Đền Kính Thiên",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.5",
      "geometry": {
        "type": "Point",
        "coordinates": [105.48545591, 21.13864893]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 5,
        "madoituong": "BP03",
        "ten": "Đền Và",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.6",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50106879, 21.1280937]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 6,
        "madoituong": "BO03",
        "ten": "Chùa Trì",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.7",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5090232, 21.13580011]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 7,
        "madoituong": "BO03",
        "ten": "Chùa Thuần Nghệ",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.8",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5042187, 21.13611567]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 8,
        "madoituong": "BO03",
        "ten": "Chùa Linh Ứng",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.9",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50255942, 21.14230481]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 9,
        "madoituong": "BO03",
        "ten": "Chùa Linh Sơn",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.10",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49815767, 21.12558376]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 10,
        "madoituong": "BP02",
        "ten": "Đình Lăng Mỗ",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.11",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49430803, 21.13038998]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 11,
        "madoituong": "BP02",
        "ten": "Đình Vân Gia",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.12",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50861465, 21.13563377]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 12,
        "madoituong": "BP02",
        "ten": "Đình Thuần Nghệ",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.13",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5065032, 21.14262125]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 13,
        "madoituong": "BO04",
        "ten": "Nhà thờ Sơn Tây",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.14",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50646655, 21.14392447]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 14,
        "madoituong": "BO03",
        "ten": "Chùa Hậu An",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.15",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50025604, 21.14190215]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 15,
        "madoituong": "BO03",
        "ten": "Chùa Phúc Hưng",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.16",
      "geometry": {
        "type": "Point",
        "coordinates": [105.48925672, 21.13141519]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 16,
        "madoituong": "BO03",
        "ten": "Chùa Vân Gia",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.17",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50663852, 21.14382634]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 17,
        "madoituong": "BP02",
        "ten": "Đình Hậu An",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.18",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50328466, 21.14290086]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 18,
        "madoituong": "BP02",
        "ten": "Đình Hàng Đàn",
        "diachi": null,
        "xephangditich": null
      }
    },
    {
      "type": "Feature",
      "id": "CongTrinhTonGiaoTinNguong.19",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5014738, 21.14178775]
      },
      "geometry_name": "geom",
      "properties": {
        "fid": 19,
        "madoituong": "BP02",
        "ten": "Đình Đệ Nhị",
        "diachi": null,
        "xephangditich": null
      }
    }
  ],
  "totalFeatures": 19,
  "numberMatched": 19,
  "numberReturned": 19,
  "timeStamp": "2022-03-09T14:18:55.887Z",
  "crs": {
    "type": "name",
    "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}
  }
};
