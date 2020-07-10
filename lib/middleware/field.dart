import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:after_init/after_init.dart';
import 'form.dart';
import 'scope.dart';

class FieldWidget<V> extends StatefulWidget {
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
  final ValueChanged<V> onSubmitted;
  final ValueChanged<V> onValidSubmit;
  final ValueChanged<V> onChanged;
  final GestureTapCallback onTab;
  final GestureTapCallback onBlur;
  final GestureTapCallback onFocus;
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
    this.onChanged,
    this.onTab,
    this.onBlur,
    this.onFocus,
    this.validator,
  })  : assert(scope != null && name != null),
        super(key: key ?? scope.forms.key(group ?? scope.view.name, name));

  @override
  Field createState() => Field();
}

abstract class FieldState<V, F extends FieldWidget<V>> extends State<F> {
  int index;
  V value;
  bool focused;
  bool isEmpty;

  void focus({String warning});

  void select();

  String validate({bool showMessage});

  bool valid();

  void reset();

  dynamic data();
}

class Field<V, F extends FieldWidget<V>> extends FieldState<V, F> with AfterInitMixin<F> {
  V _value;
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
    var result = widget.visible != false && widget.validator != null ? widget.validator(getValueString(this.value)) : null;

    if (showMessage != false) {
      warning = result;
    }
    return result;
  }

  bool valid() {
    return validate() == null;
  }

  @protected
  String getValueString(V value) {
    return value?.toString();
  }

  @protected
  void submit(V $value) {
    if (this.value != $value && widget.onChanged != null) {
      widget.onChanged($value);
    }
    this.value = $value;
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
      if (widget.readonly == true) {
        return;
      }
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
    if (widget.visible == false) {
      return Container();
    }
    prebuild();
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: field(),
    );
  }

  @protected
  void clear() {
    validate();
    Future.delayed(Duration(milliseconds: 0), () {
      this.reset();
      if (widget.onChanged != null) {
        widget.onChanged(null);
      }
    });
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

  V get value => _value;

  set value(value) {
    _value = value;
    present();
    rasterize();
  }

  bool get focused => _focused;

  FieldsForm get form => widget.scope.forms[widget.group ?? widget.scope.view.name];

  bool get isEmpty => value == null || value.toString().isEmpty;
}
