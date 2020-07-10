import 'dart:io';
import 'package:device_info/device_info.dart';

class Device {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getModelName() async {
    if (Platform.isAndroid) {
      var androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } else {
      var iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
  }
}
