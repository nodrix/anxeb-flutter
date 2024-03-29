import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';
import 'form.dart';
import 'scope.dart';

class FieldWidgetTheme {
  final bool isDense;
  final Color fillColor;
  final Color focusColor;
  final InputBorder border;
  final Color prefixIconColor;
  final Color iconColor;
  final bool minimal;
  final double prefixIconSize;
  final Color hoverColor;
  final TextStyle hintStyle;
  final TextStyle displayStyle;
  final TextStyle errorStyle;
  final TextStyle inputStyle;
  final TextStyle suffixStyle;
  final TextStyle prefixStyle;
  final Color suffixIconColor;
  final EdgeInsets contentPaddingWithIcon;
  final EdgeInsets contentPaddingNoIcon;
  final BorderRadius disabledBorder;
  final BorderRadius enabledBorder;
  final BorderRadius focusedBorder;
  final BorderRadius errorBorder;
  final BorderRadius focusedErrorBorder;
  final FontWeight labelFontWeight;
  final Color dangerColor;
  final Color labelColor;
  final double labelLetterSpacing;
  final double labelFontSize;
  final String labelFontFamily;
  final TextStyle labelStyle;
  final Color suffixIconReadonlyColor;
  final double suffixIconSize;
  final Color suffixIconDangerColor;
  final Color suffixIconSuccessColor;
  final Color suffixIconFocusedColor;
  final double iconSize;
  final double fontSize;
  final double labelSize;
  final bool borderless;
  final bool fixedLabel;
  final BorderRadius borderRadius;

  FieldWidgetTheme({
    this.isDense,
    this.fillColor,
    this.focusColor,
    this.border,
    this.prefixIconColor,
    this.iconColor,
    this.prefixIconSize,
    this.minimal,
    this.hoverColor,
    this.hintStyle,
    this.displayStyle,
    this.errorStyle,
    this.inputStyle,
    this.suffixStyle,
    this.prefixStyle,
    this.suffixIconColor,
    this.contentPaddingWithIcon,
    this.contentPaddingNoIcon,
    this.disabledBorder,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.labelFontWeight,
    this.dangerColor,
    this.labelColor,
    this.labelLetterSpacing,
    this.labelFontSize,
    this.labelFontFamily,
    this.labelStyle,
    this.suffixIconReadonlyColor,
    this.suffixIconSize,
    this.suffixIconDangerColor,
    this.suffixIconSuccessColor,
    this.suffixIconFocusedColor,
    this.iconSize,
    this.fontSize,
    this.labelSize,
    this.borderless,
    this.fixedLabel,
    this.borderRadius,
  });
}

class FieldWidget<V> extends StatefulWidget {
  final Scope scope;
  final Key key;
  final String name;
  final String group;
  final String label;
  final IconData icon;
  final IconData sufixIcon;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool readonly;
  final bool visible;
  final ValueChanged<V> onSubmitted;
  final ValueChanged<V> onApplied;
  final ValueChanged<V> onChanged;
  final GestureTapCallback onTab;
  final GestureTapCallback onBlur;
  final GestureTapCallback onFocus;
  final FormFieldValidator<V> validator;
  final V Function(dynamic value) parser;
  final FieldFocusType focusType;
  final Future<V> Function() fetcher;
  final Function(V value) applier;
  final bool initialSelected;
  final FieldWidgetTheme theme;

  FieldWidget({
    @required this.scope,
    this.key,
    this.name,
    this.group,
    this.label,
    this.icon,
    this.margin,
    this.padding,
    this.readonly,
    this.visible,
    this.onSubmitted,
    this.onApplied,
    this.onChanged,
    this.onTab,
    this.onBlur,
    this.onFocus,
    this.validator,
    this.parser,
    this.focusType,
    @required this.fetcher,
    @required this.applier,
    this.initialSelected,
    this.theme,
    this.sufixIcon,
  })  : assert(scope != null && name != null),
        super(key: key ?? scope.forms.key(group ?? scope.key, name));

  @override
  Field createState() => Field();
}

abstract class FieldState<V, F extends FieldWidget<V>> extends State<F> {
  int index;
  V value;
  bool focused;
  bool isEmpty;
  bool busy;

  void focus({String warning});

  void select();

  String validate({bool showMessage});

  bool valid();

  void reset();

  dynamic data();

  void fetch();

  void apply();
}

class Field<V, F extends FieldWidget<V>> extends FieldState<V, F> with AfterInitMixin<F> {
  V _value;
  bool _focused = false;
  int index = 0;
  String _warning;
  bool _initialized = false;

  @protected
  FocusNode focusNode;

  @protected
  dynamic data() {
    return value;
  }

  @protected
  void present() {}

  @protected
  Future<V> lookup() => null;

  @protected
  String label() => null;

  @protected
  bool get hasValue => value != null;

  @protected
  bool get canClear => false;

  @protected
  Widget display([String text]) {
    return Padding(
      padding: !hasValue ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
      child: Text(
        text ?? value?.toString() ?? widget.label,
        style: widget?.theme?.displayStyle ??
            TextStyle(
              fontSize: widget.theme?.fontSize != null ? (widget.theme.fontSize * 0.9) : 16,
              color: hasValue ? widget.scope.application.settings.colors.text : Color(0x88000000),
            ),
      ),
    );
  }

  void rasterize([VoidCallback fn]) {
    if (!mounted) {
      fn?.call();
    } else {
      setState(() {
        fn?.call();
      });
    }
  }

  @protected
  void init() {}

  @protected
  void setup() => null;

  @override
  void didInitState() {
    setup();
    if (_initialized != true) {
      _initialized = true;
      if (widget.fetcher != null) {
        widget.fetcher().then((fvalue) {
          this.value = fvalue;
          if (widget.initialSelected == true) {
            select();
          }
        });
      }
    }
  }

  @protected
  void focus({String warning}) {
    if (warning != null) {
      this.warning = warning;
    }
    if (mounted == true && focusNode?.context != null && focusNode.hasFocus == false) {
      FocusScope.of(this.context).requestFocus(focusNode);
    }
  }

  @protected
  void select() {}

  void unfocus() {
    widget.scope.unfocus();
  }

  void reset() {
    if (mounted) {
      setState(() {
        warning = null;
        value = null;
      });
    } else {
      warning = null;
      value = null;
    }
  }

  Future<V> fetch([bool apply = true]) async {
    if (widget.fetcher != null) {
      if (apply == true) {
        value = await widget.fetcher();
      } else {
        return await widget.fetcher();
      }
    }
    return value;
  }

  void apply() {
    if (widget.applier != null) {
      widget.applier(value);
    }

    if (widget.onApplied != null) {
      Future.delayed(new Duration(milliseconds: 150), () {
        widget.onApplied(value);
        widget.scope.rasterize();
      });
    } else {
      widget.scope.rasterize();
    }
  }

  String validate({bool showMessage, bool apply = true}) {
    var validation = _getValidation(value);
    if (validation != null && showMessage != false) {
      warning = validation;
    } else {
      warning = null;
      if (apply == true) {
        this.apply();
      }
    }
    return validation;
  }

  bool valid() {
    final result = _getValidation(value) == null;
    if (result == true) {
      apply();
    }
    return result;
  }

  @protected
  void submit(V $value) {
    var $warning = _getValidation($value);
    if ($warning == null) {
      if (this.value != $value && widget.onChanged != null) {
        this.value = $value;
        widget.onChanged($value);
      } else {
        this.value = $value;
      }

      warning = null;
      if (focusNode.hasFocus == true) {
        if (widget.focusType == FieldFocusType.refocus) {
          focus();
        } else if (widget.focusType == FieldFocusType.next) {
          unfocus();
          form.focusFrom(index, onlyEmpty: false);
        } else if (widget.focusType == FieldFocusType.unfocus) {
          unfocus();
        } else if (widget.focusType == FieldFocusType.empty) {
          unfocus();
          form.focusFrom(index, onlyEmpty: true);
        } else {
          unfocus();
          form.focusFrom(index);
        }
      }
      apply();
    } else {
      focus(warning: $warning);
    }
    if (widget.onSubmitted != null) {
      widget.onSubmitted(value);
    }
  }

  @override
  initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (widget.readonly == true) {
        return;
      }
      if (mounted == true) {
        if (!focusNode.hasFocus) {
          if (isEmpty) {
            warning = null;
          }
          setState(() {
            _focused = false;
          });
          onBlur();
          if (widget.onBlur != null) {
            widget.onBlur();
          }
        } else {
          setState(() {
            _focused = true;
          });
          onFocus();
          if (widget.onFocus != null) {
            widget.onFocus();
          }
        }
      }
    });

    form.include(this);
    init();
    if (!mounted) return;
    rasterize();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visible == false) {
      return Container();
    }
    prebuild();
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: field(),
    );
  }

  @protected
  void clear() {
    validate(apply: false);
    Future.delayed(Duration(milliseconds: 0), () {
      this.reset();
      if (widget.onChanged != null) {
        widget.onChanged(null);
      }
      apply();
    });
  }

  @protected
  void prebuild() {}

  @protected
  void onFocus() {}

  @protected
  void onBlur() {}

  @protected
  String hint() => null;

  bool _hovering;

  @protected
  Widget field() {
    return MouseRegion(
      cursor: widget.readonly == true ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onHover: (event) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (widget.readonly == true) {
            return;
          }
          focus();
          _beginLookup();
        },
        child: new FormField(
          builder: (FormFieldState state) {
            return InputDecorator(
              isFocused: focused,
              decoration: InputDecoration(
                filled: true,
                contentPadding: (widget.icon != null ? (widget.theme?.contentPaddingWithIcon ?? widget.scope.application.settings.fields.contentPaddingWithIcon) : (widget.theme?.contentPaddingNoIcon ?? widget.scope.application.settings.fields.contentPaddingNoIcon)) ?? EdgeInsets.only(left: widget.icon == null ? 10 : 0, top: widget.label == null ? 12 : 7, bottom: 7, right: 0),
                prefixIcon: widget.theme?.minimal == true
                    ? null
                    : (widget.icon != null
                        ? Icon(
                            widget.icon,
                            size: widget.theme?.prefixIconSize,
                            color: widget.theme?.prefixIconColor ?? widget.scope.application.settings.colors.primary,
                          )
                        : null),
                labelText: label?.call() ?? (hasValue ? (widget.theme?.fixedLabel == true ? widget.label.toUpperCase() : widget.label) : null),
                labelStyle: widget.theme?.labelSize != null
                    ? TextStyle(
                        fontWeight: widget.theme?.labelFontWeight,
                        color: widget.theme?.labelColor,
                        letterSpacing: widget.theme?.labelLetterSpacing,
                        fontSize: widget.theme?.labelSize,
                      )
                    : widget.theme?.labelStyle,
                floatingLabelBehavior: widget.theme?.fixedLabel == true ? FloatingLabelBehavior.always : null,
                hintText: hint(),
                hintStyle: widget.theme?.hintStyle ?? widget.scope.application.settings.fields.hintStyle,
                iconColor: widget.theme?.iconColor ?? widget.scope.application.settings.fields.iconColor,
                suffixIconColor: widget.theme?.suffixIconColor ?? widget.scope.application.settings.fields.suffixIconColor,
                prefixStyle: widget.theme?.prefixStyle ?? TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
                suffixStyle: widget.theme?.suffixStyle ?? TextStyle(color: widget.scope.application.settings.colors.text, fontSize: 16),
                errorText: warning,
                border: widget.theme?.borderRadius != null ? UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: widget.theme?.borderRadius) : (widget.theme?.border ?? widget.scope.application.settings.fields.border ?? UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8)))),
                disabledBorder: widget.theme?.borderless == true ? null : (widget.theme?.disabledBorder ?? widget.scope.application.settings.fields.disabledBorder),
                enabledBorder: widget.theme?.borderless == true ? null : (widget.theme?.enabledBorder ?? widget.scope.application.settings.fields.enabledBorder),
                focusedBorder: widget.theme?.borderless == true ? null : (widget.theme?.focusedBorder ?? widget.scope.application.settings.fields.focusedBorder),
                errorBorder: widget.theme?.borderless == true ? null : (widget.theme?.errorBorder ?? widget.scope.application.settings.fields.errorBorder),
                focusedErrorBorder: widget.theme?.borderless == true ? null : (widget.theme?.focusedErrorBorder ?? widget.scope.application.settings.fields.focusedErrorBorder),
                fillColor: _hovering == true ? (widget.theme?.hoverColor ?? widget.scope.application.settings.fields.hoverColor) : (focused ? (widget.theme?.focusColor ?? widget.scope.application.settings.fields.focusColor ?? widget.scope.application.settings.colors.focus) : (widget.theme?.fillColor ?? widget.scope.application.settings.fields.fillColor ?? widget.scope.application.settings.colors.input)),
                hoverColor: widget.theme?.hoverColor ?? widget.scope.application.settings.fields.hoverColor,
                errorStyle: widget.theme?.errorStyle ?? widget.scope.application.settings.fields.errorStyle,
                isDense: widget.theme?.isDense != null ? widget.theme?.isDense : (widget.scope.application.settings.fields.isDense != null ? widget.scope.application.settings.fields.isDense : false),
                suffixIcon: widget.theme?.minimal == true
                    ? null
                    : MouseRegion(
                        cursor: widget.readonly == true ? SystemMouseCursors.basic : SystemMouseCursors.click,
                        child: GestureDetector(
                          dragStartBehavior: DragStartBehavior.down,
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (widget.readonly == true) {
                              return;
                            }
                            if (hasValue || canClear) {
                              clear();
                            } else {
                              _beginLookup();
                            }
                          },
                          child: _getIcon(),
                        ),
                      ),
              ),
              child: display(),
            );
          },
        ),
      ),
    );
  }

  void _beginLookup() async {
    final value$ = await lookup?.call();
    if (value$ != null) {
      submit(value$);
    }
  }

  Widget _getIcon() {
    if (busy == true) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.primary),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.readonly == true) {
      return Icon(Icons.lock_outline, color: widget.scope.application.settings.colors.primary);
    }

    if (hasValue || canClear) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(widget.sufixIcon ?? Icons.search, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }

  @protected
  setValueSilent(dynamic value) {
    if (value == null) {
      _value = null;
    } else if (widget.parser != null) {
      _value = widget.parser(value);
    } else if (value is V) {
      _value = value;
    } else {
      _value = null;
    }
  }

  String _getValidation(V value) => widget.visible != false && widget.validator != null ? widget.validator(value) : null;

  @protected
  String get warning => _warning;

  @protected
  set warning(value) {
    rasterize(() {
      _warning = value;
    });
  }

  V get value => _value;

  set value(dynamic value) {
    if (value == null) {
      _value = null;
    } else if (widget.parser != null) {
      _value = widget.parser(value);
    } else if (value is V) {
      _value = value;
    } else {
      _value = null;
    }
    present();
    rasterize();
  }

  bool get focused => _focused;

  FieldsForm get form => widget.scope.forms[widget.group ?? widget.scope.key];

  bool get isEmpty {
    return value?.toString()?.isNotEmpty != true;
  }
}

enum FieldFocusType { refocus, unfocus, next, empty }
