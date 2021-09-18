import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionMenu with ActionItem {
  final IconData Function() icon;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  final bool divided;
  final List<ActionMenuItem> actions;
  final Offset offset;

  ActionMenu({
    this.icon,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.divided,
    this.actions,
    this.offset,
  });

  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Colors.white;

    var items = <PopupMenuEntry<dynamic>>[];

    for (var action in actions) {
      if (action.isVisible?.call() == false) {
        continue;
      }
      if (action.divided?.call() == true) {
        items.add(PopupMenuDivider());
      }
      items.add(action.build());
    }

    return PopupMenuButton(
      itemBuilder: (context) => items,
      icon: Icon(icon?.call() ?? Icons.more_vert, color: $disabled ? $color.withOpacity(0.4) : $color),
      offset: offset ?? Offset(10, 60),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
      padding: EdgeInsets.all(0),
      enabled: isDisabled?.call() != true,
      onSelected: (value) {
        var action = (value as ActionMenuItem);
        if (action.onPressed != null && action.isDisabled?.call() != true) {
          Future.delayed(Duration(milliseconds: 0), () {
            action.onPressed();
          });
        }
      },
    );
  }
}

class ActionMenuItem {
  final IconData Function() icon;
  final String Function() caption;
  final Color Function() color;
  final Color Function() iconColor;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  final bool Function() divided;
  final double iconSize;

  ActionMenuItem({
    @required this.caption,
    this.icon,
    this.color,
    this.iconColor,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.divided,
    this.iconSize,
  });

  Widget build() {
    var $disabled = isDisabled?.call() == true;
    var $color = color?.call() ?? Color(0xff333333);
    $color = $disabled ? $color.withOpacity(0.4) : $color;

    return PopupMenuItem<dynamic>(
      height: 35,
      child: Row(
        children: <Widget>[
          Container(
            child: icon != null ? Icon(icon(), size: iconSize ?? 24, color: iconColor?.call() ?? $color) : Container(),
            width: 26,
          ),
          Container(
            child: Text(caption(), style: TextStyle(color: $color)),
            padding: EdgeInsets.only(left: icon != null ? 12 : 0),
          ),
        ],
      ),
      value: this,
    );
  }
}
