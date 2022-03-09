import 'dart:math';

import 'package:flutter/foundation.dart';
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

  final sourceId = 'points';
  final layerId = 'symbols';

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
            iconSize: kIsWeb ? 0.5 : 1.0,
            textField: '{ten}',
            textColor: '#601B1B',
            textSize: 12,
            textAnchor: 'top',
            textHaloBlur: 0.5,
            textHaloWidth: 0.5,
            textHaloColor: 'rgba(255, 255, 255, 1)',
          ),
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
      "geometry": {
        "type": "Point",
        "coordinates": [105.50484084, 21.13757161]
      },
      "properties": {
        "id": 1,
        "madoituong": "BP03",
        "ten": "Đền Chúa Bản Tỉnh",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49988233, 21.14436791]
      },
      "properties": {
        "id": 2,
        "madoituong": "BP03",
        "ten": "Đền Giáp",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50034321, 21.14113785]
      },
      "properties": {
        "id": 3,
        "madoituong": "BP03",
        "ten": "Đền Kiếp Bạc",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50425331, 21.13881287]
      },
      "properties": {
        "id": 4,
        "madoituong": "BP03",
        "ten": "Đền Kính Thiên",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.48545591, 21.13864893]
      },
      "properties": {
        "id": 5,
        "madoituong": "BP03",
        "ten": "Đền Và",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50106879, 21.1280937]
      },
      "properties": {
        "id": 6,
        "madoituong": "BO03",
        "ten": "Chùa Trì",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5090232, 21.13580011]
      },
      "properties": {
        "id": 7,
        "madoituong": "BO03",
        "ten": "Chùa Thuần Nghệ",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5042187, 21.13611567]
      },
      "properties": {
        "id": 8,
        "madoituong": "BO03",
        "ten": "Chùa Linh Ứng",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50255942, 21.14230481]
      },
      "properties": {
        "id": 9,
        "madoituong": "BO03",
        "ten": "Chùa Linh Sơn",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49815767, 21.12558376]
      },
      "properties": {
        "id": 10,
        "madoituong": "BP02",
        "ten": "Đình Lăng Mỗ",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.49430803, 21.13038998]
      },
      "properties": {
        "id": 11,
        "madoituong": "BP02",
        "ten": "Đình Vân Gia",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50861465, 21.13563377]
      },
      "properties": {
        "id": 12,
        "madoituong": "BP02",
        "ten": "Đình Thuần Nghệ",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5065032, 21.14262125]
      },
      "properties": {
        "id": 13,
        "madoituong": "BO04",
        "ten": "Nhà thờ Sơn Tây",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50646655, 21.14392447]
      },
      "properties": {
        "id": 14,
        "madoituong": "BO03",
        "ten": "Chùa Hậu An",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50025604, 21.14190215]
      },
      "properties": {
        "id": 15,
        "madoituong": "BO03",
        "ten": "Chùa Phúc Hưng",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.48925672, 21.13141519]
      },
      "properties": {
        "id": 16,
        "madoituong": "BO03",
        "ten": "Chùa Vân Gia",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50663852, 21.14382634]
      },
      "properties": {
        "id": 17,
        "madoituong": "BP02",
        "ten": "Đình Hậu An",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.50328466, 21.14290086]
      },
      "properties": {
        "id": 18,
        "madoituong": "BP02",
        "ten": "Đình Hàng Đàn",
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [105.5014738, 21.14178775]
      },
      "properties": {
        "id": 19,
        "madoituong": "BP02",
        "ten": "Đình Đệ Nhị",
      }
    }
  ],
};
