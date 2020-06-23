import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog;

class MessageDialog extends Dialog {
  final String title;
  final String message;
  final Widget body;
  final IconData icon;
  final double iconSize;
  final Color messageColor;
  final Color titleColor;
  final Color iconColor;
  final List<KeyValue<ResultCallback>> buttons;
  final TextAlign textAlign;

  MessageDialog(Scope scope, {this.title, this.message, this.body, this.icon, this.iconSize, this.iconColor, this.messageColor, this.titleColor, this.textAlign, this.buttons})
      : assert(icon != null),
        super(scope) {
    super.dismissible = this.buttons == null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
      contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: messageColor ?? scope.application.settings.colors.text, fontWeight: FontWeight.w400),
      title: title != null
          ? Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 7),
                  margin: EdgeInsets.only(right: 12),
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
                ),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16.2, color: titleColor ?? scope.application.settings.colors.primary, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                  ),
                ),
              ],
            )
          : Container(
              child: Icon(
                icon,
                size: iconSize ?? 150,
                color: iconColor ?? scope.application.settings.colors.primary,
              ),
            ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          message != null
              ? Container(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: new Text(
                    message,
                    textAlign: textAlign ?? (title != null ? TextAlign.left : TextAlign.center),
                  ),
                )
              : Container(),
          body ?? Container(),
          buttons != null
              ? Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: TextButton.createList(context, buttons, settings: scope.application.settings),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
