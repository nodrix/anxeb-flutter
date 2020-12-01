import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:flutter/material.dart';

class ViewAction {
  final Scope scope;
  final IconData Function() icon;
  final VoidCallback onPressed;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final FloatingActionButtonLocation locator;
  final List<AltAction> alternates;
  final double separation;
  final double offset;
  final bool mini;
  bool _hidden;

  ViewAction({
    @required this.scope,
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.locator,
    this.alternates,
    this.separation,
    this.offset,
    this.mini,
  });

  ViewAction.back({
    @required this.scope,
    this.isDisabled,
    this.isVisible,
    this.offset,
  })  : mini = true,
        color = (() => scope.application.settings.colors.primary),
        onPressed = (() => scope.view.dismiss()),
        alternates = null,
        separation = null,
        locator = ViewActionLocator(alignment: Alignment.bottomLeft),
        icon = (() => Icons.chevron_left);

  void show() {
    _hidden = false;
    scope.rasterize();
  }

  void hide() {
    _hidden = true;
    scope.rasterize();
  }

  Widget build() {
    if (_hidden == true || isVisible?.call() == false) {
      return null;
    }
    return FloatAction(
      onPressed: onPressed,
      color: color?.call() ?? scope.application.settings.colors.success,
      icon: icon?.call() ?? Icons.check,
      disabled: isDisabled?.call(),
      alternates: alternates,
      separation: separation,
      topOffset: offset,
      mini: mini,
      bottomOffset: Platform.isAndroid && scope.window.overlay.extendBodyFullScreen == true ? 60.0 : 0.0,
    );
  }

  bool get rebuild => false;
}
