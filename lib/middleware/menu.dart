import 'package:flutter/material.dart';
import 'view.dart';

typedef MenuCallback = Future<dynamic> Function();
typedef ActiveStateCallback = bool Function();
typedef EnabledStateCallback = bool Function();
typedef DisabledStateCallback = bool Function();
typedef VisibleStateCallback = bool Function();
typedef ErrorStateCallback = String Function();

class MenuItem {
  final String key;
  final Future<IView> Function(Key key) view;
  final Function(dynamic data) result;
  final double iconScale;
  final double iconVOffset;
  final double iconHOffset;
  final MenuCallback onTab;
  final ActiveStateCallback isActive;
  final EnabledStateCallback isEnabled;
  final DisabledStateCallback isDisabled;
  final VisibleStateCallback isVisible;
  final ErrorStateCallback isError;
  final List<String> roles;
  final bool home;
  String Function() caption;
  String hint;
  IconData icon;
  bool active;
  String error;
  bool enabled;
  bool visible;
  bool divider;

  MenuItem({
    this.caption,
    this.hint,
    this.key,
    this.view,
    this.result,
    this.icon,
    this.iconScale,
    this.iconVOffset,
    this.iconHOffset,
    this.active,
    this.isActive,
    this.error,
    this.isError,
    this.enabled,
    this.isEnabled,
    this.isDisabled,
    this.visible,
    this.isVisible,
    this.divider,
    this.onTab,
    this.roles,
    this.home,
  });
}

class MenuGroup extends MenuItem {
  List<MenuItem> items = <MenuItem>[];

  MenuGroup({
    @required String Function() caption,
    @required String key,
    @required IconData icon,
    String hint,
    Future<IView> Function(Key key) view,
    Function(dynamic data) result,
    double iconScale,
    double iconVOffset,
    double iconHOffset,
    bool active,
    ActiveStateCallback isActive,
    String error,
    ErrorStateCallback isError,
    bool enabled,
    EnabledStateCallback isEnabled,
    DisabledStateCallback isDisabled,
    bool visible,
    VisibleStateCallback isVisible,
    bool divider,
    MenuCallback onTab,
    List<String> roles,
    bool home,
    this.items = const <MenuItem>[],
  }) : super(
          caption: caption,
          hint: hint,
          key: key,
          view: view,
          result: result,
          icon: icon,
          iconScale: iconScale,
          iconVOffset: iconVOffset,
          iconHOffset: iconHOffset,
          active: active,
          isActive: isActive,
          error: error,
          isError: isError,
          enabled: enabled,
          isEnabled: isEnabled,
          isDisabled: isDisabled,
          visible: visible,
          isVisible: isVisible,
          divider: divider,
          onTab: onTab,
          roles: roles,
          home: home,
        );

  MenuItem add(MenuItem item) {
    items.add(item);
    return item;
  }

  void setup(List<MenuItem> items) {
    this.items = items;
  }
}
