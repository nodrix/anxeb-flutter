import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ContextMenu {
  final List<ContextMenuItem> items;
  final Widget child;
  final double itemHeight;
  final Offset offset;
  final TextStyle textStyle;

  ContextMenu({
    this.items,
    this.child,
    this.itemHeight,
    this.offset,
    this.textStyle,
  });
}

class ContextMenuBlock extends StatelessWidget {
  final Scope scope;
  final List<ContextMenuItem> items;
  final Widget child;
  final IconData icon;
  final double itemHeight;
  final Offset offset;
  final TextStyle textStyle;
  final double iconSize;
  final ShapeBorder shape;

  ContextMenuBlock({
    this.scope,
    this.items,
    this.child,
    this.icon,
    this.itemHeight,
    this.offset,
    this.textStyle,
    this.iconSize,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Function>(
      icon: child != null ? null : Icon(icon ?? Icons.more_vert),
      offset: offset ?? Offset(10, 50),
      child: child,
      tooltip: '',
      shape: shape ?? RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
      onSelected: (func) {
        func?.call();
      },
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context) {
        var result = <PopupMenuEntry<Function>>[];

        for (var i = 0; i < items.length; i++) {
          var item = items[i];
          if (item.onTap == null || item.visible == false) {
            continue;
          }

          if (item.divided == true) {
            result.add(PopupMenuDivider());
          }

          result.add(PopupMenuItem<Function>(
            height: itemHeight ?? 35,
            onTap: item.onTap ?? () {},
            child: Row(
              children: [
                Container(
                  child: Icon(item.icon, size: iconSize, color: item.color ?? scope.application.settings.colors.primary),
                  width: 26,
                ),
                Container(
                  child: Text(item.label, style: textStyle ?? TextStyle(color: scope.application.settings.colors.primary)),
                  padding: EdgeInsets.only(left: 12),
                ),
              ],
            ),
          ));
        }

        return result;
      },
    );
  }
}

class ContextMenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final Function onTap;
  final bool divided;
  final bool visible;

  ContextMenuItem({this.icon, this.label, this.onTap, this.divided, this.color, this.visible});
}
