import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ViewTabs {
  final Scope scope;
  final List<TabItem> items;
  final int initial;
  final Function(TabItem item) onChange;
  BuildContext _context;
  TabController _controller;

  @protected
  ViewTabs tabs() => null;

  ViewTabs({
    @required this.scope,
    @required this.items,
    this.initial,
    this.onChange,
  });

  void select(int index) {
    _controller.animateTo(index, duration: Duration(milliseconds: 100), curve: Curves.decelerate);
  }

  PreferredSize header() {
    var tabs = items.where(($tab) => $tab.isVisible?.call() != false).map((item) => item.build()).toList();
    return PreferredSize(
      preferredSize: new Size(0.0, 30.0),
      child: TabBar(
        isScrollable: true,
        unselectedLabelColor: Colors.white,
        indicatorColor: Colors.white,
        labelColor: scope.application.settings.colors.active,
        tabs: tabs,
        labelStyle: TextStyle(fontSize: 18),
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
      initialIndex: initial,
      child: Builder(builder: (BuildContext context) {
        _context = context;
        _controller = DefaultTabController.of(_context);
        _controller.addListener(() {
          Future.delayed(Duration(milliseconds: 150), () {
            onChange?.call(current);
            scope.rasterize();
          });
        });
        return scaffold;
      }),
    );
  }

  get currentData => current?.data;

  TabItem get current => currentIndex != null && items != null ? items[currentIndex] : null;

  int get currentIndex => _controller?.index;

  bool get rebuild => true;
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
