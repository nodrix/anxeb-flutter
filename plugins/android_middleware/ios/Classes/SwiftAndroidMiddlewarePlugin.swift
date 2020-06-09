import Flutter
import UIKit

public class SwiftAndroidMiddlewarePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "android_middleware", binaryMessenger: registrar.messenger())
    let instance = SwiftAndroidMiddlewarePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
       if (call.method == "getPlatformVersion") {
           result("iOS " + UIDevice.current.systemVersion)
       } else {
           result(true)
       }
  }
}
