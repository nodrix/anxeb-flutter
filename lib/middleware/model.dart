import 'package:anxeb_flutter/misc/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class Model<T> {
  Data _data;
  String _diskKey;
  SharedPreferences _shared;
  List<_ModelField> _fields;

  Model([data]) {
    _data = data != null ? (data is Data ? data : Data(data)) : Data();
    _init(forcePush: data != null);
  }

  Model.fromDisk(String diskKey, ModelLoadedCallback<T> callback) {
    _diskKey = diskKey;
    _init(callback: callback);
  }

  @protected
  void init() {}

  Future _init({ModelLoadedCallback<T> callback, bool forcePush}) async {
    bool mustPush = false;
    if (_diskKey != null) {
      await _checkShared();
      var $data = await _shared?.get(_diskKey);
      if ($data != null) {
        _data = Data($data);
        mustPush = true;
      }
    }
    _data = _data ?? Data();
    _fields = List<_ModelField>();
    init();
    if (forcePush == true || mustPush == true) {
      _pushDataToFields();
    }
    if (callback != null) {
      callback(this as T);
    }
  }

  Future _checkShared() async {
    if (_shared == null) {
      _shared = await SharedPreferences.getInstance();
    }
  }

  void _pushDataToFields() {
    for (var field in _fields) {
      field.setValue(data[field.fieldName]);
    }
  }

  void _pushFieldsToData() {
    for (var field in _fields) {
      data[field.fieldName] = field.getValue();
    }
  }

  void field(dynamic Function() getValue, Function(dynamic value) setValue, String fieldName) {
    _fields.add(_ModelField(getValue, setValue, fieldName));
  }

  Future persist([String diskKey]) async {
    if (_diskKey != null || diskKey != null) {
      _pushFieldsToData();
      await _checkShared();
      await _shared?.setString(diskKey ?? _diskKey, _data.toJson());
    } else {
      throw Exception('Persistance can be done only to disk instances');
    }
  }

  dynamic toObjects() {
    _pushFieldsToData();
    return _data.toObjects();
  }

  String toJson() {
    _pushFieldsToData();
    return _data.toJson();
  }

  @protected
  Data get data {
    return _data;
  }
}

class _ModelField {
  final dynamic Function() getValue;
  final Function(dynamic value) setValue;
  final String fieldName;

  _ModelField(this.getValue, this.setValue, this.fieldName);
}
