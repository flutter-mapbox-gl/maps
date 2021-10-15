import 'dart:io';
import 'dart:convert';

import 'package:mustache/mustache.dart';
import 'package:recase/recase.dart';

main() async {
  var styleJson =
      jsonDecode(await new File('./scripts/input/style.json').readAsString());

  await renderTemplate(styleJson, "LayerPropertyConverter.template.java",
      './android/src/main/java/com/mapbox/mapboxgl/LayerPropertyConverter.java');

  await renderTemplate(styleJson, "LayerPropertyConverter.template.swift",
      "./ios/Classes/LayerPropertyConverter.swift");
}

Future<void> renderTemplate(Map<String, dynamic> styleJson, String templateName,
    String outputPath) async {
  var javaTemplate =
      await File('./scripts/templates/$templateName').readAsString();
  var template = Template(javaTemplate);

  var outputFile = File(outputPath);
  final renderContext = {
    'lineStyles': buildStyleProperties(styleJson, "layout_line", "paint_line"),
    'fillStyles': buildStyleProperties(styleJson, "layout_fill", "paint_fill"),
    'circleStyles':
        buildStyleProperties(styleJson, "layout_circle", "paint_circle"),
    'symbolStyles':
        buildStyleProperties(styleJson, "layout_symbol", "paint_symbol")
  };
  outputFile.writeAsString(template.renderString(renderContext));
}

List<Map<String, String>> buildStyleProperties(
    Map<String, dynamic> styleJson, String layoutKey, String paintKey) {
  final Map<String, dynamic> layout = styleJson[layoutKey];
  final Map<String, dynamic> paint = styleJson[paintKey];

  return layout.keys
      .followedBy(paint.keys)
      .map((f) =>
          <String, String>{'property': f, 'function': new ReCase(f).camelCase})
      .toList();
}
