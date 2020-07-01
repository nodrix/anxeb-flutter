import 'package:anxeb_flutter/middleware/menu.dart';
import 'package:flutter/material.dart';

import 'application.dart';
import 'view.dart';

class Navigator {
  Application _application;
  List<MenuGroup> _groups;
  Drawer Function(List<MenuGroup> groups) build;
  String role;
  Function() header;
  View _sourceView;
  GlobalKey<ViewState> _currentViewKey;

  Navigator(Application application) {
    _application = application;
    _groups = List<MenuGroup>();
    build = _buildDrawer;
  }

  void begin({View source, String role, Widget Function() header}) {
    _sourceView = source;
    this.header = header;
    this.role = role;
  }

  Future end() async {
    if (_currentView != null) {
      await _currentView.pop(null, force: true);
    }

    _sourceView = null;
    this.header = null;
    this.role = null;
  }

  Future<bool> exit() async => _sourceView != null ? await _sourceView.dismiss() : false;

  Future<dynamic> push(Future<ViewWidget> Function(Key key) getView) async {
    if (_sourceView != null) {
      var dismissed = _currentView != null ? await _currentView.dismiss() : true;

      if (dismissed) {
        if (_currentView == null) {
          if (_sourceView.scaffold != null && _sourceView.scaffold.currentState != null && _sourceView.scaffold.currentState.isDrawerOpen) {
            _sourceView.scaffold.currentState.openEndDrawer();
          }
        }
        _currentViewKey = GlobalKey<ViewState>();

        var view = await getView(_currentViewKey);
        var $openedKey = _currentViewKey;
        var result = await _sourceView.push(
          view,
          transition: ViewTransitionType.fade,
        );
        if (_currentViewKey == $openedKey) {
          _currentViewKey = null;
        }
        return result;
      }
    }
    return null;
  }

  MenuGroup add(MenuGroup group, {List<MenuItem> items}) {
    if (items != null) {
      group.setup(items);
    }
    _groups.add(group);
    return group;
  }

  Drawer drawer() {
    return build(groups);
  }

  Drawer _buildDrawer(List<MenuGroup> $groups) {
    if (_sourceView == null) {
      return null;
    }
    if ($groups.length > 0 || header != null) {
      return Drawer(
        elevation: 20.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            header(),
            Expanded(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: $groups.map(($group) => _buildItem($group)).toList(),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildItem(MenuItem $item, [MenuItem parent]) {
    var $hidden = $item.visible == false || ($item.isVisible != null && $item.isVisible() == false);
    var $unauthorized = (_sourceView == null) || (role != null && $item.roles != null && !$item.roles.contains(role));

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

    Color $activeColor = _application.settings.colors.primary;
    double $fontSize = 18;
    var $navigationColor = _application.settings.colors.navigation;
    var $itemStyle = TextStyle(
      color: $navigationColor,
      fontSize: $fontSize,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
    );

    if ($active == true) {
      $navigationColor = $activeColor;
      $itemStyle = TextStyle(
        color: $activeColor,
        fontSize: $fontSize,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
      );
    }

    if ($enabled == false) {
      $navigationColor = $error != null ? _application.settings.colors.danger.withAlpha(150) : _application.settings.colors.primary.withAlpha(90);
      $itemStyle = TextStyle(
        color: $error != null ? _application.settings.colors.danger.withAlpha(150) : _application.settings.colors.text.withAlpha(90),
        fontSize: $fontSize,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
      );
    }

    var menuItemContent = Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 16, bottom: $item.iconOffset != null && $item.iconOffset > 0 ? $item.iconOffset : 0, top: $item.iconOffset != null && $item.iconOffset < 0 ? -$item.iconOffset : 0),
            alignment: Alignment.center,
            width: 42,
            child: Icon(
              $item.icon,
              color: $navigationColor,
              size: 25.0 * ($item.iconScale ?? 1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text($item.caption, style: $itemStyle),
              $error != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text($error.toUpperCase(),
                          style: TextStyle(
                            color: $enabled == false ? _application.settings.colors.danger.withAlpha(150) : _application.settings.colors.danger,
                            fontSize: 11,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                          )),
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );

    var $group = $item is MenuGroup ? $item : null;
    var $anyChildActive = $group != null && $group.items != null && $group.items.length > 0 && $group.items.any(($item) => _isItemActive($item) == true);

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: $active == true ? _application.settings.colors.navigation.withOpacity(0.05) : Colors.transparent,
            border: $item.divider == true
                ? Border(
                    bottom: BorderSide(width: 1.0, color: _application.settings.colors.separator),
                  )
                : null,
          ),
          child: $group != null && $group.items.length > 0
              ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 8.0, color: _application.settings.colors.navigation.withOpacity(0.4)),
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: $anyChildActive,
                    title: menuItemContent,
                    children: $group.items.map(($subItem) {
                      return _buildItem($subItem, $group);
                    }).toList(),
                  ),
                )
              : Container(
                  decoration: parent != null
                      ? null
                      : BoxDecoration(
                          border: Border(
                            left: BorderSide(width: 8.0, color: _application.settings.colors.navigation.withOpacity(0.3)),
                          ),
                        ),
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

                      if ($item.home == true) {
                        await home();
                      }

                      if ($item.view != null) {
                        push((key) => $item.view(key));
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<bool> home() async {
    if (_currentViewKey != null) {
      var dismissed = _currentView != null ? await _currentView.dismiss() : true;
      if (dismissed) {
        _currentViewKey = null;
      }
      return dismissed;
    } else {
      if (_sourceView.scaffold != null && _sourceView.scaffold.currentState != null && _sourceView.scaffold.currentState.isDrawerOpen) {
        _sourceView.scaffold.currentState.openEndDrawer();
      }
      return true;
    }
  }

  bool _isItemActive(MenuItem $item) {
    var result = $item.active != null ? $item.active : ($item.isActive != null ? $item.isActive() : null);
    if (result == null) {
      if (_currentView != null && _currentView.name == $item.name) {
        result = true;
      } else if (_currentView == null && $item.home == true) {
        result = true;
      }
    }
    return result;
  }

  ViewState get _currentView => _currentViewKey?.currentState?.mounted == true ? _currentViewKey.currentState : null;

  List<MenuGroup> get groups => _groups;
}
