import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInputField extends FieldWidget<DateTime> {
  final String displayFormat;
  final String Function(DateTime value) displayText;
  final dynamic Function(DateTime value) dataValue;
  final String locale;
  final bool pickTime;

  DateInputField({
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
    ValueChanged<DateTime> onSubmitted,
    ValueChanged<DateTime> onValidSubmit,
    ValueChanged<DateTime> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    DateTime Function(dynamic value) parser,
    bool refocus,
    DateTime Function() fetcher,
    Function(DateTime value) applier,
    FieldWidgetTheme theme,
    this.displayFormat,
    this.displayText,
    this.dataValue,
    this.locale,
    this.pickTime,
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
  _DateInputFieldState createState() => _DateInputFieldState();
}

class _DateInputFieldState extends Field<DateTime, DateInputField> {
  DateFormat _dateFormat;

  @override
  void init() {
    _dateFormat = widget.displayFormat != null ? DateFormat(widget.displayFormat, widget.locale ?? 'es_DO') : null;
  }

  @override
  Widget display([String text]) => super.display(value != null && _dateFormat != null ? _dateFormat.format(value) : value?.toString());

  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<DateTime> lookup() async => await widget.scope.dialogs.dateTime(value: value, pickTime: widget.pickTime).show();
}
