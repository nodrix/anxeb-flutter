import 'package:flutter/material.dart' hide Dialog, TextButton;
import '../../middleware/dialog.dart';
import '../../middleware/scope.dart';
import '../../widgets/buttons/text.dart';
import 'form.dart';

class AlertSheet extends FormSheet {
  final String subtitle;
  final String message;
  final Widget Function(BuildContext) body;
  final IconData icon;
  final List<DialogButton> buttons;
  final double iconSize;
  final Color iconColor;
  final Color subtitleColor;

  AlertSheet(
    Scope scope, {
    String title,
    this.subtitle,
    this.message,
    this.body,
    this.icon,
    this.buttons,
    this.iconSize,
    this.iconColor,
    this.subtitleColor,
    LinearGradient gradient,
  }) : super(scope, title: title ?? scope.title, gradient: gradient);

  @override
  Widget content(BuildContext context, Scope scope) {
    Widget $header = subtitle != null
        ? Row(
            children: <Widget>[
              icon != null
                  ? Container(
                      padding: const EdgeInsets.only(right: 7),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: iconSize ?? 72,
                        color: iconColor ?? scope.application.settings.colors.primary,
                      ),
                    )
                  : Container(),
              Expanded(
                child: Text(
                  subtitle.toUpperCase(),
                  softWrap: true,
                  textAlign: icon == null ? TextAlign.center : TextAlign.left,
                  style: TextStyle(fontSize: 16.2, color: subtitleColor ?? scope.application.settings.colors.primary, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                ),
              ),
            ],
          )
        : icon != null
            ? Icon(
                icon,
                size: iconSize ?? 150,
                color: iconColor ?? scope.application.settings.colors.primary,
              )
            : Container();

    Widget $content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        message != null
            ? Container(
                padding: const EdgeInsets.only(bottom: 4, top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        softWrap: true,
                        textAlign: (subtitle != null ? TextAlign.left : TextAlign.center),
                        style: TextStyle(
                          fontSize: 15,
                          color: scope.application.settings.colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        body?.call(context) ?? Container(),
        buttons != null
            ? Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: TextButton.createList(context, buttons, settings: scope.application.settings),
                ),
              )
            : Container(),
      ],
    );

    return Column(
      children: <Widget>[
        $header,
        $content,
      ],
    );
  }
}
