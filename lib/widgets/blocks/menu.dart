import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContextMenuBlock extends StatelessWidget {
  final Scope scope;
  final List<ContextMenuItem> items;
  final IconData icon;

  ContextMenuBlock({this.scope, this.items, this.icon});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Function>(
      icon: Icon(icon ?? Icons.more_vert),
      offset: Offset(10, 50),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
      onSelected: (func) {
        func?.call();
      },
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context) {
        var result = <PopupMenuEntry<Function>>[];

        for (var i = 0; i < items.length; i++) {
          var item = items[i];

          if (item.divided == true) {
            result.add(PopupMenuDivider());
          }

          result.add(PopupMenuItem<Function>(
            height: 35,
            value: item.onTap ?? () {},
            child: Row(
              children: [
                Container(
                  child: Icon(item.icon, color: scope.application.settings.colors.primary),
                  width: 26,
                ),
                Container(
                  child: Text(item.label, style: TextStyle(color: scope.application.settings.colors.primary)),
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
  final String label;
  final Function onTap;
  final bool divided;

  ContextMenuItem({this.icon, this.label, this.onTap, this.divided});
}
