import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class MenuPanel extends BoardPanel {
  final List<PanelMenuItem> items;

  MenuPanel({Scope scope, this.items, double height, bool rebuild, bool Function() isDisabled})
      : super(
          scope: scope,
          height: height ?? 400,
          isDisabled: isDisabled,
        ) {
    super.rebuild = rebuild;
  }

  @override
  Widget content([Widget child]) {
    return super.content(Container(
      margin: EdgeInsets.only(top: 5),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map(($item) {
            return Expanded(
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: $item.actions.map(($action) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: Material(
                          key: GlobalKey(),
                          color: $action.fillColor ?? Colors.white.withOpacity(0.2),
                          borderRadius: new BorderRadius.all(Radius.circular(10)),
                          child: InkWell(
                            onTap: () {
                              super.collapse();
                              $action.onPressed?.call();
                            },
                            borderRadius: new BorderRadius.all(Radius.circular(10)),
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      $action.icon,
                                      color: $action.iconColor ?? Colors.white,
                                      size: 48.0 * ($action.scale ?? 1),
                                    ),
                                  ),
                                  $action.label != null
                                      ? Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            $action.label.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            textScaleFactor: 1.05,
                                            style: TextStyle(
                                              color: $action.textColor ?? Colors.white,
                                              letterSpacing: 0.3,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList()),
            );
          }).toList()),
    ));
  }

  @protected
  BoxShadow get shadow => BoxShadow(offset: Offset(0, 0), blurRadius: 5, spreadRadius: 3, color: Color(0x3f555555));

  @override
  Color get fill => scope.application.settings.colors.navigation;

  @override
  double get paddings => 8;

  @override
  double get margins => 0;

  @override
  double get radius => 0;
}

class PanelMenuItem {
  final List<PanelMenuAction> actions;

  PanelMenuItem({this.actions});
}

class PanelMenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double scale;
  final Color iconColor;
  final Color fillColor;
  final Color textColor;

  PanelMenuAction({
    this.icon,
    this.label,
    this.onPressed,
    this.scale,
    this.iconColor,
    this.fillColor,
    this.textColor,
  });
}
