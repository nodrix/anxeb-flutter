import 'package:anxeb_flutter/middleware/menu.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import 'application.dart';
import 'view.dart';

class Navigator {
  List<MenuGroup> _groups;
  String Function() role;
  List<String> Function() roles;
  Function() header;
  Function() footer;

  @protected
  final Application application;

  @protected
  IView source;

  Navigator(this.application) {
    _groups = <MenuGroup>[];
  }

  void begin({IView source, String Function() role, List<String> Function() roles, Widget Function() header, Widget Function() footer}) {
    this.source = source;
    this.header = header;
    this.footer = footer;
    this.role = role;
    this.roles = roles;
  }

  void end() {
    this.source = null;
    this.header = null;
    this.footer = null;
    this.role = null;
    this.role = null;
  }

  MenuGroup add(MenuGroup group, {List<Anxeb.MenuItem> items}) {
    if (items != null) {
      group.setup(items);
    }
    _groups.add(group);
    return group;
  }

  Widget drawer() {
    return build();
  }

  @protected
  Widget build() {
    return Container();
  }

  List<MenuGroup> get groups => _groups;
}
