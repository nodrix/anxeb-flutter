#import "AndroidKioskPlugin.h"
#if __has_include(<android_kiosk/android_kiosk-Swift.h>)
#import <android_kiosk/android_kiosk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "android_kiosk-Swift.h"
#endif

@implementation AndroidKioskPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAndroidKioskPlugin registerWithRegistrar:registrar];
}
@end
