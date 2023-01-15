import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/menu.dart';
import 'scope.dart';
import 'screen.dart';

class ScreenNavigator extends Anxeb.Navigator {
  GlobalKey<ScreenState> _currentScreenKey;

  ScreenNavigator(Application application) : super(application);

  Future<T> push<T>(Future<ScreenWidget> Function(Key key) getScreen) async {
    if (source != null) {
      var dismissed = _currentScreen != null ? await _currentScreen.dismiss() : true;

      if (dismissed != false) {
        if (_currentScreen == null) {
          collapse();
        }
        _currentScreenKey = GlobalKey<ScreenState>();

        var screen = await getScreen(_currentScreenKey);
        var $openedKey = _currentScreenKey;
        var result = await _screen.push<T>(
          screen,
          transition: ScreenTransitionType.fade,
        );
        if (_currentScreenKey == $openedKey) {
          _currentScreenKey = null;
        }
        return result;
      }
    }
    return null;
  }

  @override
  Widget build() {
    if (source == null) {
      return null;
    }
    if (groups.length > 0 || header != null || footer != null) {
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
    if (_currentScreen != null) {
      await _currentScreen.pop(force: true);
    }
    super.end();
  }

  Widget _buildItem(Anxeb.MenuItem $item, [Anxeb.MenuItem parent]) {
    var $role = role?.call();
    var $roles = roles?.call();

    var $hidden = $item.visible == false || ($item.isVisible != null && $item.isVisible() == false);
    var $unauthorized = (source == null) || ($role != null && $item.roles != null && !$item.roles.contains($role)) || ($roles != null && $item.roles != null && !$roles.any(($role) => $item.roles.contains($role)));

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

    Color $activeColor = application.settings.colors.primary;
    double $fontSize = 18;
    var $navigationColor = application.settings.colors.navigation;
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
      $navigationColor = $error != null ? application.settings.colors.danger.withAlpha(150) : application.settings.colors.primary.withAlpha(90);
      $itemStyle = TextStyle(
        color: $error != null ? application.settings.colors.danger.withAlpha(150) : application.settings.colors.text.withAlpha(90),
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
            padding: EdgeInsets.only(right: 16.0 + ($item.iconHOffset != null && $item.iconHOffset < 0 ? -$item.iconHOffset : 0), left: $item.iconHOffset != null && $item.iconHOffset > 0 ? $item.iconHOffset : 0, bottom: $item.iconVOffset != null && $item.iconVOffset > 0 ? $item.iconVOffset : 0, top: $item.iconVOffset != null && $item.iconVOffset < 0 ? -$item.iconVOffset : 0),
            alignment: Alignment.center,
            width: 42,
            child: Icon(
              $item.icon,
              color: $navigationColor,
              size: 25.0 * ($item.iconScale ?? 1),
            ),
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text($item.caption(), style: $itemStyle),
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
                  : Container()
            ],
          )),
        ],
      ),
    );

    var $group = $item is MenuGroup ? $item : null;
    var $anyChildActive = $group != null && $group.items != null && $group.items.length > 0 && $group.items.any(($item) => _isItemActive($item) == true);

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: $active == true ? application.settings.colors.navigation.withOpacity(0.05) : Colors.transparent,
            border: $item.divider == true
                ? Border(
                    bottom: BorderSide(width: 1.0, color: application.settings.colors.separator),
                  )
                : null,
          ),
          child: $group != null && $group.items.length > 0
              ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 8.0, color: application.settings.colors.navigation.withOpacity(0.4)),
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
                            left: BorderSide(width: 8.0, color: application.settings.colors.navigation.withOpacity(0.3)),
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

                      await _onItemTab($item);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<bool> exit([result]) async => _screen != null ? await _screen.pop(result: result) : false;

  void collapse() {
    final scaffold = _screen.scaffold;
    if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
      scaffold.currentState.openEndDrawer();
    }
  }

  Future<bool> home() async {
    if (_currentScreenKey != null) {
      var dismissed = _currentScreen != null ? await _currentScreen.dismiss() : true;
      if (dismissed) {
        _currentScreenKey = null;
      }
      return dismissed;
    } else {
      collapse();
      return true;
    }
  }

  Future _onItemTab(Anxeb.MenuItem item) async {
    if (item.home == true) {
      await home();
    }

    if (item.view != null) {
      push((key) => item.view(key)).then((data) {
        item.result?.call(data);
      });
    }
  }

  bool _isItemActive(Anxeb.MenuItem item) {
    var result = item.active != null ? item.active : (item.isActive != null ? item.isActive() : null);
    if (result == null) {
      if (_currentScreen != null && _currentScreen.name == item.key) {
        result = true;
      } else if (_currentScreen == null && item.home == true) {
        result = true;
      }
    }
    return result;
  }

  ScreenState get _currentScreen => _currentScreenKey?.currentState?.mounted == true ? _currentScreenKey.currentState : null;

  ScreenView get _screen => source as ScreenView;

  ScreenScope get scope => _currentScreen?.scope ?? _screen?.scope;
}
