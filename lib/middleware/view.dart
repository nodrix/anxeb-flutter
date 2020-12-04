import 'dart:async';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:anxeb_flutter/parts/headers/search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:after_init/after_init.dart';
import 'action.dart';
import 'application.dart';
import 'footer.dart';
import 'header.dart';
import 'panel.dart';
import 'refresher.dart';
import 'scope.dart';
import 'tabs.dart';

enum ViewTransitionType {
  fromBottom,
  fromLeft,
  fromRight,
  fromTop,
  fade,
}

class ViewWidget extends StatefulWidget {
  final String name;
  final String title;
  final Application application;
  final bool root;
  final Key key;

  ViewWidget(
    this.name, {
    this.title,
    this.application,
    this.root,
    this.key,
  })  : assert(name != null),
        super(key: key);

  @override
  View createState() => View();
}

abstract class ViewState<T extends ViewWidget> extends State<T> {
  String name;
  Scope scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop(result, {bool force});
}

class View<T extends ViewWidget, A extends Application> extends ViewState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  ViewActionLocator _locator;
  Scope _scope;
  Scope _parent;
  Application _application;
  ViewPanel _panel;
  ViewRefresher _refresher;
  ViewHeader _header;
  ViewFooter _footer;
  ViewAction _action;
  ViewTabs _tabs;
  _ViewParts _parts;
  bool _initialized;
  bool _initializing;
  bool _postinitialized;
  dynamic value;

  View() {
    _scaffold = GlobalKey<ScaffoldState>();
    //_locator = ViewActionLocator();
  }

  void rasterize([VoidCallback fn]) {
    if (!mounted) {
      fn?.call();
    } else {
      setState(() {
        fn?.call();
      });
    }
  }

  @protected
  Future init() async {}

  @protected
  void setup() => null;

  @override
  void didInitState() {
    _init();
  }

  Future _init() async {
    _application = arguments?.application;
    _parent = arguments?.scope;
    _scope = Scope(context, this);
    _header = header();
    _refresher = refresher();
    _panel = panel();
    _action = action();
    _tabs = tabs();
    _footer = footer();
    await _scope.setup();
    setup();
    _scope.window.overlay.apply();
  }

  @override
  initState() {
    super.initState();
    rasterize();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkParts();
    _locator = _locator ?? _action?.locator ?? ViewActionLocator();

    prebuild();
    var $drawer = drawer();

    var scaffoldContent = Scaffold(
      key: _scaffold,
      appBar: _header?.build(),
      drawer: $drawer == true ? application.navigator.drawer() : ($drawer is Drawer ? $drawer : null),
      floatingActionButton: _action?.build(),
      floatingActionButtonLocation: _locator,
      bottomNavigationBar: _footer?.build(),
      extendBody: _scope.window.overlay.extendBody,
      extendBodyBehindAppBar: _scope.window.overlay.extendBodyBehindAppBar,
      body: WillPopScope(
        onWillPop: () async {
          if (_scope.isBusy) {
            return false;
          } else {
            if (_scope.alerts.isAny) {
              await _scope.alerts.dispose();
              return false;
            } else if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
              scaffold.currentState.openEndDrawer();
              return false;
            } else if (_header is SearchHeader && (_header as SearchHeader).isActive) {
              (_header as SearchHeader).end();
              return false;
            }
            var result = await beforePop();
            if (result == true) {
              await _beginPop(null);
            }
            return result;
          }
        },
        child: Container(
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            _scope.window.update(constraints: viewportConstraints);
            return GestureDetector(
              onTap: () {
                _scope.unfocus();
                _scope.alerts.dispose();
              },
              child: _initializeContent(),
            );
          }),
        ),
      ),
    );

    if (_tabs != null) {
      return _tabs.setup(scaffoldContent);
    } else {
      return scaffoldContent;
    }
  }

  @protected
  void prebuild() {}

  @protected
  void postinit() {}

  @protected
  dynamic drawer() => null;

  @protected
  Widget content() => Container();

  @protected
  ViewHeader header() => null;

  @protected
  ViewRefresher refresher() => null;

  @protected
  ViewPanel panel() => null;

  @protected
  ViewTabs tabs() => null;

  @protected
  ViewAction action() => null;

  @protected
  ViewFooter footer() => null;

  @protected
  Future<bool> beforePop() async {
    if (scope.isBusy) {
      return false;
    } else {
      return true;
    }
  }

  @protected
  Future closing() async {}

  @protected
  Future closed() async {}

  Future<bool> dismiss() async => await pop(null);

  Future<bool> submit([value]) async => await pop(value, force: true);

  Future<bool> pop(result, {bool force}) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    if (force == true) {
      await _beginPop(result);
      return true;
    } else {
      try {
        var value = await beforePop();
        if (value == true) {
          await _beginPop(result);
          return true;
        }
      } catch (err) {}
    }
    return false;
  }

  Future<T> push<T>(ViewWidget view, {ViewTransitionType transition, int delay, ViewPushAction action}) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    var settings = RouteSettings(
        arguments: _PushedViewArguments<A>(
      application: application,
      scope: _scope,
    ));

    var $route;
    if (transition != null) {
      $route = PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => view,
        settings: settings,
        transitionDuration: Duration(milliseconds: delay ?? 200),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          if (transition == ViewTransitionType.fade) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: FadeTransition(opacity: Tween<double>(begin: 1, end: .5).animate(secondaryAnimation), child: child),
            );
          } else {
            Offset from = Offset.zero;
            Offset to = Offset.zero;

            switch (transition) {
              case ViewTransitionType.fromBottom:
                from = Offset(0, 1);
                to = Offset(0, -.5);
                break;
              case ViewTransitionType.fromLeft:
                from = Offset(-1, 0);
                to = Offset(.5, 0);
                break;
              case ViewTransitionType.fromRight:
                from = Offset(1, 0);
                to = Offset(-.5, 0);
                break;
              case ViewTransitionType.fromTop:
                from = Offset(0, -1);
                to = Offset(0, .5);
                break;
              case ViewTransitionType.fade:
            }

            return SlideTransition(
              position: Tween<Offset>(begin: from, end: Offset.zero).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset.zero, end: to).animate(secondaryAnimation),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0.5).animate(secondaryAnimation),
                  child: child,
                ),
              ),
            );
          }
        },
      );
    } else {
      $route = MaterialPageRoute(builder: (BuildContext context) => view, settings: settings);
    }

    var result;
    if (action == ViewPushAction.replace) {
      result = await Navigator.of(_scope.context).pushReplacement($route);
    } else {
      result = await Navigator.of(_scope.context).push($route);
    }

    await _scope.setup();
    if (mounted) {
      setup();
      _scope.window.overlay.apply();
      Future.delayed(Duration(milliseconds: 150), rasterize);
      Future.delayed(Duration(milliseconds: 250), rasterize);
    }
    return result as T;
  }

  void _checkParts() {
    _tabs = _tabs?.rebuild == true ? tabs() : _tabs;
    _header = _header?.rebuild == true ? header() : _header;
    _refresher = _refresher?.rebuild == true ? refresher() : _refresher;
    _panel = _panel?.rebuild == true ? panel() : _panel;
    _action = _action?.rebuild == true ? action() : _action;
    _footer = _footer?.rebuild == true ? footer() : _footer;

    _parts = _parts ??
        _ViewParts(
          header: _header,
          refresher: _refresher,
          panel: _panel,
          action: _action,
          footer: _footer,
          tabs: _tabs,
        );
  }

  Widget _initializeContent() {
    var contentResult;
    if (_tabs != null) {
      contentResult = _tabs.build(_initialized);
    } else {
      var $content = (_initialized == true ? content() : null) ?? Container();
      $content = _refresher != null ? _refresher.wrap($content) : $content;
      $content = _panel != null ? _panel.wrap($content) : $content;
      contentResult = $content;
    }

    if (_initialized != true && _initializing != true) {
      _initializing = true;
      Future.delayed(Duration(milliseconds: 0), () async {
        await init();
        _initialized = true;
        _initializing = false;
        rasterize();
      });
    } else if (_initialized == true && _postinitialized != true) {
      Future.delayed(Duration(milliseconds: 0), () async {
        postinit();
        _postinitialized = true;
        rasterize();
      });
    }
    return contentResult;
  }

  Future _beginPop(result) async {
    if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
      scaffold.currentState.openEndDrawer();
    }
    value = result ?? value;
    await closing();
    if (widget.root != true) {
      Navigator.of(_scope.context).pop(value);
    }
    await closed();
  }

  bool equals(String name) {
    return this.name == name;
  }

  String get name => widget.name;

  Scope get scope => _scope;

  Scope get parent => _parent;

  Window get window => _scope.window;

  A get application => (_application ?? widget.application) as A;

  Settings get settings => application?.settings;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;

  String get title => widget?.title ?? application.title;

  bool get isFooter => _footer != null;

  bool get isHeader => _header != null;

  _PushedViewArguments get arguments => ModalRoute.of(context).settings?.arguments;

  _ViewParts get parts => _parts;
}

enum ViewPushAction { replace, push }

class _ViewParts {
  final ViewHeader header;
  final ViewRefresher refresher;
  final ViewPanel panel;
  final ViewAction action;
  final ViewFooter footer;
  final ViewTabs tabs;

  _ViewParts({
    this.header,
    this.refresher,
    this.panel,
    this.action,
    this.footer,
    this.tabs,
  });
}

class _PushedViewArguments<A extends Application> {
  final A application;
  final Scope scope;

  _PushedViewArguments({
    @required this.application,
    @required this.scope,
  });
}
