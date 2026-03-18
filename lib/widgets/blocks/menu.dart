import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ContextMenu {
  final List<ContextMenuItem> items;
  final Widget child;
  final double itemHeight;
  final Offset offset;
  final TextStyle textStyle;
  final BoxConstraints constraints;

  ContextMenu({
    this.items,
    this.child,
    this.itemHeight,
    this.offset,
    this.textStyle,
    this.constraints,
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
  final BoxConstraints constraints;

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
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Function>(
      icon: child != null ? null : Icon(icon ?? Icons.more_vert),
      offset: offset ?? Offset(10, 50),
      child: child,
      tooltip: '',
      constraints: constraints ?? const BoxConstraints(minWidth: 20),
      shape: shape ?? RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
      onSelected: (func) {
        func?.call();
      },
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context) {
        var result = <PopupMenuEntry<Function>>[];

        for (var i = 0; i < items.length; i++) {
          var item = items[i];
          if (item.visible == false) {
            continue;
          }

          if (item.title != null) {
            result.add(
              PopupMenuItem<Function>(
                height: 20,
                enabled: false,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(item.title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xff333333))),
                        margin: EdgeInsets.only(bottom: 9, top: 6),
                        padding: EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.7, color: const Color(0xff333333)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (item.divided == true) {
            result.add(PopupMenuDivider());
          }

          result.add(PopupMenuItem<Function>(
            height: itemHeight ?? 35,
            onTap: item.enabled == false ? () {} : (item.onTap ?? () {}),
            enabled: item.enabled != false,
            child: Row(
              children: [
                Container(
                  child: Icon(item.icon, size: iconSize, color: item.color ?? item.iconColor ?? scope.application.settings.colors.primary),
                  width: 26,
                ),
                Container(
                  child: item.enabled == false
                      ? Opacity(
                          opacity: 0.5,
                          child: Text(item.label, style: textStyle ?? TextStyle(color: item.color ?? item.textColor ?? scope.application.settings.colors.primary)),
                        )
                      : Text(item.label, style: textStyle ?? TextStyle(color: scope.application.settings.colors.primary)),
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
  final Color iconColor;
  final String label;
  final Function onTap;
  final bool divided;
  final bool visible;
  final bool enabled;
  final String title;
  final Color textColor;
  final Color color;

  ContextMenuItem({this.icon, this.label, this.onTap, this.divided, this.iconColor, this.visible, this.enabled, this.title, this.textColor, this.color});
}
