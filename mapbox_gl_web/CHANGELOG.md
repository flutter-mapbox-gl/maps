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
