part of mapbox_gl_platform_interface;

class NeoRanges {
  int visionRangeRadius;
  int adRangeRadius;
  int actionRangeRadius;
  CircleOptions visionRangeCircleOptions;
  CircleOptions adRangeCircleOptions;
  CircleOptions actionRangeCircleOptions;

  NeoRanges(
      {this.visionRangeRadius,
      this.adRangeRadius,
      this.actionRangeRadius,
      this.visionRangeCircleOptions,
      this.adRangeCircleOptions,
      this.actionRangeCircleOptions});
}
