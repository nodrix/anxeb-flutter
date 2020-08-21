import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/footer.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_button.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsFooter extends ViewFooter {
  @protected
  List<ActionIcon> actions;
  List<ActionButton> buttons;

  ActionsFooter({
    @required Scope scope,
    bool Function() isVisible,
    this.actions,
    this.buttons,
  }) : super(scope: scope, isVisible: isVisible);

  @override
  Widget content() {
    var $actions = actions != null ? actions.where(($action) => $action.isVisible?.call() != false).map(($action) => $action.build()).toList() : null;
    var $buttons = buttons != null ? buttons.where(($button) => $button.isVisible?.call() != false).map(($button) => $button.build()).toList() : null;

    return Row(
      children: <Widget>[
        Container(child: Row(children: $actions ?? [])),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: $buttons ?? [],
            ),
          ),
        ),
      ],
    );
  }
}
