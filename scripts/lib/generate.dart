import 'dart:io';
import 'dart:convert';

import 'package:mustache_template/mustache_template.dart';
import 'package:recase/recase.dart';

main() async {
  var styleJson =
      jsonDecode(await new File('scripts/input/style.json').readAsString());

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

  // required for deduplication
  renderContext["all_layout_properties"] = [
    for (final type in renderContext["layerTypes"]!)
      ...type["layout_properties"].map((p) => p["value"]).toList()
  ].toSet().map((p) => {"property": p}).toList();

  await render(
    renderContext,
    "android/src/main/java/com/mapbox/mapboxgl",
    "LayerPropertyConverter.java",
  );
  await render(
    renderContext,
    "ios/Classes",
    "LayerPropertyConverter.swift",
  );
  await render(
    renderContext,
    "lib/src",
    "layer_expressions.dart",
  );
  await render(
    renderContext,
    "lib/src",
    "layer_properties.dart",
  );
  await render(
    renderContext,
    "mapbox_gl_web/lib/src",
    "layer_tools.dart",
  );
}

Future<void> render(
  Map<String, List> renderContext,
  String outputPath,
  String filename,
) async {
  print("Rendering $filename");
  var templateFile =
      await File('./scripts/templates/$filename.template').readAsString();

  var template = Template(templateFile);
  var outputFile = File('$outputPath/$filename');

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
    'docSplit': buildDocSplit(value).map((s) => {"part": s}).toList(),
    'valueAsCamelCase': camelCase
  };
}

List<String> buildDocSplit(Map<String, dynamic> item) {
  final defaultValue = item["default"];
  final maxValue = item["maximum"];
  final minValue = item["minimum"];
  final type = item["type"];
  final Map<dynamic, dynamic>? sdkSupport = item["sdk-support"];

  final Map<String, dynamic>? values = item["values"];
  final result = splitIntoChunks(item["doc"]!, 70);
  if (type != null) {
    result.add("");
    result.add("Type: $type");
    if (defaultValue != null) result.add("  default: $defaultValue");
    if (minValue != null) result.add("  minimum: $minValue");
    if (maxValue != null) result.add("  maximum: $maxValue");
    if (values != null) {
      result.add("Options:");
      for (var value in values.entries) {
        result.add("  \"${value.key}\"");
        result.addAll(
            splitIntoChunks("${value.value["doc"]}", 70, prefix: "     "));
      }
    }
  }
  if (sdkSupport != null) {
    final Map<String, dynamic>? basic = sdkSupport["basic functionality"];
    final Map<String, dynamic>? dataDriven = sdkSupport["data-driven styling"];

    result.add("");
    result.add("Sdk Support:");
    if (basic != null && basic.isNotEmpty) {
      result.add("  basic functionality with " + basic.keys.join(", "));
    }
    if (dataDriven != null && dataDriven.isNotEmpty) {
      result.add("  data-driven styling with " + dataDriven.keys.join(", "));
    }
  }

  return result;
}

List<String> splitIntoChunks(String input, int lineLength,
    {String prefix = ""}) {
  final words = input.split(" ");
  final chunks = <String>[];

  String chunk = "";
  for (var word in words) {
    final nextChunk = chunk.length == 0 ? prefix + word : chunk + " " + word;
    if (nextChunk.length > lineLength || chunk.endsWith("\n")) {
      chunks.add(chunk.replaceAll("\n", ""));
      chunk = prefix + word;
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
            'docSplit': buildDocSplit(e.value).map((s) => {"part": s}).toList(),
            'valueAsCamelCase': new ReCase(renamed[e.key] ?? e.key).camelCase
          })
      .toList();
}
