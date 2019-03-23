# Flutter Mapbox GL Native

> **Please note that this project is community driven and is not an official Mapbox product.** We welcome [feedback](https://github.com/tobrun/flutter-mapbox-gl/issues) and contributions.

This Flutter plugin for [mapbox-gl-native](https://github.com/mapbox/mapbox-gl-native) enables
embedded interactive and customizable vector maps inside a Flutter widget by embedding Android and iOS views.

![screenshot.png](screenshot.png)

## Install
This project is available on [pub.dartlang](https://pub.dartlang.org/packages/mapbox_gl), follow the [instructions](https://flutter.dev/docs/development/packages-and-plugins/using-packages#adding-a-package-dependency-to-an-app) to integrate a package into your flutter application.

### Running example app

- Install [Flutter](https://flutter.io/get-started/) and validate its installation with `flutter doctor`
- Clone this repository with `git clone git@github.com:mapbox/flutter-mapbox-gl.git`
- Run the app with `cd flutter_mapbox/example && flutter run`

#### Mapbox Access Token

This project uses Mapbox vector tiles, which requires a Mapbox account and a Mapbox access token. Obtain a free access token on [your Mapbox account page](https://www.mapbox.com/account/access-tokens/).

##### Android
After you get the key, place it in project's Android directory:
- Add your access token to `$project_dir/example/android/app/src/values/developer-config.xml`

##### iOS
Add this lines to your Info.plist
```plist
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>MGLMapboxAccessToken</key>
<string>YOUR_TOKEN_HERE</string>
```


## Documentation

This README file currently houses all of the documentation for this Flutter project. Please visit [mapbox.com/android-docs](https://www.mapbox.com/android-docs/) if you'd like more information about the Mapbox Maps SDK for Android and [mapbox.com/ios-sdk](https://www.mapbox.com/ios-sdk/) for more information about the Mapbox Maps SDK for iOS.

## Getting Help

- **Need help with your code?**: Look for previous questions on the [#mapbox tag](https://stackoverflow.com/questions/tagged/mapbox+android) — or [ask a new question](https://stackoverflow.com/questions/tagged/mapbox+android).
- **Have a bug to report?** [Open an issue](https://github.com/tobrun/flutter-mapbox-gl/issues/new). If possible, include a full log and information which shows the issue.
- **Have a feature request?** [Open an issue](https://github.com/tobrun/flutter-mapbox-gl/issues/new). Tell us what the feature should do and why you want the feature.

## Sample code

[This repository's example library](https://github.com/tobrun/flutter-mapbox-gl/tree/master/example/lib) is currently the best place for you to find reference code for this project.

## Contributing

We welcome contributions to this repository!

If you're interested in helping build this Mapbox/Flutter integration, please read [the contribution guide](https://github.com/tobrun/flutter-mapbox-gl/blob/master/CONTRIBUTING.md) to learn how to get started.
