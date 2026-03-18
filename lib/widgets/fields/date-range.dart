import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeInputField extends FieldWidget<List<DateTime>> {
  final String displayFormat;
  final String Function(List<DateTime> value) displayText;
  final dynamic Function(List<DateTime> value) dataValue;
  final String locale;
  final bool pickTime;
  final DateTime firstDate;
  final DateTime lastDate;

  DateRangeInputField({
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
    ValueChanged<List<DateTime>> onSubmitted,
    ValueChanged<List<DateTime>> onApplied,
    ValueChanged<List<DateTime>> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<List<DateTime>> validator,
    List<DateTime> Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<List<DateTime>> Function() fetcher,
    Function(List<DateTime> value) applier,
    FieldWidgetTheme theme,
    this.displayFormat,
    this.displayText,
    this.dataValue,
    this.locale,
    this.pickTime,
    this.firstDate,
    this.lastDate,
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
  _DateRangeInputFieldState createState() => _DateRangeInputFieldState();
}

class _DateRangeInputFieldState extends Field<List<DateTime>, DateRangeInputField> {
  DateFormat _dateFormat;

  @override
  void init() {
    _dateFormat = widget.displayFormat != null ? DateFormat(widget.displayFormat, widget.locale ?? 'es_DO') : null;
  }

  @override
  Widget display([String text]) => super.display(value != null && _dateFormat != null ? '${_dateFormat.format(value.first)} al ${_dateFormat.format(value.last)}' : (widget?.displayText?.call(value) ?? value?.toString()));

  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<List<DateTime>> lookup() async {
    var fetchedDate = (widget.fetcher != null ? await widget.fetcher() : value) ?? [];

    return await showCalendarDatePicker2Dialog(
      context: context,
      value: fetchedDate,
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDayOfWeek: 1,
        animateToDisplayedMonthDate: true,
        calendarType: CalendarDatePicker2Type.range,
        selectedDayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        selectedDayHighlightColor: widget.scope.application.settings.colors.primary,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        allowSameValueSelection: true,
        centerAlignModePicker: true,
        customModePickerIcon: SizedBox(),
      ),
      dialogSize: const Size(325, 400),
      //value: _dates,
      borderRadius: BorderRadius.circular(15),
    );
  } //await widget.scope.dialogs.dateTime(value: value, pickTime: widget.pickTime).show();
}
