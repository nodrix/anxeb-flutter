import 'package:anxeb_flutter/middleware/header.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsHeader extends ViewHeader {
  @protected
  List<ActionItem> actions;

  ActionsHeader({
    Scope scope,
    String Function() title,
    this.actions,
    VoidCallback dismiss,
    VoidCallback back,
    ActionIcon leading,
  }) : super(scope: scope, dismiss: dismiss, back: back, title: title) {
    super.leading = leading?.build();
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
