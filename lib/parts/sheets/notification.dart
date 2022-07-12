import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:anxeb_flutter/widgets/blocks/image.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter_translate/flutter_translate.dart';

class NotificationSheet extends ScopeSheet {
  final String title;
  final String message;
  final String imageUrl;
  final DateTime date;
  final IconData icon;
  final Widget body;
  final VoidCallback onDelete;
  final List<NotificationSheetAction> actions;

  NotificationSheet(Scope scope, {this.title, this.message, this.imageUrl, this.icon, this.body, this.actions, this.onDelete, this.date})
      : assert(title != null),
        super(scope);

  @override
  Widget build(BuildContext context) {
    Color foreground = scope.application.settings.colors.text;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: scope.window.available.height,
        minHeight: 0,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: scope.window.overlay.extendBodyFullScreen && Platform.isAndroid
                ? EdgeInsets.only(
                    top: 25,
                    left: 25,
                    right: 25,
                    bottom: 64,
                  )
                : EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: foreground),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            icon ?? Icons.notifications,
                            color: foreground,
                            size: 55,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  date != null
                      ? Container(
                          child: Row(
                            children: [
                              Text(Anxeb.Utils.convert.fromDateToHumanString(date, withTime: true, complete: true)),
                            ],
                          ),
                        )
                      : Container(),
                  imageUrl != null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          child: ImageLinkBlock(
                            url: imageUrl,
                            fit: BoxFit.cover,
                          ),
                          height: 200,
                        )
                      : Container(),
                  message != null
                      ? Container(
                          padding: EdgeInsets.only(top: 12, bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 21.5,
                                    height: 1.3,
                                    fontWeight: FontWeight.w300,
                                    color: foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  body ?? Container(),
                  actions != null && actions.isNotEmpty
                      ? Container(
                          child: Column(
                            children: actions.where((element) => element.isVisible != false).map(($action) {
                              return Anxeb.TextButton(
                                caption: $action.caption,
                                icon: $action.icon,
                                color: $action.color ?? scope.application.settings.colors.secudary,
                                margin: EdgeInsets.only(top: 12),
                                radius: scope.application.settings.dialogs.buttonRadius,
                                onPressed: () {
                                  Navigator.pop(context);
                                  $action.onPressed?.call();
                                },
                                type: Anxeb.ButtonType.primary,
                                size: Anxeb.ButtonSize.normal,
                              );
                            }).toList(),
                          ),
                        )
                      : Container(),
                  onDelete != null
                      ? Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Anxeb.TextButton(
                                  caption: translate('anxeb.common.delete'),
                                  //TR 'Eliminar',
                                  margin: EdgeInsets.only(right: 6),
                                  color: scope.application.settings.colors.danger,
                                  radius: scope.application.settings.dialogs.buttonRadius,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete?.call();
                                  },
                                  type: Anxeb.ButtonType.primary,
                                  size: Anxeb.ButtonSize.normal,
                                ),
                              ),
                              Expanded(
                                child: Anxeb.TextButton(
                                  caption: translate('anxeb.common.close'),
                                  //TR 'Cerrar',
                                  margin: EdgeInsets.only(left: 6),
                                  color: scope.application.settings.colors.secudary,
                                  radius: scope.application.settings.dialogs.buttonRadius,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  type: Anxeb.ButtonType.primary,
                                  size: Anxeb.ButtonSize.normal,
                                ),
                              ),
                            ],
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
  }

  @override
  Color get barrierColor => Colors.black12;

  @override
  double get elevation => 20.0;
}

class NotificationSheetAction {
  final String caption;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isDisabled;
  final bool isVisible;

  NotificationSheetAction({
    this.caption,
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
  });
}
