import 'dart:io';

import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:flutter/material.dart' hide Dialog;

class TipSheet extends ScopeSheet {
  final String title;
  final String message;
  final Color fill;
  final Color foreground;
  final IconData icon;
  final Widget body;
  final bool flat;

  TipSheet(Scope scope, {this.title, this.message, this.fill, this.foreground, this.icon, this.body, this.flat})
      : assert(title != null),
        super(scope);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: scope.window.vertical(0.66),
        minHeight: 0,
      ),
      child: Container(
        decoration: flat != true
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    fill.withOpacity(1),
                    fill.withOpacity(0.8),
                  ],
                  stops: [0.0, 1.0],
                ),
              )
            : null,
        color: flat == true ? fill : null,
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
                        bottom: BorderSide(width: 0.5, color: foreground ?? scope.application.settings.colors.header),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        icon != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  icon,
                                  color: foreground ?? scope.application.settings.colors.header,
                                  size: 23,
                                ),
                              )
                            : Container(),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                              color: foreground ?? scope.application.settings.colors.header,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  message != null
                      ? Text(
                          message,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                            color: foreground ?? scope.application.settings.colors.text,
                          ),
                        )
                      : Container(),
                  body ?? Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
