## Release

This document describes the steps needed to make a release:

For each supported library:
 - `mapbox_gl_platform_interface`
 - `mapbox_gl_web`
 - `flutter-mapbox-gl`

Perform the following actions:
 - Update `CHANGELOG.md` with the commits associated since previous release.
 - Update library version in `pubspec.yaml`

Publish `mapbox_gl_platform_interface`, `mapbox_gl_web` and `flutter-mapbox-gl` after eachother with:
 - `flutter pub publish`

Before publishgin in `mapbox_gl_web` update the version of the `mapbox_gl_platform_interface`
Repeat this action for `flutter-mapbox-gl` for both dependencies:

```
Replace:
mapbox_gl_platform_interface:
  git:
    url: https://github.com/tobrun/flutter-mapbox-gl.git
    path: mapbox_gl_platform_interface

With:
mapbox_gl_platform_interface: ^0.10.0

Remove:
dependency_overrides:
  mapbox_gl_platform_interface:
    path: ../mapbox_gl_platform_interface
```

Before being able to publish `flutter-mapbox-gl`, you will have to PR and merge changelog changes.