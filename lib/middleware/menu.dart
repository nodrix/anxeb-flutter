import 'package:flutter/material.dart';
import 'view.dart';

typedef MenuCallback = Future<dynamic> Function();
typedef ActiveStateCallback = bool Function();
typedef EnabledStateCallback = bool Function();
typedef DisabledStateCallback = bool Function();
typedef VisibleStateCallback = bool Function();
typedef ErrorStateCallback = String Function();

class MenuItem {
  final String name;
  final Future<ViewWidget> Function(Key key) view;
  final double iconScale;
  final double iconOffset;
  final MenuCallback onTab;
  final ActiveStateCallback isActive;
  final EnabledStateCallback isEnabled;
  final DisabledStateCallback isDisabled;
  final VisibleStateCallback isVisible;
  final ErrorStateCallback isError;
  final List<String> roles;
  final bool home;
  String caption;
  String hint;
  IconData icon;
  bool active;
  String error;
  bool enabled;
  bool visible;
  bool divider;

  MenuItem(
    this.caption, {
    this.hint,
    this.name,
    this.view,
    this.icon,
    this.iconScale,
    this.iconOffset,
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
  List<MenuItem> _items;

  MenuGroup(
    String caption, {
    @required String name,
    @required IconData icon,
    String hint,
    Future<ViewWidget> Function(Key key) view,
    double iconScale,
    double iconOffset,
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
  }) : super(
          caption,
          hint: hint,
          name: name,
          view: view,
          icon: icon,
          iconScale: iconScale,
          iconOffset: iconOffset,
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
        ) {
    _items = List<MenuItem>();
  }

  MenuItem add(MenuItem item) {
    items.add(item);
    return item;
  }

  void setup(List<MenuItem> items) {
    _items = items;
  }

  List<MenuItem> get items => _items;
}
