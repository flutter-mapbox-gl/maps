part of mapbox_gl;

Map<String, dynamic> buildFeatureCollection(
    List<Map<String, dynamic>> features) {
  return {"type": "FeatureCollection", "features": features};
}

final _random = Random();
String getRandomString([int length = 10]) {
  const charSet =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return String.fromCharCodes(Iterable.generate(
      length, (_) => charSet.codeUnitAt(_random.nextInt(charSet.length))));
}
