import 'dart:async';
import 'package:flutter/services.dart';

class LockTaskManager {
  late MethodChannel _channel;

  LockTaskManager(MethodChannel channel) {
    _channel = channel;
  }

  Future<bool> startLockTask() async {
    final value = await _channel.invokeMethod<bool>('startLockTask') ?? false;
    return value;
  }

  Future<bool> stopLockTask() async {
    final value = await _channel.invokeMethod<bool>('stopLockTask') ?? false;
    return value;
  }

  Future<bool> isInLockTaskMode() async {
    final value = await _channel.invokeMethod<bool>('isInLockTaskMode') ?? false;
    return value;
  }

  Future<bool> setDeviceOwnerApp() async {
    final value = await _channel.invokeMethod<bool>('setDeviceOwnerApp') ?? false;
    return value;
  }

  Future<bool> clearDeviceOwnerApp() async {
    final value = await _channel.invokeMethod<bool>('clearDeviceOwnerApp') ?? false;
    return value;
  }

  Future<bool> openHomeSettings() async {
    final value = await _channel.invokeMethod<bool>('openHomeSettings') ?? false;
    return value;
  }

  Future<String?> getPackageName() async {
    final version = await _channel.invokeMethod<String>('getPackageName');
    return version;
  }
}
