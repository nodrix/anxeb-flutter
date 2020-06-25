import 'dart:async';

import 'package:anxeb_flutter/misc/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class Model<T> {
  Data _data;
  String _pk;
  String _diskKey;
  SharedPreferences _shared;
  List<_ModelField> _fields;
  String _primaryField;

  Model([data]) {
    if (data is String) {
      _pk = data;
      _data = Data();
    } else {
      _data = data != null ? (data is Data ? data : Data(data)) : Data();
    }
    _init(forcePush: data != null);
  }

  Model.fromDisk(String diskKey, ModelLoadedCallback<T> callback) {
    _diskKey = diskKey;
    _init(callback: callback);
  }

  @protected
  void init() {}

  Future<T> loadFromDisk(String key) {
    var promise = new Completer<T>();
    _diskKey = key;
    _init(callback: (data) {
      promise.complete(data);
    });
    return promise.future;
  }

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

    _initializeFields();
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
      field.pushToFields();
    }
  }

  void _initializeFields() {
    for (var field in _fields) {
      field.initialize();
    }
  }

  void _pushFieldsToData() {
    for (var field in _fields) {
      field.pushToData();
    }
  }

  void field(dynamic Function() getValue, Function(dynamic value) setValue, String fieldName, {bool primary, dynamic Function() defect, dynamic Function(dynamic raw) instance}) {
    if (primary == true) {
      _primaryField = fieldName;
    }
    _fields.add(_ModelField(
      data: data,
      getValue: getValue,
      setValue: setValue,
      fieldName: fieldName,
      primary: primary,
      defect: defect,
      instance: instance,
      pk: primary == true ? _pk : null,
    ));
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

  @protected
  bool has(String dataField) {
    return _data[dataField] != null;
  }

  dynamic toValue() {
    _pushFieldsToData();
    return _primaryField != null ? _data[_primaryField] : _data.toObjects();
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
  final Data data;
  final dynamic Function() getValue;
  final Function(dynamic value) setValue;
  final String fieldName;
  final bool primary;
  final dynamic Function() defect;
  final dynamic Function(dynamic raw) instance;
  final dynamic pk;

  _ModelField({this.data, this.getValue, this.setValue, this.fieldName, this.primary, this.defect, this.instance, this.pk});

  void initialize() {
    if (pk != null) {
      setValue(pk);
    } else if (defect != null) {
      setValue(defect());
    }
  }

  void pushToFields() {
    var $rawValue = data[fieldName];
    var $defValue = defect != null ? defect() : null;

    if (instance != null) {
      if ($rawValue != null && $rawValue is Iterable) {
        setValue(data.list((item) => instance(item), field: fieldName));
      } else {
        var $insValue = instance($rawValue);
        if ($defValue is Iterable) {
          setValue($defValue ?? ($insValue is Iterable ? $insValue : null));
        } else {
          setValue($insValue ?? $defValue);
        }
      }
    } else {
      setValue($rawValue ?? $defValue);
    }
  }

  void pushToData() {
    var propertyValue = getValue();
    if (propertyValue is Model) {
      data[fieldName] = propertyValue.toValue();
    } else {
      data[fieldName] = propertyValue;
    }
  }
}
