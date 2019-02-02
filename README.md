# Flutter Mapbox GL Native

> **Please note that this project is community driven and is not an official Mapbox supported product.** We welcome [feedback](https://github.com/tobrun/flutter-mapbox-gl/issues) and contributions.

This Flutter plugin for [mapbox-gl-native](https://github.com/mapbox/mapbox-gl-native) enables
embedded interactive and customizable vector maps inside of a Flutter widget. This project plugin is in early development stage. Only Android is supported for now.
the plugin relies on Flutter's new mechanism for embedding Android and iOS views.

![screenshot.png](screenshot.png)

## Getting Started

### Android

Following examples use Mapbox vector tiles, which require a Mapbox account and a Mapbox access token. Obtain a free access token on [your Mapbox account page](https://www.mapbox.com/account/access-tokens/). After you get the key, place it in project's Android directory:
- Add your access token to `$project_dir/example/android/app/src/values/developer-config.xml`

#### Demo app

- Install [Flutter](https://flutter.io/get-started/) and validate its installation with `flutter doctor`
- Clone this repository with `git clone git@github.com:mapbox/flutter-mapbox-gl.git`
- Run the app with `cd flutter_mapbox/example && flutter run`

#### New project

- Create new Flutter project in your IDE or via terminal
- Add `mapbox_gl: ^0.0.1` dependency to `pubspec.yaml` file and [get the package](https://flutter.io/using-packages/#adding-a-package-dependency-to-an-app)
- Add Mapbox read token value in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.mapbox.token" android:value="YOUR_TOKEN_HERE" />
```

- Import Mapbox widgets and add them to your widget tree
```
import 'package:mapbox_gl/mapbox_gl.dart';
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
