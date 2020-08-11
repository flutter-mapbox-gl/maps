part of mapbox_gl_platform_interface;

class DirectionsRoute {
  DirectionsRoute({
    this.routeIndex,
    this.distance,
    this.duration,
    this.geometry,
    this.weight,
    this.weightName,
    this.legs,
    this.routeOptions,
    this.voiceLocale,
  });

  final String routeIndex;
  final double distance;
  final double duration;
  final String geometry;
  final double weight;
  final String weightName;
  final List<RouteLeg> legs;
  final RouteOptions routeOptions;
  final String voiceLocale;

  DirectionsRoute copyWith({
    String routeIndex,
    double distance,
    double duration,
    String geometry,
    double weight,
    String weightName,
    List<RouteLeg> legs,
    RouteOptions routeOptions,
    String voiceLocale,
  }) =>
      DirectionsRoute(
        routeIndex: routeIndex ?? this.routeIndex,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        geometry: geometry ?? this.geometry,
        weight: weight ?? this.weight,
        weightName: weightName ?? this.weightName,
        legs: legs ?? this.legs,
        routeOptions: routeOptions ?? this.routeOptions,
        voiceLocale: voiceLocale ?? this.voiceLocale,
      );

  factory DirectionsRoute.fromJson(Map<String, dynamic> json) => DirectionsRoute(
    routeIndex: json["routeIndex"],
    distance: json["distance"].toDouble(),
    duration: json["duration"].toDouble(),
    geometry: json["geometry"],
    weight: json["weight"].toDouble(),
    weightName: json["weight_name"],
    legs: List<RouteLeg>.from(json["legs"].map((x) => RouteLeg.fromJson(x))),
    routeOptions: RouteOptions.fromJson(json["routeOptions"]),
    voiceLocale: json["voiceLocale"],
  );

  Map<String, dynamic> toJson() => {
    "routeIndex": routeIndex,
    "distance": distance,
    "duration": duration,
    "geometry": geometry,
    "weight": weight,
    "weight_name": weightName,
    "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
    "routeOptions": routeOptions.toJson(),
    "voiceLocale": voiceLocale,
  };
}

class RouteLeg {
  RouteLeg({
    this.distance,
    this.duration,
    this.summary,
    this.steps,
    this.annotation,
  });

  final double distance;
  final double duration;
  final String summary;
  final List<LegStep> steps;
  final LegAnnotation annotation;

  RouteLeg copyWith({
    double distance,
    double duration,
    String summary,
    List<LegStep> steps,
    LegAnnotation annotation,
  }) =>
      RouteLeg(
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        summary: summary ?? this.summary,
        steps: steps ?? this.steps,
        annotation: annotation ?? this.annotation,
      );

  factory RouteLeg.fromJson(Map<String, dynamic> json) => RouteLeg(
    distance: json["distance"].toDouble(),
    duration: json["duration"].toDouble(),
    summary: json["summary"],
    steps: List<LegStep>.from(json["steps"].map((x) => LegStep.fromJson(x))),
    annotation: LegAnnotation.fromJson(json["annotation"]),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "duration": duration,
    "summary": summary,
    "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
    "annotation": annotation.toJson(),
  };
}

class LegAnnotation {
  LegAnnotation({
    this.congestion,
  });

  final List<Congestion> congestion;

  LegAnnotation copyWith({
    List<Congestion> congestion,
  }) =>
      LegAnnotation(
        congestion: congestion ?? this.congestion,
      );

  factory LegAnnotation.fromJson(Map<String, dynamic> json) => LegAnnotation(
    congestion: List<Congestion>.from(json["congestion"].map((x) => congestionValues.map[x])),
  );

  Map<String, dynamic> toJson() => {
    "congestion": List<dynamic>.from(congestion.map((x) => congestionValues.reverse[x])),
  };
}

enum Congestion { UNKNOWN }

final congestionValues = EnumValues({
  "unknown": Congestion.UNKNOWN
});

class LegStep {
  LegStep({
    this.distance,
    this.duration,
    this.geometry,
    this.name,
    this.mode,
    this.maneuver,
    this.voiceInstructions,
    this.bannerInstructions,
    this.drivingSide,
    this.weight,
    this.intersections,
  });

  final double distance;
  final double duration;
  final String geometry;
  final String name;
  final Profile mode;
  final Maneuver maneuver;
  final List<VoiceInstruction> voiceInstructions;
  final List<BannerInstruction> bannerInstructions;
  final String drivingSide;
  final double weight;
  final List<Intersection> intersections;

  LegStep copyWith({
    double distance,
    double duration,
    String geometry,
    String name,
    Profile mode,
    Maneuver maneuver,
    List<VoiceInstruction> voiceInstructions,
    List<BannerInstruction> bannerInstructions,
    String drivingSide,
    double weight,
    List<Intersection> intersections,
  }) =>
      LegStep(
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        geometry: geometry ?? this.geometry,
        name: name ?? this.name,
        mode: mode ?? this.mode,
        maneuver: maneuver ?? this.maneuver,
        voiceInstructions: voiceInstructions ?? this.voiceInstructions,
        bannerInstructions: bannerInstructions ?? this.bannerInstructions,
        drivingSide: drivingSide ?? this.drivingSide,
        weight: weight ?? this.weight,
        intersections: intersections ?? this.intersections,
      );

  factory LegStep.fromJson(Map<String, dynamic> json) => LegStep(
    distance: json["distance"].toDouble(),
    duration: json["duration"].toDouble(),
    geometry: json["geometry"],
    name: json["name"],
    mode: profileValues.map[json["mode"]],
    maneuver: Maneuver.fromJson(json["maneuver"]),
    voiceInstructions: json["voiceInstructions"] == null ? null : List<VoiceInstruction>.from(json["voiceInstructions"].map((x) => VoiceInstruction.fromJson(x))),
    bannerInstructions: json["bannerInstructions"] == null ? null : List<BannerInstruction>.from(json["bannerInstructions"].map((x) => BannerInstruction.fromJson(x))),
    drivingSide: json["driving_side"],
    weight: json["weight"].toDouble(),
    intersections: List<Intersection>.from(json["intersections"].map((x) => Intersection.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "duration": duration,
    "geometry": geometry,
    "name": name,
    "mode": profileValues.reverse[mode],
    "maneuver": maneuver.toJson(),
    "voiceInstructions": voiceInstructions == null ? null : List<dynamic>.from(voiceInstructions.map((x) => x.toJson())),
    "bannerInstructions": bannerInstructions == null ? null : List<dynamic>.from(bannerInstructions.map((x) => x.toJson())),
    "driving_side": drivingSide,
    "weight": weight,
    "intersections": List<dynamic>.from(intersections.map((x) => x.toJson())),
  };
}

class BannerInstruction {
  BannerInstruction({
    this.distanceAlongGeometry,
    this.primary,
    this.secondary,
    this.sub,
  });

  final double distanceAlongGeometry;
  final BannerText primary;
  final BannerText secondary;
  final BannerText sub;

  BannerInstruction copyWith({
    double distanceAlongGeometry,
    BannerText primary,
    BannerText secondary,
    BannerText sub,
  }) =>
      BannerInstruction(
        distanceAlongGeometry: distanceAlongGeometry ?? this.distanceAlongGeometry,
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        sub: sub ?? this.sub,
      );

  factory BannerInstruction.fromJson(Map<String, dynamic> json) => BannerInstruction(
    distanceAlongGeometry: json["distanceAlongGeometry"].toDouble(),
    primary: BannerText.fromJson(json["primary"]),
    secondary: json["secondary"] == null ? null : BannerText.fromJson(json["secondary"]),
    sub: json["sub"] == null ? null : BannerText.fromJson(json["sub"]),
  );

  Map<String, dynamic> toJson() => {
    "distanceAlongGeometry": distanceAlongGeometry,
    "primary": primary.toJson(),
    "secondary": secondary == null ? null : secondary.toJson(),
    "sub": sub == null ? null : sub.toJson(),
  };
}

class BannerText {
  BannerText({
    this.text,
    this.components,
    this.type,
    this.modifier,
  });

  final String text;
  final List<Component> components;
  final String type;
  final String modifier;

  BannerText copyWith({
    String text,
    List<Component> components,
    String type,
    String modifier,
  }) =>
      BannerText(
        text: text ?? this.text,
        components: components ?? this.components,
        type: type ?? this.type,
        modifier: modifier ?? this.modifier,
      );

  factory BannerText.fromJson(Map<String, dynamic> json) => BannerText(
    text: json["text"] ?? "",
    components: List<Component>.from(json["components"].map((x) => Component.fromJson(x))),
    type: json["type"] ?? "",
    modifier: json["modifier"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "components": List<dynamic>.from(components.map((x) => x.toJson())),
    "type": type,
    "modifier": modifier,
  };
}

class Component {
  Component({
    this.text,
    this.type,
  });

  final String text;
  final String type;

  Component copyWith({
    String text,
    String type,
  }) =>
      Component(
        text: text ?? this.text,
        type: type ?? this.type,
      );

  factory Component.fromJson(Map<String, dynamic> json) => Component(
    text: json["text"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "type": type,
  };
}

class Intersection {
  Intersection({
    this.location,
    this.bearings,
    this.entry,
    this.out,
    this.intersectionIn,
    this.lanes,
  });

  final List<double> location;
  final List<int> bearings;
  final List<bool> entry;
  final int out;
  final int intersectionIn;
  final List<Lane> lanes;

  Intersection copyWith({
    List<double> location,
    List<int> bearings,
    List<bool> entry,
    int out,
    int intersectionIn,
    List<Lane> lanes,
  }) =>
      Intersection(
        location: location ?? this.location,
        bearings: bearings ?? this.bearings,
        entry: entry ?? this.entry,
        out: out ?? this.out,
        intersectionIn: intersectionIn ?? this.intersectionIn,
        lanes: lanes ?? this.lanes,
      );

  factory Intersection.fromJson(Map<String, dynamic> json) => Intersection(
    location: List<double>.from(json["location"].map((x) => x.toDouble())),
    bearings: List<int>.from(json["bearings"].map((x) => x)),
    entry: List<bool>.from(json["entry"].map((x) => x)),
    out: json["out"] == null ? null : json["out"],
    intersectionIn: json["in"] == null ? null : json["in"],
    lanes: json["lanes"] == null ? null : List<Lane>.from(json["lanes"].map((x) => Lane.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "location": List<dynamic>.from(location.map((x) => x)),
    "bearings": List<dynamic>.from(bearings.map((x) => x)),
    "entry": List<dynamic>.from(entry.map((x) => x)),
    "out": out == null ? null : out,
    "in": intersectionIn == null ? null : intersectionIn,
    "lanes": lanes == null ? null : List<dynamic>.from(lanes.map((x) => x.toJson())),
  };
}

class Lane {
  Lane({
    this.valid,
    this.indications,
  });

  final bool valid;
  final List<String> indications;

  Lane copyWith({
    bool valid,
    List<String> indications,
  }) =>
      Lane(
        valid: valid ?? this.valid,
        indications: indications ?? this.indications,
      );

  factory Lane.fromJson(Map<String, dynamic> json) => Lane(
    valid: json["valid"],
    indications: List<String>.from(json["indications"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "valid": valid,
    "indications": List<dynamic>.from(indications.map((x) => x)),
  };
}

class Maneuver {
  Maneuver({
    this.location,
    this.bearingBefore,
    this.bearingAfter,
    this.instruction,
    this.type,
    this.modifier,
  });

  final List<double> location;
  final double bearingBefore;
  final double bearingAfter;
  final String instruction;
  final String type;
  final String modifier;

  Maneuver copyWith({
    List<double> location,
    double bearingBefore,
    double bearingAfter,
    String instruction,
    String type,
    String modifier,
  }) =>
      Maneuver(
        location: location ?? this.location,
        bearingBefore: bearingBefore ?? this.bearingBefore,
        bearingAfter: bearingAfter ?? this.bearingAfter,
        instruction: instruction ?? this.instruction,
        type: type ?? this.type,
        modifier: modifier ?? this.modifier,
      );

  factory Maneuver.fromJson(Map<String, dynamic> json) => Maneuver(
    location: List<double>.from(json["location"].map((x) => x.toDouble())),
    bearingBefore: json["bearing_before"],
    bearingAfter: json["bearing_after"],
    instruction: json["instruction"],
    type: json["type"],
    modifier: json["modifier"] == null ? null : json["modifier"],
  );

  Map<String, dynamic> toJson() => {
    "location": List<dynamic>.from(location.map((x) => x)),
    "bearing_before": bearingBefore,
    "bearing_after": bearingAfter,
    "instruction": instruction,
    "type": type,
    "modifier": modifier == null ? null : modifier,
  };
}

enum Profile { DRIVING }

final profileValues = EnumValues({
  "driving": Profile.DRIVING
});

class VoiceInstruction {
  VoiceInstruction({
    this.distanceAlongGeometry,
    this.announcement,
    this.ssmlAnnouncement,
  });

  final double distanceAlongGeometry;
  final String announcement;
  final String ssmlAnnouncement;

  VoiceInstruction copyWith({
    double distanceAlongGeometry,
    String announcement,
    String ssmlAnnouncement,
  }) =>
      VoiceInstruction(
        distanceAlongGeometry: distanceAlongGeometry ?? this.distanceAlongGeometry,
        announcement: announcement ?? this.announcement,
        ssmlAnnouncement: ssmlAnnouncement ?? this.ssmlAnnouncement,
      );

  factory VoiceInstruction.fromJson(Map<String, dynamic> json) => VoiceInstruction(
    distanceAlongGeometry: json["distanceAlongGeometry"].toDouble(),
    announcement: json["announcement"],
    ssmlAnnouncement: json["ssmlAnnouncement"],
  );

  Map<String, dynamic> toJson() => {
    "distanceAlongGeometry": distanceAlongGeometry,
    "announcement": announcement,
    "ssmlAnnouncement": ssmlAnnouncement,
  };
}

class RouteOptions {
  RouteOptions({
    this.baseUrl,
    this.user,
    this.profile,
    this.coordinates,
    this.alternatives,
    this.language,
    this.geometries,
    this.overview,
    this.steps,
    this.annotations,
    this.voiceInstructions,
    this.bannerInstructions,
    this.voiceUnits,
    this.accessToken,
    this.uuid,
  });

  final String baseUrl;
  final String user;
  final Profile profile;
  final List<List<double>> coordinates;
  final bool alternatives;
  final String language;
  final String geometries;
  final String overview;
  final bool steps;
  final String annotations;
  final bool voiceInstructions;
  final bool bannerInstructions;
  final String voiceUnits;
  final String accessToken;
  final String uuid;

  RouteOptions copyWith({
    String baseUrl,
    String user,
    Profile profile,
    List<List<double>> coordinates,
    bool alternatives,
    String language,
    String geometries,
    String overview,
    bool steps,
    String annotations,
    bool voiceInstructions,
    bool bannerInstructions,
    String voiceUnits,
    String accessToken,
    String uuid,
  }) =>
      RouteOptions(
        baseUrl: baseUrl ?? this.baseUrl,
        user: user ?? this.user,
        profile: profile ?? this.profile,
        coordinates: coordinates ?? this.coordinates,
        alternatives: alternatives ?? this.alternatives,
        language: language ?? this.language,
        geometries: geometries ?? this.geometries,
        overview: overview ?? this.overview,
        steps: steps ?? this.steps,
        annotations: annotations ?? this.annotations,
        voiceInstructions: voiceInstructions ?? this.voiceInstructions,
        bannerInstructions: bannerInstructions ?? this.bannerInstructions,
        voiceUnits: voiceUnits ?? this.voiceUnits,
        accessToken: accessToken ?? this.accessToken,
        uuid: uuid ?? this.uuid,
      );

  factory RouteOptions.fromJson(Map<String, dynamic> json) => RouteOptions(
    baseUrl: json["baseUrl"],
    user: json["user"],
    profile: profileValues.map[json["profile"]],
    coordinates: List<List<double>>.from(json["coordinates"].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
    alternatives: json["alternatives"],
    language: json["language"],
    geometries: json["geometries"],
    overview: json["overview"],
    steps: json["steps"],
    annotations: json["annotations"],
    voiceInstructions: json["voice_instructions"],
    bannerInstructions: json["banner_instructions"],
    voiceUnits: json["voice_units"],
    accessToken: json["access_token"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "baseUrl": baseUrl,
    "user": user,
    "profile": profileValues.reverse[profile],
    "coordinates": List<dynamic>.from(coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
    "alternatives": alternatives,
    "language": language,
    "geometries": geometries,
    "overview": overview,
    "steps": steps,
    "annotations": annotations,
    "voice_instructions": voiceInstructions,
    "banner_instructions": bannerInstructions,
    "voice_units": voiceUnits,
    "access_token": accessToken,
    "uuid": uuid,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
