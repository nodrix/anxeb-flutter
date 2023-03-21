import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class LookupInputField<V> extends FieldWidget<V> {
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
    V Function(dynamic value) parser,
    bool focusNext,
    V Function() fetcher,
    Function(V value) applier,
    FieldWidgetTheme theme,
    this.onLookup,
    this.displayText,
    this.dataValue,
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
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  _LookupInputFieldState createState() => _LookupInputFieldState<V>();
}

class _LookupInputFieldState<V> extends Field<V, LookupInputField<V>> {
  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<V> lookup() => widget.onLookup?.call() ?? null;

  @override
  Widget display([String text]) => super.display(widget?.displayText?.call(value));
}
