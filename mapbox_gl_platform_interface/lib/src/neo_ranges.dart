part of mapbox_gl_platform_interface;

class NeoRanges {
  int visionRangeRadius;
  int adRangeRadius;
  int actionRangeRadius;
  int circlePrecision;
  NeoRangeOptions visionRangeOptions;
  NeoRangeOptions adRangeOptions;
  NeoRangeOptions actionRangeOptions;

  NeoRanges(
      {@required this.visionRangeRadius,
      @required this.adRangeRadius,
      @required this.actionRangeRadius,
      @required this.visionRangeOptions,
      @required this.adRangeOptions,
      @required this.actionRangeOptions,
      this.circlePrecision = 180});
}

class NeoRangeOptions {
  String fillColor;
  int fillOpacity;
  String borderColor;
  int borderOpacity;
  int borderWidth;

  NeoRangeOptions({
    @required this.fillColor,
    @required this.fillOpacity,
    @required this.borderColor,
    @required this.borderOpacity,
    @required this.borderWidth,
  });

  toJson() {
    return {
      "fill-color": fillColor,
      "fill-opacity": fillOpacity,
      "border-color": borderColor,
      "border-opacity": borderOpacity,
      "border-width": borderWidth,
    };
  }
}
