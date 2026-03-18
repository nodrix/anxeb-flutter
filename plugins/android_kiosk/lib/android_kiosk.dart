import 'package:flutter/services.dart';
import 'middleware/lock_task_manager.dart';

class AndroidKiosk {
  static const MethodChannel _channel = const MethodChannel('android_kiosk');

  static LockTaskManager get locker {
    return LockTaskManager(_channel);
  }
}
