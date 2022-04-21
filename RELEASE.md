## Release

This document describes the steps needed to make a release:

### Update Changelog

For each supported library:
 - `mapbox_gl_platform_interface`
 - `mapbox_gl_web`
 - `flutter-mapbox-gl`

Update the changelog by listing the commits that occurred for that given library.
Starting with `flutter-mapbox-gl` allows you to capture them all and be more granular
when updating the other libraries. Once the CHANGELOG.md's are updated, make a PR
and merge to master.

### Release libraries

#### Release `mapbox_gl_platform_interface`

Update library version in `mapbox_gl_platform_interface/pubspec.yaml` and run `flutter pub publish`.

#### Release `mapbox_gl_web`

Update library version in `mapbox_gl_web/pubspec.yaml` in `mapbox_gl_platform_interface`,


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

and run `flutter pub publish` in `mapbox_gl_web`.

#### Release `flutter-mapbox-gl`

Update library version in `pubspec.yaml`, replace both web as platform interface conform to above and run `flutter pub publish` from root of project.

### Tag Release

Once the PR that updates version numbers is merged, create a release for that version number
with the contents of the root CHANGELOG.md.