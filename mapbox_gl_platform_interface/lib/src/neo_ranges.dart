part of mapbox_gl_platform_interface;

class NeoRanges {
  LatLng geometry;
  NeoRangeOptions visionRangeOptions;
  NeoRangeOptions adRangeOptions;
  NeoRangeOptions actionRangeOptions;
  int circlePrecision;

  NeoRanges({
    @required this.visionRangeOptions,
    @required this.adRangeOptions,
    @required this.actionRangeOptions,
    @required this.geometry,
    this.circlePrecision = 180,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vision_range_options': visionRangeOptions.toJson(),
        'ad_range_options': adRangeOptions.toJson(),
        'action_range_options': actionRangeOptions.toJson(),
        'circle_precision': circlePrecision,
        'geometry': geometry.toJson(),
      };

  factory NeoRanges.empty() {
    return NeoRanges(
      actionRangeOptions: NeoRangeOptions.empty(),
      adRangeOptions: NeoRangeOptions.empty(),
      visionRangeOptions: NeoRangeOptions.empty(),
      circlePrecision: 1,
      geometry: LatLng(0, 0),
    );
  }
}

class NeoRangeOptions {
  Color fillColor;
  double fillOpacity;
  Color borderColor;
  double borderOpacity;
  int borderWidth;
  int radius;

  NeoRangeOptions({
    @required this.fillColor,
    @required this.fillOpacity,
    @required this.borderColor,
    @required this.borderOpacity,
    @required this.borderWidth,
    @required this.radius,
  });

  factory NeoRangeOptions.empty() {
    return NeoRangeOptions(
      radius: 0,
      fillOpacity: 0,
      fillColor: Colors.white,
      borderColor: Colors.white,
      borderOpacity: 0,
      borderWidth: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'radius': radius,
      'fill-color': _parseColorInString(fillColor),
      'fill-opacity': fillOpacity,
      'border-color': _parseColorInString(borderColor),
      'border-opacity': borderOpacity,
      'border-width': borderWidth,
    };
  }

  String _parseColorInString(Color color) {
    final String colorString = color.toString();
    final String valueString = colorString.split('(0x')[1].split(')')[0];
    return '#${valueString.substring(2)}';
  }
}
