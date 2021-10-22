import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:mustache_template/mustache_template.dart';
import 'package:recase/recase.dart';

main() async {
  var styleJson = jsonDecode(await new File(
          '/Users/ocell/code/flutter-mapbox-gl/scripts/input/style.json')
      .readAsString());

  final layerTypes = ["symbol", "circle", "line", "fill"];

  final renderContext = {
    "layerTypes": [
      for (var type in layerTypes)
        {
          "type": type,
          "typePascal": ReCase(type).pascalCase,
          "paint_properties": buildStyleProperties(styleJson, "paint_$type"),
          "layout_properties": buildStyleProperties(styleJson, "layout_$type"),
        },
    ],
    'expressions': buildExpressionProperties(styleJson)
  };

  renderContext["all_layout_properties"] = [
    for (final type in renderContext["layerTypes"]!)
      ...type["layout_properties"].map((p) => p["value"]).toList()
  ].toSet().map((p) => {"property": p}).toList();

  print("generating java");
  await renderLayerPropertyConverter(
    renderContext,
    "java",
    './android/src/main/java/com/mapbox/mapboxgl/LayerPropertyConverter.java',
  );
  print("generating swift");
  await renderLayerPropertyConverter(
    renderContext,
    "swift",
    "./ios/Classes/LayerPropertyConverter.swift",
  );

  print("generating dart");
  await renderDart(renderContext);
  await renderWebDart(renderContext);
}

Future<void> renderLayerPropertyConverter(
  Map<String, List> renderContext,
  String templateType,
  String outputPath,
) async {
  var templateFile = await File(
          './scripts/templates/LayerPropertyConverter.$templateType.template')
      .readAsString();

  var template = Template(templateFile);
  var outputFile = File(outputPath);

  outputFile.writeAsString(template.renderString(renderContext));
}

Future<void> renderDart(
  Map<String, dynamic> renderContext,
) async {
  var templateFile =
      await File('./scripts/templates/layer_helper.dart.template')
          .readAsString();

  var template = Template(templateFile);
  var outputFile = File("./lib/src/layer_helper.dart");

  outputFile.writeAsString(template.renderString(renderContext));
}

Future<void> renderWebDart(
  Map<String, dynamic> renderContext,
) async {
  var templateFile = await File('./scripts/templates/layer_tools.dart.template')
      .readAsString();

  var template = Template(templateFile);
  var outputFile = File("./mapbox_gl_web/lib/src/layer_tools.dart");

  outputFile.writeAsString(template.renderString(renderContext));
}

List<Map<String, dynamic>> buildStyleProperties(
    Map<String, dynamic> styleJson, String key) {
  final Map<String, dynamic> items = styleJson[key];

  return items.entries.map((e) => buildStyleProperty(e.key, e.value)).toList();
}

const renamedIosProperties = {
  "iconImage": "iconImageName",
  "iconRotate": "iconRotation",
  "iconSize": "iconScale",
  "iconKeepUpright": "keepsIconUpright",
  "iconTranslate": "iconTranslation",
  "iconTranslateAnchor": "iconTranslationAnchor",
  "iconAllowOverlap": "iconAllowsOverlap",
  "iconIgnorePlacement": "iconIgnoresPlacement",
  "textTranslate": "textTranslation",
  "textTranslateAnchor": "textTranslationAnchor",
  "textIgnorePlacement": "textIgnoresPlacement",
  "textField": "text",
  "textFont": "textFontNames",
  "textSize": "textFontSize",
  "textMaxWidth": "maximumTextWidth",
  "textJustify": "textJustification",
  "textMaxAngle": "maximumTextAngle",
  "textWritingMode": "textWritingModes",
  "textRotate": "textRotation",
  "textKeepUpright": "keepsTextUpright",
  "textAllowOverlap": "textAllowsOverlap",
  "symbolAvoidEdges": "symbolAvoidsEdges",
  "circleTranslate": "circleTranslation",
  "circleTranslateAnchor": "circleTranslationAnchor",
  "circlePitchScale": "circleScaleAlignment",
  "lineTranslate": "lineTranslation",
  "lineTranslateAnchor": "lineTranslationAnchor",
  "lineDasharray": "lineDashPattern",
  "fillAntialias": "fillAntialiased",
  "fillTranslate": "fillTranslation",
  "fillTranslateAnchor": "fillTranslationAnchor",
  "visibility": "isVisible",
};

Map<String, dynamic> buildStyleProperty(
    String key, Map<String, dynamic> value) {
  final camelCase = ReCase(key).camelCase;
  return <String, dynamic>{
    'value': key,
    'isVisibilityProperty': key == "visibility",
    'requiresLiteral': key == "icon-image",
    'isIosAsCamelCase': renamedIosProperties.containsKey(camelCase),
    'iosAsCamelCase': renamedIosProperties[camelCase],
    'doc': value["doc"],
    'docSplit':
        buildDocLines(value["doc"], 70).map((s) => {"part": s}).toList(),
    'valueAsCamelCase': camelCase
  };
}

List<String> buildDocLines(String input, int lineLength) {
  final words = input.split(" ");
  final chunks = <String>[];

  String chunk = "";
  for (var word in words) {
    final nextChunk = chunk + " " + word;
    if (nextChunk.length > lineLength || chunk.endsWith("\n")) {
      chunks.add(chunk.replaceAll("\n", ""));
      chunk = " " + word;
    } else {
      chunk = nextChunk;
    }
  }
  chunks.add(chunk);

  return chunks;
}

List<Map<String, dynamic>> buildExpressionProperties(
    Map<String, dynamic> styleJson) {
  final Map<String, dynamic> items = styleJson["expression_name"]["values"];

  final renamed = {
    "var": "varExpression",
    "in": "inExpression",
    "case": "caseExpression",
    "to-string": "toStringExpression",
    "+": "plus",
    "*": "multiply",
    "-": "minus",
    "%": "precent",
    ">": "larger",
    ">=": "largerOrEqual",
    "<": "smaller",
    "<=": "smallerOrEqual",
    "!=": "notEqual",
    "==": "equal",
    "/": "divide",
    "^": "xor",
    "!": "not",
  };

  return items.entries
      .map((e) => <String, dynamic>{
            'value': e.key,
            'doc': e.value["doc"],
            'docSplit': buildDocLines(e.value["doc"], 70)
                .map((s) => {"part": s})
                .toList(),
            'valueAsCamelCase': new ReCase(renamed[e.key] ?? e.key).camelCase
          })
      .toList();
}
