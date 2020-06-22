import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:barcode_scan/barcode_scan.dart';

enum BarcodeInputFieldType { numeric, alphanumeric }

class BarcodeInputField extends FieldWidget {
  final TextEditingController controller;
  final BarcodeInputFieldType type;
  final bool autofocus;
  final TextInputAction action;
  final bool canSelect;
  final TextFieldFormatter formatter;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final bool autoflash;

  BarcodeInputField({
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
    this.canSelect,
    this.formatter,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.autoflash,
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
  _BarcodeInputFieldState createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends Field<BarcodeInputField> {
  TextEditingController _controller = TextEditingController();
  bool _editing;
  bool _tabbed;

  _BarcodeInputFieldState() {
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
  void select(){
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  @override
  void setup() {}

  @override
  void prebuild() {}

  @override
  void onBlur() {
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
    _controller.text = _controller.text.toUpperCase();
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

  void _scan() async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      var $value = await BarcodeScanner.scan(
          options: ScanOptions(
        strings: {
          'cancel': 'X',
          'flash_on': 'Apagar Luz',
          'flash_off': 'Encender Luz',
        },
        autoEnableFlash: widget.autoflash != null ? widget.autoflash : true,
        android: AndroidOptions(
          useAutoFocus: true,
        ),
      ));
      if ($value != null) {
        super.value = $value.rawContent;
        _controller.selection = TextSelection(baseOffset: _controller.text.length, extentOffset: _controller.text.length);
        validate();
      }
    } catch (e) {}
  }

  @override
  Widget field() {
    var result = TextField(
      autofocus: widget.autofocus ?? false,
      focusNode: focusNode,
      textInputAction: widget.action,
      textCapitalization: TextCapitalization.characters,
      controller: _controller,
      readOnly: widget.readonly == true,
      enableInteractiveSelection: widget.canSelect != null ? widget.canSelect : true,
      autocorrect: false,
      keyboardType: widget.type == BarcodeInputFieldType.alphanumeric ? TextInputType.text : TextInputType.numberWithOptions(signed: false, decimal: false),
      onSubmitted: (value) {
        _editing = false;
        super.submit(value);
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
            if (focused && warning == null && _controller.text.length > 0) {
              _editing = false;
              super.submit(_controller.text);
            } else {
              if (_controller.text.length > 0) {
                _clear();
              } else {
                _scan();
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
    if (focused && warning == null && _controller.text.length > 0) {
      return Icon(Icons.done, color: widget.scope.application.settings.colors.success);
    } else {
      if (_controller.text.length > 0) {
        return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
      } else {
        return Icon(Icons.filter_center_focus, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
      }
    }
  }
}
