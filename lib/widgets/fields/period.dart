import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';

class PeriodInputField extends FieldWidget<PeriodValue> {
  final String displayFormat;
  final String Function(PeriodValue value) displayText;
  final dynamic Function(PeriodValue value) dataValue;
  final bool allowAllMonths;

  PeriodInputField({
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
    ValueChanged<PeriodValue> onSubmitted,
    ValueChanged<PeriodValue> onApplied,
    ValueChanged<PeriodValue> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<PeriodValue> validator,
    PeriodValue Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<PeriodValue> Function() fetcher,
    Function(PeriodValue value) applier,
    FieldWidgetTheme theme,
    this.displayFormat,
    this.displayText,
    this.dataValue,
    this.allowAllMonths,
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
          onApplied: onApplied,
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          sufixIcon: Icons.keyboard_arrow_down_sharp,
        );

  @override
  _PeriodInputFieldState createState() => _PeriodInputFieldState();
}

class _PeriodInputFieldState extends Field<PeriodValue, PeriodInputField> {
  @override
  void init() {}

  @override
  Widget display([String text]) => super.display((widget?.displayText?.call(value) ?? value?.toString(light: true)));

  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<PeriodValue> lookup() async => await widget.scope.dialogs.period(widget.label, icon: widget.icon, allowAllMonths: widget.allowAllMonths, selectedValue: value).show();
}
