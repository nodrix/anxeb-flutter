import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionButton with ActionItem {
  final IconData Function() icon;
  final String Function() caption;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  
  ActionButton({
    @required this.caption,
    this.icon,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
  });
  
  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Colors.white;
    $color = $disabled ? $color.withOpacity(0.4) : $color;
    
    return Container(
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            icon != null ? Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(icon(), color: $color,),
            ) : Container(),
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
