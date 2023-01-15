import 'package:anxeb_flutter/middleware/header.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsHeader extends ScreenHeader {
  Widget Function() _body;

  ActionsHeader({
    Scope scope,
    String Function() title,
    Widget Function() body,
    Widget Function() bottom,
    double Function() elevation,
    double Function() height,
    this.actions,
    VoidCallback dismiss,
    VoidCallback back,
    ActionIcon leading,
    bool Function() isVisible,
    Color Function() fill,
  }) : super(
          scope: scope,
          dismiss: dismiss,
          back: back,
          title: title,
          bottom: bottom,
          elevation: elevation,
          height: height,
          isVisible: isVisible,
          fill: fill,
        ) {
    super.leading = leading?.build();
    _body = body;
  }

  @protected
  List<ActionItem> actions;

  @override
  Widget body() {
    return _body?.call() ?? null;
  }

  @override
  List<Widget> content() {
    var $actions = actions != null ? actions.where(($action) => $action.isVisible?.call() != false).map(($action) => $action.build()).toList() : null;
    return $actions;
  }
}

abstract class ActionItem {
  bool Function() isDisabled;
  bool Function() isVisible;
  VoidCallback onPressed;

  Widget build();
}
