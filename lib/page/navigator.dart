import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/menu.dart';
import 'page.dart';
import 'scope.dart';

class PageNavigator extends Anxeb.Navigator {
  final PageMiddleware middleware;

  PageNavigator(this.middleware) : super(middleware.application);

  @override
  Widget build() {
    if (groups.length > 0 || header != null || footer != null) {
      return Drawer(
        elevation: 0.0,
        backgroundColor: application.settings.colors.navigation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            header?.call() ?? Container(),
            Expanded(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: groups.map(($group) => _buildItem($group)).toList() + (footer != null ? [footer()] : []),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Future end() async {
    if (scope != null) {
      await scope.view.pop(force: true);
    }
    super.end();
  }

  void go(String route) async {
    scope?.idle?.call();
    await scope?.alerts?.dispose?.call(quick: true);

    try {
      middleware?.info?.context?.go(route);
    } catch (err) {
      try {
        scope?.go?.call(route);
      } catch (err) {
        //ignore
      }
    }

    await scope?.setup?.call();
    if (scope?.view?.mounted == true) {
      scope.setup();
    }
  }

  Widget _buildItem(Anxeb.MenuItem $item, [Anxeb.MenuItem parent]) {
    var $role = role?.call();
    var $roles = roles?.call();

    var $hidden = $item.visible == false || ($item.isVisible != null && $item.isVisible() == false);
    var $unauthorized = ($role != null && $item.roles != null && !$item.roles.contains($role)) || ($roles != null && $item.roles != null && !$roles.any(($role) => $item.roles.contains($role)));

    if ($hidden || $unauthorized) {
      return Container();
    }

    var $enabled = $item.enabled != null ? $item.enabled : ($item.isEnabled != null ? $item.isEnabled() : null);
    var $disabled = $item.isDisabled != null ? $item.isDisabled() : null;

    if ($disabled == true) {
      $enabled = false;
    }

    var $error = $item.error ?? ($item.isError != null ? $item.isError() : null);
    var $active = _isItemActive($item);
    Color $activeColor = application.settings.colors.active;

    double $fontSize = 10;

    var $itemStyle = TextStyle(
      color: Colors.white,
      fontSize: $fontSize,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
    );

    if ($active == true) {
      $itemStyle = TextStyle(
        color: $activeColor,
        fontSize: $fontSize,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
      );
    }

    if ($enabled == false) {
      $itemStyle = TextStyle(
        color: $error != null ? application.settings.colors.danger.withAlpha(150) : application.settings.colors.text.withAlpha(90),
        fontSize: $fontSize,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
      );
    }

    var menuItemContent = Container(
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  $item.icon,
                  color: $active == true ? $activeColor : Colors.white,
                  size: 30.0 * ($item.iconScale ?? 1),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  $item.caption().toUpperCase(),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: $itemStyle,
                ),
              ],
            ),
          ),
          $error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text($error.toUpperCase(),
                      style: TextStyle(
                        color: $enabled == false ? application.settings.colors.danger.withAlpha(150) : application.settings.colors.danger,
                        fontSize: 11,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      )),
                )
              : Container(),
        ],
      ),
    );

    var $group = $item is MenuGroup ? $item : null;
    var $anyChildActive = $group != null && $group.items != null && $group.items.length > 0 && $group.items.any(($item) => _isItemActive($item) == true);

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: $active == true ? Colors.white.withOpacity(0.1) : Colors.transparent,
            border: $item.divider == true
                ? Border(
                    bottom: BorderSide(width: 1.0, color: application.settings.colors.separator),
                  )
                : null,
          ),
          child: $group != null && $group.items.length > 0
              ? Container(
                  /*decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 8.0, color: Colors.white.withOpacity(0.4)),
                    ),
                  ),*/
                  child: ExpansionTile(
                    initiallyExpanded: $anyChildActive,
                    title: menuItemContent,
                    children: $group.items.map(($subItem) {
                      return _buildItem($subItem, $group);
                    }).toList(),
                  ),
                )
              : Container(
                  /*decoration: parent != null
                      ? null
                      : BoxDecoration(
                          border: Border(
                            left: BorderSide(width: 8.0, color: Colors.white.withOpacity(0.3)),
                          ),
                        ),*/
                  child: ListTile(
                    dense: $error != null,
                    enabled: $enabled != false,
                    title: menuItemContent,
                    onTap: () async {
                      if ($item.onTab != null) {
                        var result = await $item.onTab();
                        if (result == false) {
                          return;
                        }
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  bool _isItemActive(Anxeb.MenuItem item) {
    var result = item.active != null ? item.active : (item.isActive != null ? item.isActive() : null);
    if (result == null) {
      if (info != null && info.name == item.key) {
        result = true;
      }
    }
    return result;
  }

  PageScope get scope => middleware.scope;

  PageInfo get info => middleware.info;
}
