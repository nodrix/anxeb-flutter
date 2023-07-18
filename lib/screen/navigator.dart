import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/menu.dart';
import 'scope.dart';
import 'screen.dart';

class ScreenNavigatorController {
  Function() _collapse;
  Function() _home;
  Function() _exit;
  Function() _lobby;

  void collapse() {
    _collapse?.call();
  }

  void home() {
    _home?.call();
  }

  void exit() {
    _exit?.call();
  }

  void lobby() {
    _lobby?.call();
  }

  void _init({Function() collapse, Function() home, Function() exit, Function() lobby}) {
    _collapse = collapse;
    _home = home;
    _exit = exit;
    _lobby = lobby;
  }
}

class ScreenNavigator extends StatefulWidget {
  final ScreenScope scope;
  final bool Function(Anxeb.MenuItem item) isActive;
  final bool Function() isVisible;
  final List<MenuGroup> Function() groups;
  final String Function() role;
  final List<String> Function() roles;
  final Widget Function() header;
  final Widget Function() footer;
  final Color backgroundColor;
  final ScreenNavigatorController controller;

  ScreenNavigator({
    Key key,
    @required this.scope,
    this.isActive,
    this.isVisible,
    this.groups,
    this.role,
    this.roles,
    this.header,
    this.footer,
    this.backgroundColor,
    this.controller,
  }) : super(key: key);

  @override
  State<ScreenNavigator> createState() => _ScreenNavigatorState();
}

class _ScreenNavigatorState extends State<ScreenNavigator> {
  GlobalKey<ScreenState> _currentScreenKey;
  List<MenuGroup> _groups;
  String _role;
  List<String> _roles;
  Widget _header;
  Widget _footer;

  @override
  void initState() {
    widget.controller?._init(collapse: () {
      collapse();
    }, home: () {
      home();
    }, exit: () {
      exit();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _groups = widget.groups();
    _role = widget.role?.call();
    _roles = widget.roles?.call();
    _header = widget.header?.call();
    _footer = widget.footer?.call();

    if (_groups?.isEmpty == true || widget.isVisible?.call() == false) {
      return Container();
    }

    return Drawer(
      elevation: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _header,
          Expanded(
            child: Container(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _groups.map(($group) => _buildItem($group)).toList() + (_footer != null ? [_footer] : []),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Anxeb.MenuItem $item, [Anxeb.MenuItem parent]) {
    var $hidden = $item.visible == false || ($item.isVisible != null && $item.isVisible() == false);
    var $unauthorized = (_role != null && $item.roles != null && !$item.roles.contains(_role)) || (_roles != null && $item.roles != null && !_roles.any(($role) => $item.roles.contains($role)));

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

  void collapse() {
    final scaffold = _parentScreen.scaffold;
    if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
      scaffold.currentState.openEndDrawer();
    }
  }

  Future<T> push<T>(Future<ScreenWidget> Function(Key key) getScreen) async {
    var dismissed = _currentScreen != null ? await _currentScreen.dismiss() : true;

    if (dismissed == false) {
      return null;
    }

    if (_currentScreen == null) {
      collapse();
    }
    _currentScreenKey = GlobalKey<ScreenState>();

    var screen = await getScreen(_currentScreenKey);
    var $openedKey = _currentScreenKey;
    var result = await _parentScreen.push<T>(
      screen,
      transition: ScreenTransitionType.fade,
    );
    if (_currentScreenKey == $openedKey) {
      _currentScreenKey = null;
    }
    return result;
  }

  Future end() async {
    if (_currentScreen != null) {
      await _currentScreen.pop(force: true);
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

  bool _isItemActive(Anxeb.MenuItem item) {
    var result = item.active != null ? item.active : (item.isActive != null ? item.isActive() : null);
    if (result == null) {
      if (result == null && widget.isActive != null) {
        return widget.isActive(item);
      } else if (_currentScreen != null && _currentScreen.name == item.key) {
        result = true;
      } else if (_currentScreen == null && item.home == true) {
        result = true;
      }
    }
    return result;
  }

  void lobby() => Navigator.of(context).popUntil((route) => route.isFirst);

  Future<bool> exit([result]) async => _parentScreen != null ? await _parentScreen.pop(result: result) : false;

  ScreenState get _currentScreen => _currentScreenKey?.currentState?.mounted == true ? _currentScreenKey.currentState : null;

  ScreenView get _parentScreen => widget.scope.view;

  Application get application => widget.scope.application;
}
