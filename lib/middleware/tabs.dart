import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ViewTabs {
  final Scope scope;
  final List<TabItem> items;
  final int initial;
  final Function(TabItem item) onChange;
  final Function(TabItem item) onTap;
  BuildContext _context;
  TabController _controller;
  int _currentIndex;
  
  @protected
  ViewTabs tabs() => null;

  ViewTabs({
    @required this.scope,
    @required this.items,
    this.initial,
    this.onChange,
    this.onTap,
  });

  void select(int index) {
    _controller.animateTo(index, duration: Duration(milliseconds: 100), curve: Curves.decelerate);
  }

  PreferredSize header({Widget bottomBody, double Function() height}) {
    var tabs = items.where(($tab) => $tab.isVisible?.call() != false).map((item) => item.build()).toList();
    return PreferredSize(
      preferredSize: new Size(0.0, height ?? 30.0),
      child: Column(
        children: <Widget>[
          bottomBody ?? Container(),
          TabBar(
            isScrollable: true,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            labelColor: scope.application.settings.colors.active,
            tabs: tabs,
            labelStyle: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget build(bool initialized) {
    return TabBarView(
      children: items.map((item) {
        var $content = initialized == true ? item.body() : Container();
        $content = scope.view.parts.refresher != null ? scope.view.parts.refresher.wrap($content) : $content;
        $content = scope.view.parts.panel != null ? scope.view.parts.panel.wrap($content) : $content;
        return $content;
      }).toList(),
      physics: NeverScrollableScrollPhysics(),
    );
  }

  
  Widget setup(Scaffold scaffold) {
    return DefaultTabController(
      length: items.length,
      initialIndex: initial ?? 0,
      child: Builder(builder: (BuildContext context) {
        _context = context;
        _controller?.removeListener(_controllerListener);
        _controller = DefaultTabController.of(_context);
        _controller.addListener(_controllerListener);
        return scaffold;
      }),
    );
  }

  void _controllerListener() {
    if (_controller.index != _currentIndex) {
      _currentIndex = _controller.index;
      onTap?.call(current);
      Future.delayed(Duration(milliseconds: 150), () {
        onChange?.call(current);
        scope.rasterize();
      });
    }
  }

  get currentData => current?.data;

  TabItem get current => currentIndex != null && items != null ? items[currentIndex] : null;

  int get currentIndex => _controller?.index;

  bool get rebuild => false;
}

class TabItem {
  final dynamic data;
  final String name;
  final String Function() caption;
  final IconData Function() icon;
  final bool Function() isVisible;
  final VoidCallback onPressed;
  final Widget Function() body;

  TabItem({
    this.caption,
    this.name,
    this.icon,
    this.isVisible,
    this.onPressed,
    this.body,
    this.data,
  });

  Widget build() {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        children: <Widget>[
          icon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: Icon(
                    icon(),
                    size: 16,
                  ),
                )
              : Container(),
          Text(
            caption().toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
