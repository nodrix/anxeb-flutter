import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class LookupInputField<V> extends FieldWidget<V> {
  final bool autofocus;
  final bool fixedLabel;
  final String hint;
  final String prefix;
  final String suffix;
  final Future<V> Function() onLookup;
  final String Function(V value) displayText;
  final dynamic Function(V value) dataValue;
  
  LookupInputField({
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
    this.autofocus,
    this.fixedLabel,
    this.hint,
    this.prefix,
    this.suffix,
    this.onLookup,
    this.displayText,
    this.dataValue,
  })
      : assert(name != null),
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
      );
  
  @override
  _LookupInputFieldState createState() => _LookupInputFieldState<V>();
}

class _LookupInputFieldState<V> extends Field<V, LookupInputField<V>> {
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
  
  @protected
  String getValueString(V value) {
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
        _beginLookup();
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
                    _beginLookup();
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
  
  void _beginLookup() async {
    if (widget.onLookup != null) {
      var $value = await widget.onLookup();
      if ($value != null) {
        super.submit($value);
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
      return Icon(Icons.search, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }
  
  String get _displayText => widget.displayText != null ? widget.displayText(value) : value?.toString();
}
