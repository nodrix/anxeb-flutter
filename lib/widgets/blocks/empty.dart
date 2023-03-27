import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'paragraph.dart';

class EmptyBlock extends StatelessWidget {
  const EmptyBlock({
    @required this.scope,
    @required this.message,
    @required this.icon,
    this.actionCallback,
    this.actionText,
    this.visible,
    this.iconScale,
    this.fawIcon,
    this.tight,
    this.margin,
    this.fillColor,
  });

  final Scope scope;
  final String message;
  final IconData icon;
  final VoidCallback actionCallback;
  final String actionText;
  final bool visible;
  final double iconScale;
  final bool fawIcon;
  final bool tight;
  final EdgeInsets margin;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    if (visible == false) {
      return Container();
    }

    var size = MediaQuery.of(context).size;

    var $message = Container();
    var $action = Container();
    var $icon = Container(
      height: 110,
      child: Icon(
        icon,
        size: 110 * (iconScale ?? 1.0) * (fawIcon == true ? 0.8 : 1.0),
        color: fillColor ?? scope.application.settings.colors.navigation.withOpacity(0.1),
      ),
    );

    if (message?.isNotEmpty == true) {
      $message = Container(
        margin: EdgeInsets.only(top: 5),
        child: ParagraphBlock(
          alignment: TextAlign.center,
          content: <TextSpan>[
            TextSpan(style: TextStyle(), text: message),
          ],
        ),
      );
    }

    if (actionText != null) {
      $action = Container(
        margin: EdgeInsets.only(top: 10),
        child: Material(
          key: GlobalKey(),
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: InkWell(
            onTap: actionCallback,
            borderRadius: BorderRadius.all(Radius.circular(30)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ParagraphBlock(
                content: <TextSpan>[
                  TextSpan(
                    text: actionText.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 0.15,
                      fontWeight: FontWeight.w400,
                      color: scope.application.settings.colors.link,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (tight == true) {
      return Container(
        margin: margin,
        width: size.width * 0.66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [$icon, $message, $action],
        ),
      );
    }

    return Center(
      child: Container(
        width: size.width * 0.66,
        margin: margin ?? EdgeInsets.only(bottom: size.height * (0.07 + ((scope is ScreenScope && (scope as ScreenScope)?.view?.isFooter == false) ? 0.03 : 0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [$icon, $message, $action],
        ),
      ),
    );
  }
}
