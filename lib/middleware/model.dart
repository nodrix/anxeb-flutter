import 'dart:async';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'helper.dart';
import 'scope.dart';

class Model<T> {
  Data _data;
  dynamic _pk;
  String _diskKey;
  SharedPreferences _shared;
  List<_ModelField> _fields;
  String _primaryField;

  Model([data]) {
    update(data);
  }

  Model.fromDisk(String diskKey, ModelLoadedCallback<T> callback) {
    _diskKey = diskKey;
    _init(callback: callback);
  }

  @protected
  void init() {}

  @protected
  void assign() {}

  Future _init({ModelLoadedCallback<T> callback, bool forcePush}) async {
    try {
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
      assign();
      if (callback != null) {
        callback(this as T);
      }
    } catch (err) {
      print(err);
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

  void _pushFieldsToData({bool usePrimaryKeys}) {
    for (var field in _fields) {
      try {
        field.pushToData(usePrimaryKeys: usePrimaryKeys);
      } catch (err) {
        throw Exception('Error pusing field \'${field.fieldName}\' to data. ${err.message}');
      }
    }
  }

  void update([data]) {
    if (data is String || data is int) {
      _pk = data;
      _data = Data();
    } else {
      _data = data != null ? (data is Data ? data : Data(data)) : Data();
    }
    _init(forcePush: data != null);
  }

  Future<T> loadFromDisk(String key) {
    var promise = new Completer<T>();
    _diskKey = key;
    _init(callback: (data) {
      promise.complete(data);
    });
    return promise.future;
  }

  void field(dynamic Function() getValue, Function(dynamic value) setValue, String fieldName, {bool primary, dynamic Function() defect, dynamic Function(dynamic raw) instance, List<dynamic> enumValues}) {
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
      enumValues: enumValues,
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

  void $print({bool usePrimaryKeys}) {
    _pushFieldsToData(usePrimaryKeys: usePrimaryKeys);
    _data.$print();
  }

  dynamic toObjects({bool usePrimaryKeys}) {
    _pushFieldsToData(usePrimaryKeys: usePrimaryKeys);
    return _data.toObjects();
  }

  String toJson() {
    _pushFieldsToData();
    return _data.toJson();
  }

  dynamic get $pk => _primaryField != null ? toValue() : null;

  @protected
  Data get data {
    return _data;
  }
}

class HelpedModel<T, H extends ModelHelper> extends Model<T> {
  ModelHelper _helper;

  HelpedModel([data]) : super(data);

  HelpedModel.fromDisk(String diskKey, ModelLoadedCallback<T> callback) : super.fromDisk(diskKey, callback);

  @protected
  H helper(Scope scope) {
    return ModelHelper(scope: scope, model: this) as H;
  }

  H using(Scope scope, {bool reset}) {
    if (reset == true) {
      _helper = helper(scope);
    } else {
      _helper = _helper ?? helper(scope);
    }
    return _helper;
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
  final List<dynamic> enumValues;

  _ModelField({
    this.data,
    this.getValue,
    this.setValue,
    this.fieldName,
    this.primary,
    this.defect,
    this.instance,
    this.pk,
    this.enumValues,
  });

  void initialize() {
    if (pk != null) {
      setValue(pk);
    } else if (defect != null) {
      if (getValue() == null) {
        setValue(defect());
      }
    }
  }

  void pushToFields() {
    var $rawValue = data[fieldName];
    if (primary == true && $rawValue == null && fieldName == 'id') {
      $rawValue = data['_id'] ?? pk;
    }
    var $defValue = defect != null ? defect() : null;

    if (instance != null) {
      if ($rawValue != null && $rawValue is Iterable) {
        if ($defValue is List) {
          for (var item in $rawValue) {
            $defValue.add(instance(item));
          }
        }
        setValue($defValue);
      } else {
        var $insValue = instance($rawValue);
        if ($defValue is Iterable) {
          setValue($defValue ?? ($insValue is Iterable ? $insValue : null));
        } else {
          setValue($insValue ?? $defValue);
        }
      }
    } else {
      if (enumValues != null && $rawValue != null) {
        if ($rawValue is Iterable) {
          if ($defValue is List) {
            for (var item in $rawValue) {
              var eItem = enumValues.firstWhere(($enum) => $enum.toString().endsWith('.$item'), orElse: () => null);
              if (eItem != null) {
                $defValue.add(eItem);
              }
            }
          }
          setValue($defValue);
        } else {
          setValue(enumValues.firstWhere(($enum) => $enum.toString().endsWith('.${$rawValue}'), orElse: () => null) ?? $defValue);
        }
      } else {
        setValue($rawValue ?? $defValue);
      }
    }
  }

  void pushToData({bool usePrimaryKeys}) {
    var propertyValue = getValue();

    if (propertyValue is Model) {
      if (usePrimaryKeys == true) {
        data[fieldName] = propertyValue.toValue();
      } else {
        data[fieldName] = propertyValue.toObjects();
      }
    } else if (enumValues != null) {
      if (propertyValue == null) {
        data[fieldName] = null;
      } else if (propertyValue is List<Model>) {
        var items = List();
        for (var item in propertyValue) {
          items.add(item.toString().split('.')[1]);
        }
        data[fieldName] = items;
      } else {
        data[fieldName] = propertyValue.toString().split('.')[1];
      }
    } else if (propertyValue is List<Model>) {
      var items = List();
      for (var item in propertyValue) {
        if (usePrimaryKeys == true) {
          items.add(item.toValue());
        } else {
          items.add(item.toObjects());
        }
      }
      data[fieldName] = items;
    } else if (propertyValue is DateTime) {
      data[fieldName] = Utils.convert.fromDateToTick(propertyValue);
    } else {
      data[fieldName] = propertyValue;
    }
  }
}
