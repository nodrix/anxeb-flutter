import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class Disk {
  SharedPreferences _shared;
  
  Future store(String key, value) async {
    await _check();
    if (value is double) {
      await _shared?.setDouble(key, value);
    } else if (value is String) {
      await _shared?.setString(key, value);
    } else if (value is bool) {
      await _shared?.setBool(key, value);
    } else if (value is Data) {
      await _shared?.setString(key, value.toJson());
    } else {
      await _shared?.setString(key, value.toString());
    }
  }

  Future<T> retrieve<T>(String key) async {
    await _check();
    var $value = _shared?.get(key);

    if (T is Data) {
      return Data($value as String) as T;
    } else {
      return $value as T;
    }
  }

  Future remove(String key) async {
    await _check();
    await _shared?.remove(key);
  }

  Future _check() async {
    if (_shared == null) {
      _shared = await SharedPreferences.getInstance();
    }
  }
}
