import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

enum OptionsInputFieldType { dropdown, dialog }

class OptionsInputField<V> extends FieldWidget<V> {
  final Future<List<V>> Function() options;
  final OptionsInputFieldType type;
  final String Function(V value) displayText;
  final IconData Function(V value) displayIcon;
  final dynamic Function(V value) dataValue;
  final bool Function(V option, V value) comparer;

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
    ValueChanged<V> onSubmitted,
    ValueChanged<V> onApplied,
    ValueChanged<V> onChanged,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    FormFieldValidator<V> validator,
    V Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<V> Function() fetcher,
    Function(V value) applier,
    @required this.options,
    FieldWidgetTheme theme,
    this.type,
    this.displayText,
    this.displayIcon,
    this.dataValue,
    this.comparer,
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
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          sufixIcon: Icons.keyboard_arrow_down_sharp,
          theme: theme,
        );

  @override
  _OptionsInputFieldState createState() => _OptionsInputFieldState<V>();
}

class _OptionsInputFieldState<V> extends Field<V, OptionsInputField<V>> {
  GlobalKey<FormState> _fieldKey;
  List<V> _options;

  _OptionsInputFieldState() {
    _fieldKey = GlobalKey<FormState>();
  }

  @override
  void init() {
    _loadOptions();
  }

  @override
  dynamic data() {
    return widget.dataValue != null ? widget.dataValue(value) : value;
  }

  @override
  Future<V> lookup() async {
    await _loadOptions();
    focus();

    if (widget.type == OptionsInputFieldType.dialog) {
      var result = await widget.scope.dialogs
          .options<V>(
            widget.label,
            options: options
                .map(($option) => DialogButton<V>(
                    widget.displayText != null
                        ? widget.displayText($option)
                        : $option?.toString(),
                    $option))
                .toList(),
            selectedValue: value,
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
    } else {
      _openDropdown();
    }

    return null;
  }

  @override
  Widget display([String text]) {
    if ((widget.type == null ||
        widget.type == OptionsInputFieldType.dropdown)) {
      return DropdownButtonHideUnderline(
        child: GestureDetector(
          onTap: widget.readonly == true ? null : () {

          },
          child: MouseRegion(
            onHover: (e) {},
            child: DropdownButton<V>(
              key: _fieldKey,
              value: value,
              borderRadius: BorderRadius.zero,
              elevation: 0,
              isExpanded: true,
              enableFeedback: widget.readonly == true ? false : true,
              focusColor: Colors.transparent,
              iconSize: 0,
              style: widget.theme?.inputStyle ??
                  (widget.theme?.fontSize != null
                      ? TextStyle(fontSize: widget.theme?.fontSize)
                      : (widget.label == null
                          ? TextStyle(fontSize: 20.25)
                          : null)),
              isDense: true,
              onChanged: widget.readonly == true ? null : (selectedValue) {
                super.submit(selectedValue);
              },
              hint: Container(
                padding: EdgeInsets.only(top: 1),
                child: super.display(),
              ),
              items: options.map((item) {
                return DropdownMenuItem<V>(
                  value: item,
                  child: Text(widget.displayText != null
                      ? widget.displayText(item)
                      : item?.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    return super.display(widget?.displayText?.call(value));
  }

  void _openDropdown() {
    GestureDetector detector;
    void searchForGestureDetector(BuildContext element) {
      element.visitChildElements((element) {
        if (element.widget != null && element.widget is GestureDetector) {
          detector = element.widget;
          return false;
        } else {
          searchForGestureDetector(element);
        }

        return true;
      });
    }

    searchForGestureDetector(_fieldKey.currentContext);
    assert(detector != null);

    detector.onTap();
  }

  @override
  Future<V> fetch([apply = true]) async {
    if (widget.fetcher != null) {
      _options = [];
      value = await widget.fetcher();
      await _loadOptions();
    }
    return value;
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
      value = _options.firstWhere(
          (item) => (widget.comparer != null
              ? widget.comparer(item, value)
              : item == value),
          orElse: () => null);
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
