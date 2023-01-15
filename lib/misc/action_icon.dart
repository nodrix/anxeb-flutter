import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

import '../middleware/device.dart';

class ActionIcon with ActionItem {
  final IconData Function() icon;
  final double Function() size;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  final int Function() notifications;
  final BoxDecoration notificationDecoration;

  ActionIcon({
    @required this.icon,
    this.size,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.notifications,
    this.notificationDecoration,
  });

  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Colors.white;
    var button = IconButton(
      icon: Icon(icon(), color: $disabled ? $color.withOpacity(0.4) : $color, size: size?.call()),
      onPressed: $disabled ? null : onPressed,
    );

    var nots = notifications?.call();
    if (nots != null) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 6),
            child: button,
          ),
          Positioned(
            right: 8,
            top: 3,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: notificationDecoration ??
                  BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffd00000),
                    border: Border.all(width: 1.5, color: $color),
                  ),
              child: Text(
                nots.toString(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    } else {
      return button;
    }
  }
}

class ActionBack extends ActionIcon {
  ActionBack() : super(icon: () => Device.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios);

  Widget build() => BackButton();
}

class CloseAction extends ActionIcon {
  CloseAction() : super(icon: () => Icons.close);

  Widget build() => CloseButton();
}
