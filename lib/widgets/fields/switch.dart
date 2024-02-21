import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

import '../buttons/switch.dart';

class SwitchField extends FieldWidget<bool> {
  final ListTileControlAffinity controlAffinity;

  SwitchField({
    @required Scope scope,
    @required String name,
    Key key,
    String group,
    String label,
    IconData icon,
    EdgeInsets margin,
    EdgeInsets padding,
    ValueChanged<bool> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onFocus,
    FormFieldValidator<bool> validator,
    FieldFocusType focusType,
    bool readonly,
    Future<bool> Function() fetcher,
    Function(bool value) applier,
    FieldWidgetTheme theme,
    this.controlAffinity,
  })  : assert(name != null),
        super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          margin: margin,
          padding: padding,
          readonly: readonly,
          onChanged: onChanged,
          onFocus: onFocus,
          validator: validator,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          label: label,
          icon: icon,
        );

  @override
  _SwitchFieldState createState() => _SwitchFieldState();
}

class _SwitchFieldState extends Field<bool, SwitchField> {
  @override
  Widget field() {
    var result = FormField(
      builder: (FormFieldState state) {
        double borderSize = widget.theme?.border?.borderSide?.width ?? widget.scope.application.settings.fields?.border?.borderSide?.width ?? 8;

        return SwitchButton(
          scope: widget.scope,
          margin: widget.margin,
          borderRadius: widget.theme?.borderRadius ?? BorderRadius.all(Radius.circular(borderSize)),
          color: focused ? (widget.theme?.focusColor ?? widget.scope.application.settings.fields.focusColor ?? widget.scope.application.settings.colors.focus) : (widget.theme?.fillColor ?? widget.scope.application.settings.fields.fillColor ?? widget.scope.application.settings.colors.input),
          icon: widget.icon,
          text: Text(
            widget.label ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary,
              letterSpacing: 0.2,
              fontSize: 15,
            ),
          ),
          readonly: widget.readonly,
          value: value ?? false,
          onToggle: widget.readonly == true
              ? null
              : (newValue) {
                  value = newValue;
                  validate();
                  if (widget.onChanged != null) widget.onChanged(newValue);
                },
        );
      },
    );

    return result;
  }
}
