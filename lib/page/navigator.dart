import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/menu.dart';

class PageNavigator extends StatefulWidget {
  final Application application;
  final bool Function(Anxeb.MenuItem item) isActive;
  final bool Function() isVisible;
  final List<MenuGroup> Function() groups;
  final String Function() role;
  final List<String> Function() roles;
  final Widget Function() header;
  final Widget Function() footer;
  final Color backgroundColor;

  PageNavigator({
    Key key,
    @required this.application,
    @required this.isActive,
    this.isVisible,
    this.groups,
    this.role,
    this.roles,
    this.header,
    this.footer,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  ScrollController _scrollController;
  bool _showTopButton;
  bool _showDownButton;
  List<MenuGroup> _groups;
  String _role;
  List<String> _roles;
  Widget _header;
  Widget _footer;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final showTop = _scrollController.offset > 0;
      final showDown = _scrollController.offset < _scrollController.position.maxScrollExtent - 5;

      if (_showTopButton != showTop) {
        setState(() {
          _showTopButton = showTop;
        });
      }

      if (_showDownButton != showDown) {
        setState(() {
          _showDownButton = showDown;
        });
      }
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

    Future.delayed(Duration(milliseconds: 0)).then((value) => mounted == true ? setState(() {}) : null);
    if (_showDownButton == null && _scrollController.hasClients == true) {
      _showDownButton = _scrollController.offset < _scrollController.position.maxScrollExtent - 5;
    }

    if (_groups?.isEmpty == true || widget.isVisible?.call() == false) {
      return Container();
    }
    return Container(
      color: widget.backgroundColor ?? Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _header ?? Container(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: _groups.map(($group) => _buildItem($group)).toList() + (_footer != null ? [_footer] : []),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _getAnimatedButton(
                        icon: Icons.arrow_drop_up_sharp,
                        visible: _showTopButton == true,
                        onTap: () {
                          _scrollController.position.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                        }),
                    Expanded(
                      child: Container(),
                    ),
                    _getAnimatedButton(
                        icon: Icons.arrow_drop_down_sharp,
                        visible: _showDownButton == true,
                        onTap: () {
                          _scrollController.position.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                        }),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAnimatedButton({IconData icon, bool visible, Function() onTap}) {
    return Material(
      color: widget.backgroundColor ?? Colors.black,
      child: InkWell(
        enableFeedback: true,
        hoverColor: Colors.white24,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
          height: visible ? 24 : 0,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                  opacity: visible ? 1 : 0,
                  child: Container(
                    margin: const EdgeInsets.only(),
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Anxeb.MenuItem $item) {
    var $activeColor = widget.application.settings.colors.active;
    var $error = $item.error ?? ($item.isError != null ? $item.isError() : null);
    var $active = _isItemActive($item);
    var $fontSize = 10.0;
    var $hidden = $item.visible == false || ($item.isVisible != null && $item.isVisible() == false);
    var $unauthorized = (_role != null && $item.roles != null && !$item.roles.contains(_role)) || (_roles != null && $item.roles != null && !_roles.any(($role) => $item.roles.contains($role)));
    var $disabled = $item.isDisabled != null ? $item.isDisabled() : null;
    var $enabled = $disabled == true ? false : ($item.enabled != null ? $item.enabled : ($item.isEnabled != null ? $item.isEnabled() : null));

    if ($hidden || $unauthorized) {
      return Container();
    }

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
        color: $error != null ? widget.application.settings.colors.danger.withAlpha(150) : widget.application.settings.colors.text.withAlpha(90),
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
                        color: $enabled == false ? widget.application.settings.colors.danger.withAlpha(150) : widget.application.settings.colors.danger,
                        fontSize: 11,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      )),
                )
              : Container(),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: $active == true ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            child: menuItemContent,
            borderRadius: BorderRadius.circular(8),
            hoverColor: Colors.white24,
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
    );
  }

  bool _isItemActive(Anxeb.MenuItem item) {
    var result = item.active != null ? item.active : (item.isActive != null ? item.isActive() : null);
    if (result == null && widget.isActive != null) {
      return widget.isActive(item);
    }
    return result;
  }
}
