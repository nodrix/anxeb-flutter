import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StateButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData icon;
  final EdgeInsets iconPadding;
  final EdgeInsets padding;
  final double size;
  final Color color;
  final String tooltip;
  final bool active;
  
  StateButton({
    Key key,
    this.onTap,
    this.icon,
    this.iconPadding,
    this.padding,
    this.size,
    this.color,
    this.tooltip,
    this.active,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var button;
    var $color = color ?? (active == false ? Colors.white54 : Colors.yellow);
    var $size = size ?? 34;
    
    if (onTap != null) {
      button = Padding(
        padding: padding ?? EdgeInsets.only(right: 4),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white24,
              onTap: onTap,
              child: Container(
                padding: iconPadding ?? EdgeInsets.all(4),
                child: Icon(
                  icon,
                  size: $size,
                  color: $color,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      button = Padding(
        padding: padding ?? EdgeInsets.only(right: 14),
        child: ClipOval(
          child: Container(
            padding: iconPadding ?? EdgeInsets.all(4),
            child: Icon(
              icon,
              size: $size,
              color: $color,
            ),
          ),
        ),
      );
    }
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        preferBelow: false,
        showDuration: Duration(seconds: 3),
        child: button,
      );
    } else {
      return button;
    }
  }
}
