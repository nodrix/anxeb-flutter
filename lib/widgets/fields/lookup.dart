import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class LookupInputField extends FieldWidget {
  final bool autofocus;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final KeyValueCallback onLookup;

  LookupInputField({
    @required Scope scope,
    Key key,
    @required String name,
    String group,
    String label,
    IconData icon,
    EdgeInsets margin,
    EdgeInsets padding,
    bool readonly,
    bool visible,
    ValueChanged<dynamic> onSubmitted,
    ValueChanged<dynamic> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<dynamic> onChanged,
    FormFieldValidator<String> validator,
    this.autofocus,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.onLookup,
  })  : assert(name != null),
        super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onValidSubmit: onValidSubmit,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
        );

  @override
  _LookupInputFieldState createState() => _LookupInputFieldState();
}

class _LookupInputFieldState extends Field<LookupInputField> {
  String _display;

  @override
  void init() {}

  @override
  void focus({String warning}) {
    super.focus(warning: warning);
  }

  @override
  void setup() {}

  @override
  void prebuild() {}

  @override
  void onBlur() {
    super.onBlur();
  }

  @override
  void onFocus() {
    super.onFocus();
  }

  @override
  dynamic data() => value != null ? (value as KeyValue).value : null;

  @override
  void reset() {
    super.reset();
  }

  void _clear() {
    validate();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        warning = null;
        value = null;
        if (widget.onChanged != null) {
          widget.onChanged(null);
        }
      });
    });
  }

  void _beginLookup() async {
    if (widget.onLookup != null) {
      var $value = await widget.onLookup();
      super.submit($value);
    }
  }

  @override
  void present() {
    setState(() {
      _display = (value != null && value is KeyValue) ? (value as KeyValue).key : value?.toString();
    });
  }

  @override
  Widget field() {
    var result = GestureDetector(
      onTap: () {
        if (widget.readonly == true) {
          return;
        }
        focus();
        _beginLookup();
      },
      child: new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            isFocused: focused,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.only(left: 0, top: 7, bottom: 0, right: 0),
              prefixIcon: Icon(
                widget.icon ?? FontAwesome5.dot_circle,
                color: widget.scope.application.settings.colors.primary,
              ),
              labelText: value != null ? (widget.fixedLabel == true ? widget.label.toUpperCase() : widget.label) : null,
              labelStyle: widget.fixedLabel == true
                  ? TextStyle(
                      fontWeight: FontWeight.w500,
                      color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary,
                      letterSpacing: 0.8,
                      fontSize: 15,
                    )
                  : null,
              fillColor: focused ? widget.scope.application.settings.colors.focus : widget.scope.application.settings.colors.input,
              errorText: warning,
              border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
              suffixIcon: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  //TODO: Allow collapse/expando from icon
                  if (widget.readonly == true) {
                    return;
                  }

                  if (value != null) {
                    _clear();
                  } else {
                    _beginLookup();
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding: value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  _display ?? widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: _display != null ? widget.scope.application.settings.colors.text : Color(0x88000000),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    return result;
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(Icons.search, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }
}
