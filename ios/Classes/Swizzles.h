#import <Foundation/Foundation.h>
#import <Mapbox/MGLMapView.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (HttpHeaders)
+ (void) registerSwizzling;
+ (void) setHttpHeaders:(NSDictionary<NSString*,NSString*>* _Nullable)headers forFilter:(NSArray<NSString*>* _Nullable)filter;
+ (NSDictionary<NSString*,NSString*>* _Nullable) getHttpHeaders;
@end

NS_ASSUME_NONNULL_END
