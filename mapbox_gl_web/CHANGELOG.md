## 0.13.0, October 21, 2021
* Migrate to null-safety [#607](https://github.com/tobrun/flutter-mapbox-gl/pull/607)
* Add missing removeLines removeCircles and removeFills [#622](https://github.com/tobrun/flutter-mapbox-gl/pull/622)
* Fix Warning: Operand of null-aware operation '!' has type 'Locale' which excludes null [#676](https://github.com/tobrun/flutter-mapbox-gl/pull/676)

## 0.12.0, April 12, 2021
* Dependencies: updated image package [#598](https://github.com/tobrun/flutter-mapbox-gl/pull/598)
* Fix feature manager on release build [#593](https://github.com/tobrun/flutter-mapbox-gl/pull/593)
* Emit onTap only for the feature above the others [#589](https://github.com/tobrun/flutter-mapbox-gl/pull/589)
* Add annotationOrder to web [#588](https://github.com/tobrun/flutter-mapbox-gl/pull/588)

## 0.11.0, March 30, 2021
* Fix Mapbox GL JS CSS embedding on web [#551](https://github.com/tobrun/flutter-mapbox-gl/pull/551)
* Add batch mode of screen locations [#554](https://github.com/tobrun/flutter-mapbox-gl/pull/554)

## 0.10.0, February 12, 2020
* Added web support for fills [#501](https://github.com/tobrun/flutter-mapbox-gl/pull/501)
* Add heading to UserLocation and expose UserLocation type [#522](https://github.com/tobrun/flutter-mapbox-gl/pull/522)
* Update tracked camera position in camera#onIdle [#500](https://github.com/tobrun/flutter-mapbox-gl/pull/500)
* Improved Image Source Support [#469](https://github.com/tobrun/flutter-mapbox-gl/pull/469)

## 0.9.0,  October 24. 2020
* Breaking change: CameraUpdate.newLatLngBounds() now supports setting different padding values for left, top, right, bottom with default of 0 for all. Implementations using the old approach with only one padding value for all edges have to be updated. [#382](https://github.com/tobrun/flutter-mapbox-gl/pull/382)
* web:ignore myLocationTrackingMode if myLocationEnabled is false [#363](https://github.com/tobrun/flutter-mapbox-gl/pull/363)
* Add methods to access projection [#380](https://github.com/tobrun/flutter-mapbox-gl/pull/380)
* Listen to OnUserLocationUpdated to provide user location to app [#237](https://github.com/tobrun/flutter-mapbox-gl/pull/237)
* Get meters per pixel at latitude [#416](https://github.com/tobrun/flutter-mapbox-gl/pull/416)

## 0.8.0, August 22, 2020
- implementation of feature querying [#177](https://github.com/tobrun/flutter-mapbox-gl/pull/177)
- Allow setting accesstoken in flutter [#321](https://github.com/tobrun/flutter-mapbox-gl/pull/321)
- Batch create/delete of symbols [#279](https://github.com/tobrun/flutter-mapbox-gl/pull/279)
- Set dependencies from git [#319](https://github.com/tobrun/flutter-mapbox-gl/pull/319)
- Add multi map support [#315](https://github.com/tobrun/flutter-mapbox-gl/pull/315)

## 0.7.0
- Initial version
