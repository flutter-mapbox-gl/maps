part of mapbox_gl_platform_interface;

class MyLocationStyle {
  final Color? puckColor;
  final Color? pulsingColor;

  const MyLocationStyle({this.puckColor, this.pulsingColor});

  dynamic toJson() => {
        "puckColor": puckColor?.toHexStringRGB(),
        "pulsingColor": pulsingColor?.toHexStringRGB(),
      }..removeWhere((key, value) => value == null);
}
