import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum OptionsInputFieldType { dropdown, dialog }

class OptionsInputField<V> extends FieldWidget<V> {
  final List<V> options;
  final OptionsInputFieldType type;
  final bool autofocus;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final String Function(V value) displayText;
  final dynamic Function(V value) dataValue;
  final bool Function(V a, V b) comparer;

  OptionsInputField({
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
    ValueChanged<V> onSubmitted,
    ValueChanged<V> onValidSubmit,
    ValueChanged<V> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    V Function(dynamic value) parser,
    bool focusNext,
    @required this.options,
    this.type,
    this.autofocus,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.displayText,
    this.dataValue,
    this.comparer,
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
        );

  @override
  _OptionsInputFieldState createState() => _OptionsInputFieldState<V>();
}

class _OptionsInputFieldState<V> extends Field<V, OptionsInputField<V>> {
  GlobalKey<FormState> _fieldKey;

  _OptionsInputFieldState() {
    _fieldKey = GlobalKey<FormState>();
  }

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
  dynamic data() {
    return widget.dataValue != null ? widget.dataValue(value) : value;
  }

  @override
  void reset() {
    super.reset();
  }

  @override
  Widget field() {
    var result = GestureDetector(
      onTap: () {
        if (widget.readonly == true) {
          return;
        }
        focus();
        if (widget.type == OptionsInputFieldType.dialog) {
          _getOptionFromDialog();
        }
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
                  if (widget.readonly == true) {
                    return;
                  }
                  if (value != null) {
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
                  } else {
                    setState(() {
                      if (widget.type == OptionsInputFieldType.dialog) {
                        _getOptionFromDialog();
                      } else {
                        //TODO: Allow collapse/expando from icon
                      }
                    });
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding: value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: widget.type == null || widget.type == OptionsInputFieldType.dropdown
                  ? DropdownButtonHideUnderline(
                      child: GestureDetector(
                        onTap: () {
                          if (widget.readonly == true) {
                            return;
                          }
                        },
                        child: DropdownButton<V>(
                          key: _fieldKey,
                          value: value,
                          iconSize: 0,
                          isDense: true,
                          onChanged: (selectedValue) {
                            super.submit(selectedValue);
                          },
                          hint: value != null ? Text(_displayText ?? '', style: TextStyle(color: widget.scope.application.settings.colors.focus)) : Text(widget.label, style: TextStyle(color: Color(0x88000000))),
                          items: widget.options.map((item) {
                            return DropdownMenuItem<V>(value: item, child: Text(widget.displayText != null ? widget.displayText(item) : item?.toString()));
                          }).toList(),
                        ),
                      ),
                    )
                  : Container(
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

  void _getOptionFromDialog() async {
    var result = await widget.scope.dialogs
        .options<V>(
          widget.label,
          options: widget.options.map(($option) => DialogButton<V>(widget.displayText != null ? widget.displayText($option) : $option?.toString(), $option)).toList(),
          selectedValue: value,
          icon: widget.icon,
        )
        .show();

    if (result != null) {
      if (result == '') {
        clear();
      } else {
        super.submit(result);
      }
    }
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(Icons.list, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }

  String get _displayText => widget.displayText != null ? widget.displayText(value) : value?.toString();
}
