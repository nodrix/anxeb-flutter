import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:flutter/material.dart' hide Dialog;

class FormSheet extends ScopeSheet {
  final String title;
  final Color fill;
  final LinearGradient gradient;

  FormSheet(Scope scope, {this.title, this.fill, this.gradient})
      : assert(title != null),
        super(scope);

  @protected
  Widget content(BuildContext context, Scope scope) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(

        minHeight: 0,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: scope.window.insets.bottom),
        decoration: BoxDecoration(
          color: this.fill,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: this.gradient ??
              LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  fill.withOpacity(1),
                  fill.withOpacity(1),
                ],
                stops: [0.0, 1.0],
              ),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: scope.window.overlay.extendBodyFullScreen && Platform.isAndroid ? EdgeInsets.only(bottom: 64) : EdgeInsets.zero,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 0, top: 8, left: 8, right: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w600,
                                color: scope.application.settings.colors.primary,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          color: scope.application.settings.colors.primary,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 22, right: 22, bottom: 20),
                    child: content(context, scope),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
