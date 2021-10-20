import 'dart:io';
import 'dart:convert';

import 'package:mustache_template/mustache_template.dart';
import 'package:recase/recase.dart';

main() async {
  var styleJson =
      jsonDecode(await new File('./scripts/input/style.json').readAsString());

  final renderContext = {
    "layerTypes": [
      for (var type in ["symbol", "circle", "line", "fill"])
        {
          "type": type,
          "typePascal": ReCase(type).pascalCase,
          "properties": buildStyleProperties(styleJson, "layout_$type") +
              buildStyleProperties(styleJson, "paint_$type")
        },
    ],
    'expressions': buildExpressionProperties(styleJson)
  };

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
}

Future<void> renderLayerPropertyConverter(Map<String, dynamic> renderContext,
    String templateType, String outputPath) async {
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

List<Map<String, String>> buildStyleProperties(
    Map<String, dynamic> styleJson, String key) {
  final Map<String, dynamic> items = styleJson[key];

  return items.keys
      .map((f) => <String, String>{
            'value': f,
            'valueAsCamelCase': new ReCase(f).camelCase
          })
      .toList();
}

List<Map<String, String>> buildExpressionProperties(
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

  return items.keys
      .map((f) => <String, String>{
            'value': f,
            'valueAsCamelCase': new ReCase(renamed[f] ?? f).camelCase
          })
      .toList();
}
