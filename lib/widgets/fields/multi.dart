import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class MultiInputField<V> extends FieldWidget<List<V>> {
  final Future<List<V>> Function() options;
  final String Function(V value) displayText;
  final bool Function(V option, List<V> value) comparer;

  MultiInputField({
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
    ValueChanged<List<V>> onSubmitted,
    ValueChanged<List<V>> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<List<V>> onChanged,
    FormFieldValidator<String> validator,
    List<V> Function(dynamic value) parser,
    bool refocus,
    List<V> Function() fetcher,
    Function(List<V> value) applier,
    FieldWidgetTheme theme,
    @required this.options,
    this.comparer,
    this.displayText,
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
        parser: parser,
        refocus: refocus,
        fetcher: fetcher,
        applier: applier,
        theme: theme,
      );

  @override
  _MultiInputFieldState createState() => _MultiInputFieldState();
}

class _MultiInputFieldState<V> extends Field<List<V>, MultiInputField<V>> {
  List<V> _options;

  @override
  void init() {
    _loadOptions();
  }

  @override
  Future<List<V>> lookup() async {
    await _loadOptions();
    focus();

    var result = await widget.scope.dialogs
        .multi<V>(
      widget.label,
      options: options
          .map(($option) => DialogButton<V>(
          widget.displayText != null ? widget.displayText($option) : $option?.toString(), $option))
          .toList(),
      selectedValues: value ?? [],
      icon: widget.icon,
    )
        .show();

    if (result != null) {
      if (result == '') {
        clear();
      } else {
        return result;
      }
    }

    return null;
  }

  @override
  Widget display([String text]) {
    if (value?.isNotEmpty == true) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Wrap(
          children: value
              .map(
                (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
              child: Text(
                item?.toString() ?? '',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          )
              .toList(),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 2),
        child: super.display(),
      );
    }
  }

  Future _loadOptions() async {
    if (_options?.isNotEmpty == true) {
      return;
    }

    try {
      rasterize(() async {
        busy = true;
      });
      _options = await widget.options?.call();
      final selected = _options
          .where((item) => (widget.comparer != null ? widget.comparer(item, value) : value != null ? value.contains(item) : false))
          .toList();
      value = selected.isEmpty ? null : selected;
    } catch (err) {
      _options = null;
      warning = err.toString();
    } finally {
      rasterize(() async {
        busy = false;
      });
    }
  }

  List<V> get options => _options ?? [];
}