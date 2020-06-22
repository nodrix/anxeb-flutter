import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:after_init/after_init.dart';

import 'form.dart';
import 'scope.dart';

class FieldWidget extends StatefulWidget {
  final Scope scope;
  final Key key;
  final String name;
  final String group;
  final String label;
  final IconData icon;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool readonly;
  final bool visible;
  final ValueChanged<dynamic> onSubmitted;
  final ValueChanged<dynamic> onValidSubmit;
  final GestureTapCallback onTab;
  final GestureTapCallback onBlur;
  final GestureTapCallback onFocus;
  final ValueChanged<dynamic> onChanged;
  final FormFieldValidator<String> validator;

  FieldWidget({
    this.scope,
    this.key,
    this.name,
    this.group,
    this.label,
    this.icon,
    this.margin,
    this.padding,
    this.readonly,
    this.visible,
    this.onSubmitted,
    this.onValidSubmit,
    this.onTab,
    this.onBlur,
    this.onFocus,
    this.onChanged,
    this.validator,
  })  : assert(scope != null && name != null),
        super(key: key ?? scope.forms.key(group ?? scope.view.name, name));

  @override
  Field createState() => Field();
}

abstract class FieldState<T extends FieldWidget> extends State<T> {
  int index;
  dynamic value;
  bool focused;

  bool isEmpty;

  void focus({String warning});

  void select();

  String validate({bool showMessage});

  bool valid();

  void reset();

  dynamic data();
}

class Field<T extends FieldWidget> extends FieldState<T> with AfterInitMixin<T> {
  dynamic _value;
  bool _focused = false;
  int index = 0;
  String _warning;

  @protected
  FocusNode focusNode;

  @protected
  dynamic data() {
    return value;
  }

  void rasterize() {
    if (mounted == true) {
      setState(() {});
    }
  }

  @protected
  void init() {}

  @protected
  void setup() => null;

  @override
  void didInitState() {
    setup();
  }

  @protected
  void focus({String warning}) {
    if (warning != null) {
      this.warning = warning;
    }
    FocusScope.of(this.context).requestFocus(focusNode);
  }

  @protected
  void select() {}

  void unfocus() {
    FocusScope.of(this.context).requestFocus(new FocusNode());
  }

  void reset() {
    setState(() {
      warning = null;
      value = null;
    });
  }

  String validate({bool showMessage}) {
    var $value;

    if (this.value is KeyValue) {
      $value = this.value.value;
    } else {
      $value = value;
    }

    var result = widget.visible != false && widget.validator != null ? widget.validator($value?.toString()) : null;

    if (showMessage != false) {
      warning = result;
    }
    return result;
  }

  bool valid() {
    return validate() == null;
  }

  @protected
  void submit(dynamic $value) {
    if (value != $value && widget.onChanged != null) {
      widget.onChanged($value);
    }
    value = $value;
    if (valid()) {
      if (!form.focusFrom(index)) {
        unfocus();
      }
      if (widget.onValidSubmit != null) {
        Future.delayed(new Duration(milliseconds: 150), () {
          widget.onValidSubmit(value);
        });
      }
    } else {
      focus();
    }
    if (widget.onSubmitted != null) {
      widget.onSubmitted(value);
    }
  }

  @protected
  void present() {}

  @override
  initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (mounted == true) {
        if (!focusNode.hasFocus) {
          if (isEmpty) {
            warning = null;
          }
          setState(() {
            _focused = false;
          });
          onBlur();
          if (widget.onBlur != null) {
            widget.onBlur();
          }
        } else {
          setState(() {
            _focused = true;
          });
          onFocus();
          if (widget.onFocus != null) {
            widget.onFocus();
          }
        }
      }
    });

    form.include(this);
    init();
    if (!mounted) return;
    rasterize();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    prebuild();
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: field(),
    );
  }

  @protected
  void prebuild() {}

  @protected
  void onFocus() {}

  @protected
  void onBlur() {}

  @protected
  Widget field() => Container();

  @protected
  String get warning => _warning;

  @protected
  set warning(value) {
    _warning = value;
    rasterize();
  }

  dynamic get value => _value;

  set value(value) {
    _value = value;
    present();
    rasterize();
  }

  bool get focused => _focused;

  FieldsForm get form => widget.scope.forms[widget.group ?? widget.scope.view.name];

  bool get isEmpty => value == null || value.toString().isEmpty;
}
