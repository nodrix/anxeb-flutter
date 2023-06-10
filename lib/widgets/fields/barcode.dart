import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../middleware/device.dart';

enum BarcodeInputFieldType { numeric, alphanumeric }

class BarcodeInputField extends FieldWidget<String> {
  final TextEditingController controller;
  final BarcodeInputFieldType type;
  final bool autofocus;
  final TextInputAction action;
  final bool canSelect;
  final String hint;
  final String prefix;
  final String suffix;
  final bool autoflash;
  final ValueChanged<String> onScan;

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
    ValueChanged<String> onSubmitted,
    ValueChanged<String> onValidSubmit,
    ValueChanged<String> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<String> validator,
    String Function(dynamic value) parser,
    bool refocus,
    bool selected,
    String Function() fetcher,
    Function(String value) applier,
    FieldWidgetTheme theme,
    this.controller,
    this.type,
    this.autofocus,
    this.action,
    this.canSelect,
    this.hint,
    this.prefix,
    this.suffix,
    this.autoflash,
    this.onScan,
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
          initialSelected: selected,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  _BarcodeInputFieldState createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends Field<String, BarcodeInputField> {
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
  void select() {
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
    _controller.text = _controller.text.toUpperCase();
  }

  void _scan() async {
    await Future.delayed(Duration(milliseconds: 200));
    var $value = await Device.scan(scope: widget.scope, autoflash: widget.autoflash);
    if ($value != null) {
      super.value = $value;
      _controller.selection = TextSelection(baseOffset: _controller.text.length, extentOffset: _controller.text.length);
      validate();
      widget?.onScan?.call(value);
      widget?.onSubmitted?.call(value);
    }
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
        contentPadding: (widget.icon != null ? widget.scope.application.settings.fields.contentPaddingWithIcon : widget.scope.application.settings.fields.contentPaddingNoIcon) ?? EdgeInsets.only(left: widget.icon == null ? 10 : 0, top: widget.label == null ? 12 : 7, bottom: 7, right: 0),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: widget.scope.application.settings.colors.primary,
              )
            : null,
        labelText: value != null ? (widget.theme?.fixedLabel == true ? widget.label.toUpperCase() : widget.label) : null,
        labelStyle: widget.theme?.fixedLabel == true
            ? TextStyle(
                fontWeight: widget.theme?.labelFontWeight ?? FontWeight.w500,
                color: warning != null ? (widget.theme?.dangerColor ?? widget.scope.application.settings.colors.danger) : (widget.theme?.labelColor ?? widget.scope.application.settings.colors.primary),
                letterSpacing: widget.theme?.labelLetterSpacing ?? 0.8,
                fontSize: widget.theme?.labelFontSize ?? 15,
                fontFamily: widget.theme?.labelFontFamily,
              )
            : (widget.theme?.labelSize != null
                ? TextStyle(
                    fontWeight: widget.theme?.labelFontWeight,
                    color: widget.theme?.labelColor,
                    letterSpacing: widget.theme?.labelLetterSpacing,
                    fontSize: widget.theme?.labelSize,
                  )
                : widget.theme?.labelStyle),
        floatingLabelBehavior: widget.theme?.fixedLabel == true ? FloatingLabelBehavior.always : null,
        hintText: widget.hint,
        hintStyle: widget.scope.application.settings.fields.hintStyle,
        iconColor: widget.scope.application.settings.fields.iconColor,
        suffixIconColor: widget.scope.application.settings.fields.suffixIconColor,
        prefixStyle: widget.theme?.prefixStyle ?? TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        suffixStyle: widget.theme?.suffixStyle ?? TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
        prefixText: widget.prefix,
        suffixText: widget.suffix,
        errorText: warning,
        border: widget.theme?.borderRadius != null ? UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: widget.theme?.borderRadius) : (widget.theme?.border ?? widget.scope.application.settings.fields.border ?? UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8)))),
        disabledBorder: widget.theme?.borderless == true ? null : (widget.theme?.disabledBorder ?? widget.scope.application.settings.fields.disabledBorder),
        enabledBorder: widget.theme?.borderless == true ? null : (widget.theme?.enabledBorder ?? widget.scope.application.settings.fields.enabledBorder),
        focusedBorder: widget.theme?.borderless == true ? null : (widget.theme?.focusedBorder ?? widget.scope.application.settings.fields.focusedBorder),
        errorBorder: widget.theme?.borderless == true ? null : (widget.theme?.errorBorder ?? widget.scope.application.settings.fields.errorBorder),
        focusedErrorBorder: widget.theme?.borderless == true ? null : (widget.theme?.focusedErrorBorder ?? widget.scope.application.settings.fields.focusedErrorBorder),
        fillColor: focused ? (widget.theme?.focusColor ?? widget.scope.application.settings.fields.focusColor ?? widget.scope.application.settings.colors.focus) : (widget.theme?.fillColor ?? widget.scope.application.settings.fields.fillColor ?? widget.scope.application.settings.colors.input),
        hoverColor: widget.theme?.hoverColor ?? widget.scope.application.settings.fields.hoverColor,
        errorStyle: widget.theme?.errorStyle ?? widget.scope.application.settings.fields.errorStyle,
        isDense: widget.theme?.isDense != null ? widget.theme?.isDense : (widget.scope.application.settings.fields.isDense != null ? widget.scope.application.settings.fields.isDense : false),
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
                clear();
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
      return Icon(Icons.lock_outline, color: widget.theme?.suffixIconReadonlyColor ?? widget.theme?.suffixIconColor, size: widget.theme?.suffixIconSize);
    }
    if (focused && warning == null && _controller.text.length > 0) {
      return Icon(Icons.done, color: widget.theme?.suffixIconSuccessColor ?? widget.scope.application.settings.colors.success);
    } else {
      if (_controller.text.length > 0) {
        return Icon(Icons.clear, color: widget.theme?.suffixIconColor ?? widget.scope.application.settings.colors.primary);
      } else {
        return Icon(Icons.filter_center_focus, color: warning != null ? (widget.theme?.suffixIconDangerColor ?? widget.scope.application.settings.colors.danger) : (widget.theme?.suffixIconColor ?? widget.scope.application.settings.colors.primary));
      }
    }
  }
}
