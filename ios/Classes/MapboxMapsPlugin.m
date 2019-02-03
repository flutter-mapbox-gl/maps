#import "MapboxMapsPlugin.h"
#import <mapbox_gl/mapbox_gl-Swift.h>

@implementation MapboxMapsPlugin 
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMapboxGlFlutterPlugin registerWithRegistrar:registrar];
}
@end
