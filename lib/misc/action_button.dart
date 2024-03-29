import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionButton with ActionItem {
  final IconData Function() icon;
  final String Function() caption;
  final Color Function() color;
  final Color Function() fill;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  final Widget Function() child;
  final BorderRadius Function() borderRadius;

  ActionButton({
    this.caption,
    this.icon,
    this.color,
    this.fill,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.child,
    this.borderRadius,
  });

  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Colors.white;
    $color = $disabled ? $color.withOpacity(0.4) : $color;

    return Container(
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: fill != null ? MaterialStateProperty.all<Color>(fill()) : null,
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 10)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius?.call() ?? BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        child: child?.call() ?? Row(
          children: <Widget>[
            icon != null
                ? Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                icon(),
                color: $color,
              ),
            )
                : Container(),
            Text(
              caption?.call()?.toUpperCase() ?? '',
              style: TextStyle(
                color: $color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        onPressed: $disabled ? null : onPressed,
      ),
    );
  }
}
