import 'package:anxeb_flutter/middleware/footer.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsFooter extends ViewFooter {
  @protected
  List<ActionIcon> actions;

  ActionsFooter({
    Scope scope,
    this.actions,
  }) : super(scope: scope);

  @override
  Widget content() {
    var $actions = actions != null ? actions.where(($action) => $action.isVisible?.call() != false).map(($action) => $action.build()).toList() : null;
    return Row(children: $actions);
  }
}
