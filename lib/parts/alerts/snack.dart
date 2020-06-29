import 'dart:io';

import 'package:anxeb_flutter/middleware/alert.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart' hide Dialog;

const TextStyle _DEFAULT_MESSAGE_STYLE = TextStyle(fontSize: 16, fontWeight: FontWeight.w300);
const TextStyle _DEFAULT_TITLE_STYLE = TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

class SnackAlert extends ScopeAlert {
  final String title;
  final String message;
  final Color color;
  final TextStyle titleStyle;
  final TextStyle messageStyle;
  final int delay;
  final IconData icon;

  SnackAlert(Scope scope, {this.title, this.message, this.color, this.titleStyle, this.messageStyle, this.icon, this.delay}) : super(scope);

  @override
  Widget build() {
    return SnackBar(
      duration: Duration(milliseconds: delay ?? 3600),
      backgroundColor: color ?? scope.application.settings.colors.secudary,
      content: GestureDetector(
        onTap: () => this.dispose(),
        child: message == null
            ? Container(
                padding: EdgeInsets.only(bottom: scope.window.overlay.extendBodyFullScreen && Platform.isAndroid ? 50 : 0),
                child: Row(
                  children: icon != null
                      ? <Widget>[
                          Expanded(
                            flex: 0,
                            child: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(icon),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              style: messageStyle ?? _DEFAULT_MESSAGE_STYLE,
                              textAlign: TextAlign.left,
                            ),
                          )
                        ]
                      : <Widget>[
                          Text(
                            title,
                            style: messageStyle ?? _DEFAULT_MESSAGE_STYLE,
                            textAlign: TextAlign.left,
                          ),
                        ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: scope.window.overlay.extendBodyFullScreen && Platform.isAndroid ? 50 : 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 0,
                      child: Container(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          icon,
                          size: 28,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                title,
                                softWrap: true,
                                style: titleStyle ?? _DEFAULT_TITLE_STYLE,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: message != null
                                  ? Text(
                                      message,
                                      style: messageStyle ?? _DEFAULT_MESSAGE_STYLE,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
