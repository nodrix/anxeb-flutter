import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class MultiInputField<V> extends FieldWidget<List<V>> {
  final Future<List<V>> Function() options;
  final String Function(V value) displayText;
  final bool Function(V option, V value) comparer;
  final Future<V> Function() onLookup;
  final double dialogHeight;
  final double spacing;
  final double runSpacing;

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
    ValueChanged<List<V>> onApplied,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<List<V>> onChanged,
    FormFieldValidator<List<V>> validator,
    List<V> Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<List<V>> Function() fetcher,
    Function(List<V> value) applier,
    FieldWidgetTheme theme,
    @required this.options,
    this.onLookup,
    this.comparer,
    this.displayText,
    this.dialogHeight,
    this.spacing,
    this.runSpacing,
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
          onApplied: onApplied,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          sufixIcon: onLookup != null ? Icons.add : null,
        );

  @override
  _MultiInputFieldState createState() => _MultiInputFieldState<V>();
}

class _MultiInputFieldState<V> extends Field<List<V>, MultiInputField<V>> {
  List<V> _options;
  List<V> _selection;

  @override
  void init() {
    _loadOptions();
  }

  @override
  Future<List<V>> lookup() async {
    if (widget.onLookup != null) {
      var option = await widget.onLookup?.call();
      _selection = _selection ?? value ?? [];
      if (option != null) {
        var existing = _selection?.isNotEmpty == true ? _selection.firstWhere((item) => widget.comparer != null ? widget.comparer(item, option) : item == option, orElse: () => null) : null;
        if (existing != null) {
          var index = _selection.indexOf(existing);
          _selection[index] = option;
        } else {
          _selection.add(option);
        }
      }
      return _selection;
    } else if (widget.options != null) {
      await _loadOptions();
      focus();

      var result = await widget.scope.dialogs
          .multi<V>(
            widget.label,
            height: widget.dialogHeight,
            options: options.map(($option) => DialogButton<V>(widget.displayText != null ? widget.displayText($option) : $option?.toString(), $option)).toList(),
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
    }
    return null;
  }

  @override
  void clear() {
    super.clear();
    _selection = [];
  }

  @override
  Widget display([String text]) {
    if (hasValue) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Wrap(
          spacing: widget.spacing ?? 0,
          runSpacing: widget.runSpacing ?? 0,
          children: value
              .map(
                (item) => Container(
                  padding: EdgeInsets.only(left: 10, right: widget.readonly != true && widget.onLookup != null ? 6 : 10, top: 2, bottom: 2),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: widget.scope.application.settings.colors.primary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.displayText != null ? widget.displayText(item) : item?.toString(),
                        //overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.readonly != true && widget.onLookup != null)
                        GestureDetector(
                          onTap: () {
                            _selection = value;
                            _selection.remove(item);
                            value = _selection;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
    } else {
      return Container(
        //padding: EdgeInsets.only(top: 2),
        child: super.display(widget.label),
      );
    }
  }

  @override
  Future<List<V>> fetch([apply = true]) async {
    if (widget.fetcher != null) {
      _normalizeSelectionValues(await widget.fetcher());
    }
    return value;
  }

  void _normalizeSelectionValues(List<V> value) {
    List<V> selected = [];

    if (value != null && _options?.isNotEmpty == true) {
      for (var option in _options) {
        for (var item in value) {
          if (widget.comparer != null) {
            if (widget.comparer(item, option) == true) {
              selected.add(option);
              break;
            }
          }
        }
      }
    }
    super.value = selected.isEmpty ? null : selected;
  }

  Future _loadOptions() async {
    if (widget.options == null || _options?.isNotEmpty == true) {
      return;
    }

    try {
      rasterize(() async {
        busy = true;
      });
      _options = await widget.options?.call();
      _normalizeSelectionValues(value);
    } catch (err) {
      _options = null;
      warning = err.toString();
    } finally {
      rasterize(() async {
        busy = false;
      });
    }
  }

  @override
  bool get hasValue => value?.isNotEmpty == true && _options?.isNotEmpty == true;

  List<V> get options => _options ?? [];
}
