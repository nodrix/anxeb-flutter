import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:flutter/material.dart' hide Dialog;

class PanelDialog<V> extends ScopeDialog {
  final String title;
  final List<PanelMenuItem> items;
  final bool horizontal;
  final double iconScale;
  final double textScale;
  final double buttonRadius;

  PanelDialog(Scope scope, {this.title, this.items, this.horizontal, this.iconScale, this.textScale, this.buttonRadius}) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    var height = items.where(($item) => $item.isVisible?.call() != false && ($item.actions.any(($action) => $action.isVisible?.call() != false))).fold(0, (previousValue, element) => previousValue + (element.height?.call() ?? 0));
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
      contentPadding: EdgeInsets.only(bottom: 8, left: 10, right: 10, top: title != null ? 4 : 8),
      title: title != null
          ? Container(
              padding: EdgeInsets.only(bottom: 10),
              child: new Text(
                title,
                textAlign: TextAlign.center,
              ),
            )
          : null,
      content: Container(
        height: height,
        child: MenuPanel.getButtons(
            items: items,
            horizontal: horizontal,
            iconScale: iconScale,
            textScale: textScale,
            buttonRadius: buttonRadius ?? scope.application.settings.panels.buttonRadius,
            context: context,
            collapse: () async {
              Navigator.of(context).pop();
            }),
      ),
    );
  }
}
