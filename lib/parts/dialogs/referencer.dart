import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/utils/referencer.dart';
import 'package:anxeb_flutter/widgets/blocks/referencer.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog;

class ReferencerDialog<V> extends ScopeDialog<List<V>> {
  final String title;
  final IconData icon;
  final Referencer<V> referencer;
  final ReferenceItemWidget<V> itemWidget;
  final ReferenceHeaderWidget<V> headerWidget;

  ReferencerDialog(Scope scope, {this.title, this.icon, this.referencer, this.itemWidget, this.headerWidget})
      : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  @override
  Future setup() async {
    await super.scope.busy();
    await referencer.init();
    await super.scope.idle();
  }

  @override
  Widget build(BuildContext context) {
    referencer.onSubmit((result) {
      Navigator.of(context).pop(result);
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
      contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
      title: icon != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 7),
                    child: Icon(
                      icon,
                      size: 29,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(bottom: 10),
              child: new Text(
                title ?? scope.view.title,
                textAlign: TextAlign.center,
              ),
            ),
      content: Container(
        height: scope.window.vertical(0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ReferencerBlock<V>(
                padding: EdgeInsets.only(left: 4, right: 4),
                scope: scope,
                referencer: referencer,
                itemWidget: itemWidget,
                headerWidget: headerWidget,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: TextButton.createList(
                  context,
                  [
                    DialogButton('Inicio', null, onTap: () {
                      referencer.start();
                    }),
                    DialogButton('Cancelar', null, onTap: () {
                      Navigator.of(context).pop();
                    })
                  ],
                  settings: scope.application.settings,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
