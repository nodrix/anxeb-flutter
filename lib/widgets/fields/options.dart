import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum OptionsInputFieldType { dropdown, dialog }

class OptionsInputField extends FieldWidget {
  final List<KeyValue> options;
  final OptionsInputFieldType type;
  final bool autofocus;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;

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
    ValueChanged<dynamic> onSubmitted,
    ValueChanged<dynamic> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<dynamic> onChanged,
    FormFieldValidator<String> validator,
    @required this.options,
    this.type,
    this.autofocus,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
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
  _OptionsInputFieldState createState() => _OptionsInputFieldState();
}

class _OptionsInputFieldState extends Field<OptionsInputField> {
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
    return super.data();
  }

  @override
  void reset() {
    super.reset();
  }

  @override
  Widget field() {
    var optionValue = widget.options.firstWhere((item) => item.value == value, orElse: () => null);

    var optionKey;
    if (optionValue != null) {
      optionKey = optionValue.key;
    } else {
      value = null;
    }

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
                      //TODO: Allow collapse/expando from icon
                    });
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding: value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: widget.type == OptionsInputFieldType.dropdown
                  ? DropdownButtonHideUnderline(
                      child: GestureDetector(
                        onTap: () {
                          if (widget.readonly == true) {
                            return;
                          }
                        },
                        child: DropdownButton<String>(
                          key: _fieldKey,
                          value: value,
                          iconSize: 0,
                          isDense: true,
                          onChanged: (String selectedValue) {
                            super.submit(selectedValue);
                          },
                          hint: value != null
                              ? Text(
                                  optionKey,
                                  style: TextStyle(
                                    color: widget.scope.application.settings.colors.focus,
                                  ),
                                )
                              : Text(
                                  widget.label,
                                  style: TextStyle(
                                    color: Color(0x88000000),
                                  ),
                                ),
                          items: widget.options.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.value,
                              child: Text(item.key),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : Container(
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

  void _getOptionFromDialog() async {
    var result = await widget.scope.dialogs
        .options(
          widget.label,
          options: widget.options,
          selectedValue: 'cash',
          icon: widget.icon,
        )
        .show();

    if (result != null) {
      if (result == '') {
        value = null;
      } else {
        value = result;
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
      return Icon(Icons.keyboard_arrow_down, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }

  String get _display {
    var optionValue = widget.options.firstWhere((item) => item.value == this.value, orElse: () => null);
    return optionValue?.key;
  }
}
