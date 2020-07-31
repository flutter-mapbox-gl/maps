part of mapbox_gl_platform_interface;

class DirectionsResponse {
  DirectionsResponse({
    this.routes,
    this.waypoints,
    this.code,
    this.uuid,
  });

  final List<DirectionsRoute> routes;
  final List<DirectionsWaypoint> waypoints;
  final String code;
  final String uuid;

  DirectionsResponse copyWith({
    List<DirectionsRoute> routes,
    List<DirectionsWaypoint> waypoints,
    String code,
    String uuid,
  }) =>
      DirectionsResponse(
        routes: routes ?? this.routes,
        waypoints: waypoints ?? this.waypoints,
        code: code ?? this.code,
        uuid: uuid ?? this.uuid,
      );

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) => DirectionsResponse(
    routes: List<DirectionsRoute>.from(json["routes"].map((x) => DirectionsRoute.fromJson(x))),
    waypoints: List<DirectionsWaypoint>.from(json["waypoints"].map((x) => DirectionsWaypoint.fromJson(x))),
    code: json["code"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
    "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
    "code": code,
    "uuid": uuid,
  };
}

class DirectionsWaypoint {
  DirectionsWaypoint({
    this.distance,
    this.name,
    this.location,
  });

  final double distance;
  final String name;
  final List<double> location;

  DirectionsWaypoint copyWith({
    double distance,
    String name,
    List<double> location,
  }) =>
      DirectionsWaypoint(
        distance: distance ?? this.distance,
        name: name ?? this.name,
        location: location ?? this.location,
      );

  factory DirectionsWaypoint.fromJson(Map<String, dynamic> json) => DirectionsWaypoint(
    distance: json["distance"]?.toDouble(),
    name: json["name"],
    location: List<double>.from(json["location"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "name": name,
    "location": List<dynamic>.from(location.map((x) => x)),
  };
}
