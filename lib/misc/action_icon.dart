import 'dart:io';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionIcon with ActionItem {
  final IconData Function() icon;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;

  ActionIcon({
    @required this.icon,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
  });

  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Colors.white;

    return IconButton(
      icon: Icon(icon(), color: $disabled ? $color.withOpacity(0.4) : $color),
      onPressed: $disabled ? null : onPressed,
    );
  }
}

class ActionBack extends ActionIcon {
  ActionBack() : super(icon: () => Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios);

  Widget build() => BackButton();
}

class CloseAction extends ActionIcon {
  CloseAction() : super(icon: () => Icons.close);

  Widget build() => CloseButton();
}
