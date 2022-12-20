import 'dart:async';

import 'package:flutter/services.dart';

import 'middleware/window_manager.dart';

class AndroidMiddleware {
  static const MethodChannel _channel = const MethodChannel('android_middleware');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static AndroidWindowManager get windowManager {
    return AndroidWindowManager(_channel);
  }
}
