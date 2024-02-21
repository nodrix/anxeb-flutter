import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class MenuPanel extends BoardPanel {
  final List<PanelMenuItem> items;
  final double textScale;
  final double iconScale;
  final bool horizontal;
  final bool autoHide;
  final double itemHeight;
  final double buttonRadius;
  final Color fillColor;

  MenuPanel({
    @required Scope scope,
    @required this.items,
    double height,
    bool rebuild,
    bool Function() isDisabled,
    this.itemHeight,
    this.textScale,
    this.iconScale,
    this.horizontal,
    this.autoHide,
    this.buttonRadius,
    bool gapless,
    Color barColor,
    this.fillColor,
  }) : super(
          scope: scope,
          height: height ?? 400,
          isDisabled: isDisabled,
          gapless: gapless,
          barColor: barColor,
        ) {
    super.rebuild = rebuild;
  }

  @override
  double get dynamicHeight {
    if (itemHeight != null) {
      var count = items.where(($item) => $item.isVisible?.call() != false && ($item.actions.any(($action) => $action.isVisible?.call() != false))).length;
      return (itemHeight * count) + 80;
    } else {
      return null;
    }
  }

  static Widget getButtons({List<PanelMenuItem> items, bool horizontal, double iconScale, double textScale, Future Function() collapse, double buttonRadius, BuildContext context}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .where(($item) => $item.isVisible?.call() != false)
          .map(($item) {
            var $actions = $item.actions.where(($action) => $action.isVisible?.call() != false).map(($action) {
              var button;

              var buttonContent = Container(
                width: $item.width?.call() ?? null,
                padding: $item.padding?.call() ?? null,
                alignment: Alignment.center,
                child: horizontal == true
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Icon(
                              $action.icon(),
                              color: $action.iconColor?.call() ?? Colors.white,
                              size: 48.0 * ($action.iconScale ?? 1) * (iconScale ?? 1),
                            ),
                          ),
                          $action.label != null
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    $action.label().toUpperCase(),
                                    textAlign: TextAlign.left,
                                    textScaleFactor: ($action.textScale ?? 1.05) * (textScale ?? 1),
                                    style: TextStyle(
                                      color: $action.textColor?.call() ?? Colors.white,
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
                              $action.icon(),
                              color: $action.iconColor?.call() ?? Colors.white,
                              size: 48.0 * ($action.iconScale ?? 1) * (iconScale ?? 1),
                            ),
                          ),
                          $action.label != null
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    $action.label().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    textScaleFactor: ($action.textScale ?? 1.05) * (textScale ?? 1),
                                    style: TextStyle(
                                      color: $action.textColor?.call() ?? Colors.white,
                                      letterSpacing: 0.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
              );

              if ($action.isDisabled?.call() == true) {
                button = Container(
                  margin: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: $action.fillColor?.call() ?? Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(buttonRadius ?? 10)),
                    ),
                    child: Opacity(
                      opacity: 0.5,
                      child: buttonContent,
                    ),
                  ),
                );
              } else {
                button = Container(
                  margin: const EdgeInsets.all(8),
                  child: Material(
                    key: GlobalKey(),
                    color: $action.fillColor?.call() ?? Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.all(Radius.circular(buttonRadius ?? 10)),
                    child: InkWell(
                      onTap: () {
                        collapse?.call();
                        $action.onPressed?.call();
                      },
                      borderRadius: BorderRadius.all(Radius.circular(buttonRadius ?? 10)),
                      child: buttonContent,
                    ),
                  ),
                );
              }

              return Expanded(
                child: button,
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
          .toList(),
    );
  }

  @override
  Widget content([Widget child]) {
    if (autoHide == true && !items.any(($item) => $item.actions.any(($action) => $action.isVisible?.call() != false && $action.isDisabled?.call() != true))) {
      return null;
    }

    return super.content(
      Container(
        margin: EdgeInsets.only(top: 5),
        child: getButtons(items: items, horizontal: horizontal, iconScale: iconScale, collapse: super.collapse, textScale: textScale, buttonRadius: buttonRadius),
      ),
    );
  }

  @protected
  BoxShadow get shadow => BoxShadow(offset: Offset(0, 0), blurRadius: 5, spreadRadius: 3, color: Color(0x3f555555));

  @override
  Color get fill => fillColor ?? scope.application.settings.colors.navigation;

  @override
  double get paddings => 8;

  @override
  double get margins => 0;

  @override
  double get radius => 0;
}

class PanelMenuItem {
  final List<PanelMenuAction> actions;
  final Function() isVisible;
  final double Function() height;
  final double Function() width;
  final EdgeInsets Function() padding;

  PanelMenuItem({this.actions, this.isVisible, this.height, this.width, this.padding});
}

class PanelMenuAction {
  final IconData Function() icon;
  final String Function() label;
  final bool Function() isVisible;
  final bool Function() isDisabled;
  final VoidCallback onPressed;
  final double iconScale;
  final double textScale;
  final Color Function() iconColor;
  final Color Function() fillColor;
  final Color Function() textColor;

  PanelMenuAction({
    @required this.icon,
    this.label,
    this.isVisible,
    this.isDisabled,
    this.onPressed,
    this.iconScale,
    this.textScale,
    this.iconColor,
    this.fillColor,
    this.textColor,
  });
}
