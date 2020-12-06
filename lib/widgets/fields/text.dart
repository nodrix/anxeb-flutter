import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextInputFieldType { digits, decimals, positive, integers, natural, text, email, date, phone, url, password }

class TextInputField<V> extends FieldWidget<V> {
  final TextEditingController controller;
  final TextInputFieldType type;
  final bool autofocus;
  final TextInputAction action;
  final ValueChanged<V> onActionSubmit;
  final TextCapitalization capitalization;
  final bool canSelect;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final V Function(String value) converter;
  final String Function(V value) displayText;
  final int maxLines;
  final int maxLength;
  final bool suffixActions;

  TextInputField({
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
    V value,
    double iconSize,
    double fontSize,
    double labelSize,
    bool selected,
    this.controller,
    this.type,
    this.autofocus,
    this.action,
    this.onActionSubmit,
    this.capitalization,
    this.canSelect,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.converter,
    this.displayText,
    this.maxLines,
    this.maxLength,
    this.suffixActions,
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
          initialValue: value,
          initialSelected: selected,
          iconSize: iconSize,
          labelSize: labelSize,
          fontSize: fontSize,
        );

  @override
  _TextInputFieldState createState() => _TextInputFieldState<V>();
}

class _TextInputFieldState<V> extends Field<V, TextInputField<V>> {
  bool _obscureText;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  bool _editing;
  bool _tabbed;

  _TextInputFieldState() {
    _obscureText = true;
    _controller = TextEditingController();
    _editing = false;
    _tabbed = false;
  }

  @override
  void init() {
    if (widget.controller != null) {
      _controller = widget.controller;
    }
  }

  @override
  void focus({String warning}) {
    select();
    super.focus(warning: warning);
  }

  @override
  void select() {
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  @override
  void setup() {}

  @override
  void prebuild() {}

  List<TextInputFormatter> get _formatters {
    if (widget.type == TextInputFieldType.digits) {
      return <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
    } else if (widget.type == TextInputFieldType.integers) {
      return <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
    } else {
      return null;
    }
  }

  TextInputType get _keyboardType {
    if (widget.type == TextInputFieldType.text || widget.type == TextInputFieldType.password) {
      return TextInputType.text;
    } else if (widget.type == TextInputFieldType.decimals) {
      return TextInputType.numberWithOptions(signed: true, decimal: true);
    } else if (widget.type == TextInputFieldType.positive) {
      return TextInputType.numberWithOptions(signed: false, decimal: true);
    } else if (widget.type == TextInputFieldType.natural) {
      return TextInputType.numberWithOptions(signed: false, decimal: false);
    } else if (widget.type == TextInputFieldType.digits) {
      return TextInputType.numberWithOptions(signed: false, decimal: false);
    } else if (widget.type == TextInputFieldType.integers) {
      return TextInputType.numberWithOptions(signed: true, decimal: false);
    } else if (widget.type == TextInputFieldType.email) {
      return TextInputType.emailAddress;
    } else if (widget.type == TextInputFieldType.date) {
      return TextInputType.datetime;
    } else if (widget.type == TextInputFieldType.phone) {
      return TextInputType.phone;
    } else if (widget.type == TextInputFieldType.url) {
      return TextInputType.url;
    } else {
      return TextInputType.text;
    }
  }

  @override
  void onBlur() {
    if (widget.displayText != null) {
      _controller2.text = widget.displayText(value);
    }
    _obscureText = true;
    if (_editing == true) {
      _editing = false;
      _convertAndSubmit(_controller.text);
    }
    super.onBlur();
  }

  @override
  void onFocus() {
    _editing = false;

    if (warning != null) {
      select();
    }
    super.onFocus();
  }

  @override
  dynamic data() {
    return super.data();
  }

  @override
  void reset() {
    super.reset();
    if (mounted) {
      setState(() {
        _editing = false;
        _controller.clear();
      });
    } else {
      _editing = false;
      _controller.clear();
    }
  }

  @override
  void present() {
    _controller.text = value != null ? value.toString() : '';
    if (widget.displayText != null) {
      _controller2.text = widget.displayText(value) ?? '';
    }
    if (widget.capitalization == TextCapitalization.characters) {
      _controller.text = _controller.text.toUpperCase();
    }
  }

  @override
  Widget field() {
    if (widget.displayText != null && !focused) {
      _controller2.text = widget.displayText(value);
    }

    var result = TextField(
      autofocus: widget.autofocus ?? false,
      obscureText: _obscureText == true && widget.type == TextInputFieldType.password,
      focusNode: focusNode,
      textInputAction: widget.action,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      controller: widget.displayText != null ? (focused && widget.readonly != true ? _controller : _controller2) : _controller,
      readOnly: widget.readonly == true,
      enableInteractiveSelection: widget.canSelect != null ? widget.canSelect : true,
      autocorrect: false,
      inputFormatters: _formatters,
      maxLength: focused ? widget.maxLength : null,
      maxLines: (_obscureText == true && widget.type == TextInputFieldType.password) == true ? 1 : widget.maxLines,
      keyboardType: _keyboardType,
      onSubmitted: (text) {
        _editing = false;
        _convertAndSubmit(text);
        if (widget.onActionSubmit != null) {
          widget.onActionSubmit(value);
        }
      },
      onTap: () {
        if (widget.readonly == true) {
          return;
        }
        if (_tabbed == true) {
          _tabbed = false;
        } else {
          _editing = false;
          if (!focusNode.hasFocus) {
            focus();
          }
          if (widget.onTab != null) {
            widget.onTab();
          }
        }
      },
      onChanged: (text) {
        super.setValueSilent(_convertValue(text));
        if (_editing == false) {
          warning = null;
        }
        _editing = true;
        if (widget.onChanged != null) {
          widget.onChanged(_convertValue(text));
        }
      },
      textAlign: TextAlign.left,
      style: widget.fontSize != null ? TextStyle(fontSize: widget.fontSize) : (widget.label == null ? TextStyle(fontSize: 20.25) : null),
      decoration: InputDecoration(
        filled: true,
        contentPadding: EdgeInsets.only(left: widget.icon == null ? 10 : 0, top: widget.label == null ? 12 : 7, bottom: 7, right: 0),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.scope.application.settings.colors.primary,
              )
            : null,
        labelText: widget.label != null ? (widget.fixedLabel == true ? widget.label.toUpperCase() : widget.label) : null,
        labelStyle: widget.fixedLabel == true
            ? TextStyle(
                fontWeight: FontWeight.w500,
                color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary,
                letterSpacing: 0.8,
                fontSize: 15,
              )
            : (widget.labelSize != null ? TextStyle(fontSize: widget.labelSize) : null),
        floatingLabelBehavior: widget.fixedLabel == true ? FloatingLabelBehavior.always : null,
        hintText: widget.hint,
        prefixStyle: TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        suffixStyle: TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        prefixText: widget.prefix,
        suffixText: widget.suffix,
        fillColor: focused ? widget.scope.application.settings.colors.focus : widget.scope.application.settings.colors.input,
        errorText: warning,
        border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
        suffixIcon: widget.suffixActions == false
            ? null
            : GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.readonly == true) {
                    return;
                  }
                  _tabbed = true;

                  if (widget.type == TextInputFieldType.password) {
                    if (_controller.text.length == 0) {
                      focus();
                    } else {
                      if (focused) {
                        _editing = false;
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      } else {
                        clear();
                      }
                    }
                  } else {
                    if (focused && warning == null) {
                      _editing = false;
                      _convertAndSubmit(_controller.text);
                    } else {
                      if (_controller.text.length > 0) {
                        clear();
                      } else {
                        focus();
                      }
                    }
                  }
                },
                child: _getIcon(),
              ),
      ),
    );
    return result;
  }

  V _convertValue(String text) {
    if (widget.converter != null) {
      return widget.converter(text);
    } else {
      dynamic result;
      if (text?.isNotEmpty == true) {
        if (widget.type == TextInputFieldType.text || widget.type == TextInputFieldType.email || widget.type == TextInputFieldType.url || widget.type == TextInputFieldType.password) {
          result = Utils.convert.fromStringToTrimedString(text);
        } else if (widget.type == TextInputFieldType.digits) {
          result = Utils.convert.fromStringToDigits(text);
        } else if (widget.type == TextInputFieldType.date) {
          result = Utils.convert.fromStringToDate(text);
        } else if (widget.type == TextInputFieldType.decimals) {
          result = Utils.convert.fromStringToDouble(text);
        } else if (widget.type == TextInputFieldType.integers) {
          result = Utils.convert.fromStringToInteger(text);
        } else if (widget.type == TextInputFieldType.phone) {
          result = Utils.convert.fromStringToDigits(text);
        } else if (widget.type == TextInputFieldType.positive) {
          result = Utils.convert.fromStringToDouble(text);
        } else if (widget.type == TextInputFieldType.natural) {
          result = Utils.convert.fromStringToInteger(text);
        } else {
          result = Utils.convert.fromStringToTrimedString(text);
        }
      }
      return result;
    }
  }

  void _convertAndSubmit(String text) {
    super.submit(_convertValue(text));
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (widget.type == TextInputFieldType.password) {
      if (_controller.text.length == 0) {
        return Icon(Icons.keyboard_arrow_left, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
      } else {
        if (focused) {
          return Icon(_obscureText ? Icons.visibility : Icons.visibility_off, semanticLabel: _obscureText ? 'mostrar' : 'ocultar', color: widget.scope.application.settings.colors.primary);
        } else {
          return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
        }
      }
    } else {
      if (focused && warning == null) {
        return Icon(Icons.done, color: widget.scope.application.settings.colors.success);
      } else {
        if (_controller.text.length > 0) {
          return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
        } else {
          return Icon(Icons.keyboard_arrow_left, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
        }
      }
    }
  }
}
