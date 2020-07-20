import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:flutter/material.dart';

class ViewAction {
  final Scope scope;
  final IconData Function() icon;
  final VoidCallback onPressed;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  bool _hidden;

  ViewAction({
    @required this.scope,
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
  });

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
    );
  }

  bool get rebuild => false;
}
