import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ColorInputField extends FieldWidget<Color> {
  final Widget Function(Color value) displayWidget;
  final dynamic Function(Color value) dataValue;

  ColorInputField({
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
    ValueChanged<Color> onSubmitted,
    ValueChanged<Color> onValidSubmit,
    ValueChanged<Color> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    Color Function(dynamic value) parser,
    bool refocus,
    Color Function() fetcher,
    Function(Color value) applier,
    FieldWidgetTheme theme,
    this.displayWidget,
    this.dataValue,
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
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          refocus: refocus,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          sufixIcon: Icons.keyboard_arrow_down_sharp,
        );

  @override
  _ColorInputFieldState createState() => _ColorInputFieldState();
}

class _ColorInputFieldState extends Field<Color, ColorInputField> {
  @override
  void init() {}

  @override
  Widget display([String text]) {
    if (value == null) {
      return super.display();
    }
    return widget.displayWidget != null
        ? widget.displayWidget(value)
        : Container(
            height: 14,
            decoration: BoxDecoration(
              color: value,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: value.computeLuminance() > 0.5 ? Border.all(color: widget.scope.application.settings.colors.separator, width: 1) : null,
            ),
          );
  }

  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<Color> lookup() async => await widget.scope.dialogs.color(value: value, icon: widget.icon, title: widget.label).show();
}
