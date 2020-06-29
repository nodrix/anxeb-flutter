import 'package:anxeb_flutter/middleware/header.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsHeader extends ViewHeader {
  @protected
  List<ActionIcon> actions;

  ActionsHeader({
    Scope scope,
    this.actions,
    VoidCallback dismiss,
    VoidCallback back,
    ActionIcon leading,
  }) : super(scope: scope, dismiss: dismiss, back: back) {
    super.leading = leading?.build();
  }

  @override
  List<Widget> content() {
    var $actions = actions != null ? actions.where(($action) => $action.isVisible?.call() != false).map(($action) => $action.build()).toList() : null;
    return $actions;
  }
}
