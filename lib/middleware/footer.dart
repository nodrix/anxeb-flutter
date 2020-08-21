import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ViewFooter {
  final Scope scope;
  final Widget child;
  final bool Function() isVisible;

  ViewFooter({
    @required this.scope,
    this.isVisible,
    this.child,
  });

  @protected
  Widget content() => child;

  Widget build() {
    if (this.isVisible?.call() == false) {
      return null;
    }
    return BottomAppBar(
      color: scope.application.settings.colors.primary,
      notchMargin: 8,
      elevation: 20,
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: Platform.isAndroid
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.white),
                ),
              )
            : null,
        child: content(),
      ),
      shape: CircularNotchedRectangle(),
    );
  }

  bool get rebuild => false;
}
