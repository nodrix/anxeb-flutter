import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class CheckBoxField extends FieldWidget<bool> {
  final Widget title;
  final ListTileControlAffinity controlAffinity;

  CheckBoxField({
    @required Scope scope,
    @required String name,
    Key key,
    String group,
    EdgeInsets margin,
    EdgeInsets padding,
    ValueChanged<bool> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    bool focusNext,
    this.title,
    this.controlAffinity,
  })  : assert(name != null),
        super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          margin: margin,
          padding: padding,
          onChanged: onChanged,
          onFocus: onFocus,
          validator: validator,
          focusNext: focusNext,
        );

  @override
  _CheckBoxFieldState createState() => _CheckBoxFieldState();
}

class _CheckBoxFieldState extends Field<bool, CheckBoxField> {
  @override
  Widget field() {
    var result = FormField(
      builder: (FormFieldState state) {
        return CheckboxListTile(
          title: widget.title,
          subtitle: warning != null
              ? Text(
                  warning,
                  style: TextStyle(
                    color: widget.scope.application.settings.colors.danger,
                  ),
                )
              : null,
          value: value ?? false,
          onChanged: (newValue) {
            value = newValue;
            validate();
            if (widget.onChanged != null) widget.onChanged(newValue);
          },
          controlAffinity:
              widget.controlAffinity ?? ListTileControlAffinity.leading,
        );
      },
    );

    return result;
  }
}
