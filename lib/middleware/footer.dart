import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'device.dart';

class ScreenFooter {
  final Scope scope;
  final Widget child;
  final bool Function() isVisible;
  final Color color;
  final double elevation;
  final double height;
  final double divisionBorderWidth;
  final bool rebuild;
  final Clip clip;

  ScreenFooter({
    @required this.scope,
    this.isVisible,
    this.child,
    this.color,
    this.elevation,
    this.height,
    this.divisionBorderWidth,
    this.rebuild = false,
    this.clip = Clip.hardEdge,
  });

  @protected
  Widget content() => child;

  Widget build() {
    if (this.isVisible?.call() == false) {
      return null;
    }
    return BottomAppBar(
      color: color ?? scope.application.settings.colors.primary,
      notchMargin: 8,
      height: height ?? null,
      elevation: elevation ?? 20,
      clipBehavior: clip,
      child: Container(
        decoration: Device.isAndroid
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: divisionBorderWidth ?? 1.0, color: Colors.white),
                ),
              )
            : null,
        child: content(),
      ),
      shape: CircularNotchedRectangle(),
    );
  }
}
