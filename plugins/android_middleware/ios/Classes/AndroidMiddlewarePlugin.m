#import "AndroidMiddlewarePlugin.h"
#if __has_include(<android_middleware/android_middleware-Swift.h>)
#import <android_middleware/android_middleware-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "android_middleware-Swift.h"
#endif

@implementation AndroidMiddlewarePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAndroidMiddlewarePlugin registerWithRegistrar:registrar];
}
@end
