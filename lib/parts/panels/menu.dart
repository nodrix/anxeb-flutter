import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class MenuPanel extends BoardPanel {
  final List<PanelMenuItem> items;
  final double textScale;
  final double iconScale;
  final bool horizontal;

  MenuPanel({
    Scope scope,
    this.items,
    double height,
    bool rebuild,
    bool Function() isDisabled,
    this.textScale,
    this.iconScale,
    this.horizontal,
  }) : super(
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
          children: items
              .map(($item) {
                var $actions = $item.actions.where((item) => item.isVisible?.call() != false).map(($action) {
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
                            child: horizontal == true
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          $action.icon,
                                          color: $action.iconColor ?? Colors.white,
                                          size: 48.0 * ($action.iconScale ?? 1) * (iconScale ?? 1),
                                        ),
                                      ),
                                      $action.label != null
                                          ? Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                $action.label.toUpperCase(),
                                                textAlign: TextAlign.left,
                                                textScaleFactor: ($action.textScale ?? 1.05) * (textScale ?? 1),
                                                style: TextStyle(
                                                  color: $action.textColor ?? Colors.white,
                                                  letterSpacing: -0.1,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          $action.icon,
                                          color: $action.iconColor ?? Colors.white,
                                          size: 48.0 * ($action.iconScale ?? 1) * (iconScale ?? 1),
                                        ),
                                      ),
                                      $action.label != null
                                          ? Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                $action.label.toUpperCase(),
                                                textAlign: TextAlign.center,
                                                textScaleFactor: ($action.textScale ?? 1.05) * (textScale ?? 1),
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
                }).toList();

                if ($actions.length == 0) {
                  return null;
                }
                return Expanded(
                  child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: $actions),
                );
              })
              .where((element) => element != null)
              .toList()),
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
  final bool Function() isVisible;
  final bool Function() isDisabled;
  final String label;
  final VoidCallback onPressed;
  final double iconScale;
  final double textScale;
  final Color iconColor;
  final Color fillColor;
  final Color textColor;

  PanelMenuAction({
    this.icon,
    this.isVisible,
    this.isDisabled,
    this.label,
    this.onPressed,
    this.iconScale,
    this.textScale,
    this.iconColor,
    this.fillColor,
    this.textColor,
  });
}
