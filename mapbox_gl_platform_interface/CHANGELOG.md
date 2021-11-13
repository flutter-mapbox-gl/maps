## 0.14.0, November 13, 2021
* Remove memory leaks by disposing internal components [#706](https://github.com/tobrun/flutter-mapbox-gl/pull/706) 
* Add support for Layers, properties and expressions backed by GeoJsonSource [#723](https://github.com/tobrun/flutter-mapbox-gl/pull/723)
* Add attribution button gravity, position normally [#731](https://github.com/tobrun/flutter-mapbox-gl/pull/731)
* Remove MapboxGlPlatform.getInstance [#710](https://github.com/tobrun/flutter-mapbox-gl/pull/710)

## 0.13.0, October 21, 2021
* Migrate to null-safety [#607](https://github.com/tobrun/flutter-mapbox-gl/pull/607)
* Support override of attribution click action (iOS) [#605](https://github.com/tobrun/flutter-mapbox-gl/pull/605)
* Fix requestMyLocationLatLng in the platform interface [#697](https://github.com/tobrun/flutter-mapbox-gl/pull/697)

## 0.12.0, April 12, 2021
* Batch creation/removal for circles, fills and lines [#576](https://github.com/tobrun/flutter-mapbox-gl/pull/576)

## 0.11.0, March 30, 2021
* Add batch mode of screen locations [#554](https://github.com/tobrun/flutter-mapbox-gl/pull/554)

## 0.10.0, February 12, 2021
* Added web support for fills [#501](https://github.com/tobrun/flutter-mapbox-gl/pull/501)
* Add heading to UserLocation and expose UserLocation type [#522](https://github.com/tobrun/flutter-mapbox-gl/pull/522)
* Update tracked camera position in camera#onIdle [#500](https://github.com/tobrun/flutter-mapbox-gl/pull/500)
* Improved Image Source Support [#469](https://github.com/tobrun/flutter-mapbox-gl/pull/469)

## 0.9.0,  October 24, 2020
* Breaking change: CameraUpdate.newLatLngBounds() now supports setting different padding values for left, top, right, bottom with default of 0 for all. Implementations using the old approach with only one padding value for all edges have to be updated. [#382](https://github.com/tobrun/flutter-mapbox-gl/pull/382)
* Add methods to access projection [#380](https://github.com/tobrun/flutter-mapbox-gl/pull/380)
* Add fill API support for Android and iOS [#49](https://github.com/tobrun/flutter-mapbox-gl/pull/49)
* Listen to OnUserLocationUpdated to provide user location to app [#237](https://github.com/tobrun/flutter-mapbox-gl/pull/237)
* Add support for custom font stackn in symbol options [#359](https://github.com/tobrun/flutter-mapbox-gl/pull/359)
* Basic ImageSource Support [#409](https://github.com/tobrun/flutter-mapbox-gl/pull/409)
* Get meters per pixel at latitude [#416](https://github.com/tobrun/flutter-mapbox-gl/pull/416)

## 0.8.0, August 22, 2020
- implementation of feature querying [#177](https://github.com/tobrun/flutter-mapbox-gl/pull/177)
- Batch create/delete of symbols [#279](https://github.com/tobrun/flutter-mapbox-gl/pull/279)
- Add multi map support [#315](https://github.com/tobrun/flutter-mapbox-gl/pull/315)
- Add line#getGeometry and symbol#getGeometry [#281](https://github.com/tobrun/flutter-mapbox-gl/pull/281)

## 0.7.0
- Initial version
