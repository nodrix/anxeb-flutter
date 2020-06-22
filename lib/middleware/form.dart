import 'package:flutter/material.dart';

import 'data.dart';
import 'field.dart';
import 'model.dart';
import 'scope.dart';

class FieldsForm {
  Map<String, FieldState> fields;
  Map<String, GlobalKey<FieldState>> _keys;
  dynamic _initialValues;
  bool validated;
  ValueChanged<bool> onValidationChanged;

  FieldsForm([dynamic initialValues]) {
    fields = Map();
    _keys = Map();
    validated = false;
    _initialValues = initialValues ?? {};
  }

  GlobalKey<FieldState> key(String name) {
    var $key = _keys[name];
    if ($key == null) {
      $key = GlobalKey<FieldState>();
      _keys[name] = $key;
    }
    return $key;
  }

  void update([dynamic data]) {
    validated = false;

    if (data is Model) {
      _initialValues = data.toObjects();
    } else if (data is Data) {
      _initialValues = data.toObjects();
    } else {
      _initialValues = data ?? {};
    }

    for (var field in fields.values) {
      field.value = _initialValues[field.widget.name];
    }
  }

  void focusNextInvalid() {
    for (var i = 0; i <= fields.length; i++) {
      var exit = false;

      for (var field in fields.values) {
        if (field.index == i) {
          if (!field.valid() && field.context != null) {
            field.focus();
            exit = true;
            return;
          }
        }
      }
      if (exit) {
        break;
      }
    }
  }

  void remove(String name) {
    fields.remove(name);
  }

  void clear(String name) {
    var field = fields[name];
    field.reset();
  }

  bool focusFrom(int index) {
    for (var field in fields.values) {
      if (field.index == index + 1) {
        if (field.isEmpty) {
          field.focus();
          return true;
        }
        break;
      }
    }
    return false;
  }

  bool focus(String name, {bool force, String warning}) {
    var field = fields[name];

    if (field != null) {
      if (force == true || field.value == null) {
        field.focus(warning: warning);
        return true;
      }
    }
    return false;
  }

  bool select(String name) {
    var field = fields[name];

    if (field != null) {
      field.select();
      return true;
    }
    return false;
  }

  void include(FieldState current) {
    var $field = fields[current.widget.name];
    if ($field != null) {
      current.value = $field.value;
    } else {
      current.index = fields.length;
      if (_initialValues != null) {
        current.value = _initialValues[current.widget.name];
      }
    }
    fields[current.widget.name] = current;
  }

  bool validate({bool showMessage}) {
    var result = true;
    for (var field in fields.values) {
      if (field.context != null && field.validate(showMessage: showMessage) != null) {
        field.focus();
        result = false;
        break;
      }
    }
    if (validated != result) {
      validated = result;
      if (onValidationChanged != null) {
        onValidationChanged(validated);
      }
    }
    return result;
  }

  bool valid() {
    return validate();
  }

  Map<String, dynamic> data() {
    if (validate()) {
      var data = Map<String, dynamic>();

      for (var field in fields.values) {
        if (field.widget.visible != false) {
          data[field.widget.name] = field.data();
        }
      }
      return data;
    } else {
      return null;
    }
  }

  bool noneFocused() {
    for (MapEntry<String, FieldState> item in fields.entries) {
      if (item.value.focused == true) {
        return false;
      }
    }
    return true;
  }
}

class ScopeForms {
  Scope _scope;
  Map<String, FieldsForm> _forms;

  ScopeForms(Scope scope) {
    _scope = scope;
    _forms = Map<String, FieldsForm>();
  }

  bool validate(String name) {
    return _retrieve(name).validate();
  }

  bool valid() {
    for (var $form in _forms.values) {
      if ($form.valid() == false) {
        return false;
      }
    }
    return true;
  }

  void focusNextInvalid(String name) {
    _retrieve(name).focusNextInvalid();
  }

  bool noneFocused() {
    for (var $form in _forms.values) {
      for (var item in $form.fields.entries) {
        if (item.value.focused == true) {
          return false;
        }
      }
    }
    return true;
  }

  Data data() {
    var _data = Data();
    for (var $form in _forms.values) {
      var $data = $form.data();
      if ($data != null) {
        _data.include($data);
      }
    }
    return _data;
  }

  FieldsForm _retrieve(String name) {
    var $form = _forms[name ?? _scope.view.name];
    if ($form == null) {
      $form = FieldsForm();
      _forms[name] = $form;
    }
    return $form;
  }

  FieldsForm get current => _retrieve(_scope.view.name);

  dynamic operator [](name) => _retrieve(name);

  key(String name, String field) {
    var $form = _retrieve(name);
    return $form.key(field);
  }
}
