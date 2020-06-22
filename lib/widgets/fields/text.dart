import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum TextInputFieldType { digits, decimals, real, integers, text, email, date, phone, url, password }

class TextInputField extends FieldWidget {
  final TextEditingController controller;
  final TextInputFieldType type;
  final bool autofocus;
  final TextInputAction action;
  final ValueChanged<dynamic> onActionSubmit;
  final TextCapitalization capitalization;
  final bool canSelect;
  final TextFieldFormatter formatter;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;

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
    ValueChanged<dynamic> onSubmitted,
    ValueChanged<dynamic> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<dynamic> onChanged,
    FormFieldValidator<String> validator,
    this.controller,
    this.type,
    this.autofocus,
    this.action,
    this.onActionSubmit,
    this.capitalization,
    this.canSelect,
    this.formatter,
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
  _TextInputFieldState createState() => _TextInputFieldState();
}

class _TextInputFieldState extends Field<TextInputField> {
  bool _obscureText;
  TextEditingController _controller = TextEditingController();
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
      return <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly];
    } else if (widget.type == TextInputFieldType.real) {
      return <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly];
    } else if (widget.type == TextInputFieldType.integers) {
      return <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly];
    } else {
      return null;
    }
  }

  TextInputType get _keyboardType {
    if (widget.type == TextInputFieldType.text || widget.type == TextInputFieldType.password) {
      return TextInputType.text;
    } else if (widget.type == TextInputFieldType.decimals) {
      return TextInputType.numberWithOptions(signed: true, decimal: true);
    } else if (widget.type == TextInputFieldType.real) {
      return TextInputType.numberWithOptions(signed: false, decimal: true);
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
    _obscureText = true;
    if (_editing == true) {
      _editing = false;
      super.submit(_controller.text);
    }
    super.onBlur();
  }

  @override
  void onFocus() {
    _editing = false;
    super.onFocus();
  }

  @override
  dynamic data() {
    if (widget.formatter != null) {
      return widget.formatter(value?.toString());
    } else {
      return super.data();
    }
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _editing = false;
      _controller.clear();
    });
  }

  @override
  void present() {
    _controller.text = value != null ? value.toString() : '';
    if (widget.capitalization == TextCapitalization.characters) {
      _controller.text = _controller.text.toUpperCase();
    }
  }

  void _clear() {
    validate();
    Future.delayed(Duration(milliseconds: 0), () {
      this.reset();
      if (widget.onChanged != null) {
        widget.onChanged(null);
      }
    });
  }

  @override
  Widget field() {
    var result = TextField(
      autofocus: widget.autofocus ?? false,
      obscureText: _obscureText && widget.type == TextInputFieldType.password,
      focusNode: focusNode,
      textInputAction: widget.action,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      controller: _controller,
      readOnly: widget.readonly == true,
      enableInteractiveSelection: widget.canSelect != null ? widget.canSelect : true,
      autocorrect: false,
      inputFormatters: _formatters,
      keyboardType: _keyboardType,
      onSubmitted: ($value) {
        _editing = false;
        super.submit($value);
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
      onChanged: (value) {
        if (_editing == false) {
          warning = null;
        }
        _editing = true;

        if (widget.onChanged != null) {
          widget.onChanged(value);
        }
      },
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        filled: true,
        contentPadding: EdgeInsets.only(left: 0, top: 7, bottom: 0, right: 0),
        prefixIcon: Icon(
          widget.icon ?? FontAwesome5.dot_circle,
          color: widget.scope.application.settings.colors.primary,
        ),
        labelText: widget.fixedLabel == true ? widget.label.toUpperCase() : widget.label,
        labelStyle: widget.fixedLabel == true
            ? TextStyle(
                fontWeight: FontWeight.w500,
                color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary,
                letterSpacing: 0.8,
                fontSize: 15,
              )
            : null,
        floatingLabelBehavior: widget.fixedLabel == true ? FloatingLabelBehavior.always : null,
        hintText: widget.hint,
        prefixStyle: TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        suffixStyle: TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        prefixText: widget.prefix,
        suffixText: widget.suffix,
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
                  _clear();
                }
              }
            } else {
              if (focused && warning == null) {
                _editing = false;
                super.submit(_controller.text);
              } else {
                if (_controller.text.length > 0) {
                  _clear();
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
