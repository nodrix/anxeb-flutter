import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:community_material_icon/community_material_icon.dart';

class DateInputField extends FieldWidget<DateTime> {
  final bool autofocus;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final String displayFormat;
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
    bool focusNext,
    BorderRadius borderRadius,
    this.autofocus,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.displayFormat,
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
          focusNext: focusNext,
          borderRadius: borderRadius,
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
  dynamic data() {
    return widget.dataValue != null ? widget.dataValue(value) : value;
  }

  @override
  void reset() {
    super.reset();
  }

  @protected
  String getValueString(DateTime value) {
    return value?.toString();
  }

  @override
  Widget field() {
    var result = GestureDetector(
      onTap: () {
        if (widget.readonly == true) {
          return;
        }
        focus();
        _beginDateDialog();
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
                    clear();
                  } else {
                    _beginDateDialog();
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
                  _displayText ?? widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: _displayText != null ? widget.scope.application.settings.colors.text : Color(0x88000000),
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

  void _beginDateDialog() async {
    var $value = await widget.scope.dialogs.dateTime(value: value, pickTime: widget.pickTime).show();
    if ($value != null) {
      super.submit($value);
    }
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(CommunityMaterialIcons.calendar_month, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }

  String get _displayText => value != null && _dateFormat != null ? _dateFormat.format(value) : value?.toString();
}
