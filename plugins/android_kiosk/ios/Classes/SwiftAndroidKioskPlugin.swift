import Flutter
import UIKit

public class SwiftAndroidKioskPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "android_kiosk", binaryMessenger: registrar.messenger())
    let instance = SwiftAndroidKioskPlugin()
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
