#import "Swizzles.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSDictionary* _Nullable _headers = nil;
static NSArray* _Nullable _filter = nil;
static NSDictionary* _Nullable _usedHeaders = nil;
 
@implementation NSURLRequest (HttpHeaders)

+ (void) registerSwizzling {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Swizzle: registering NSURLRequest.requestWithURL override");

        Class targetClass = [NSURLRequest class];
        Method oldMethod = class_getClassMethod(targetClass, @selector(requestWithURL:));
        Method newMethod = class_getClassMethod(targetClass, @selector(__swizzle_requestWithURL:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

+ (NSURLRequest*) __swizzle_requestWithURL:(NSURL*)url {
    NSLog(@"Swizzle: calling override for NSURLRequest.requestWithURL");

    NSMutableURLRequest* req = (NSMutableURLRequest *)[NSMutableURLRequest __swizzle_requestWithURL:url];
    NSArray<NSString*>* stack = [NSThread callStackSymbols];
    if(![url.scheme isEqualToString:@"ws"] && [stack count] >= 2 && [stack[1] containsString:@"Mapbox"] == YES) {
        NSDictionary<NSString*,NSString*>* headers = _headers;
        NSArray<NSString*>* filter = _filter;
        if (_headers != nil) {       
            if (_filter != nil) {
                for (NSString* pattern in filter) {
                    if ([url.absoluteString containsString:pattern] == YES) {
                        for (NSString* key in headers) {
                            [req setValue: headers[key] forHTTPHeaderField:key];
                        }
                        _usedHeaders = headers;
                        return req;
                    }
                }        
            } else {
                for (NSString* key in headers) {
                    [req setValue: headers[key] forHTTPHeaderField:key];
                }
                _usedHeaders = headers;
            }
        }
    }

    return req;
}

+ (void) setHttpHeaders:(NSDictionary<NSString*,NSString*>* _Nullable)headers forFilter:(NSArray<NSString*>* _Nullable) filter {
    _headers = headers;
    _filter = filter;
}

+ (NSDictionary<NSString*,NSString*> *) getHttpHeaders {
    return _usedHeaders;
}

@end
