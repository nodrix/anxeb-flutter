import 'dart:async';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:anxeb_flutter/parts/headers/search.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:flutter_translate/flutter_translate.dart';
import '../misc/after_init.dart';
import '../middleware/action.dart';
import '../middleware/application.dart';
import '../middleware/footer.dart';
import '../middleware/header.dart';
import '../middleware/panel.dart';
import '../middleware/refresher.dart';
import '../middleware/scope.dart';
import '../middleware/tabs.dart';
import '../middleware/view.dart';
import 'scope.dart';

enum ScreenPushAction { replace, push }

enum ScreenTransitionType {
  fromBottom,
  fromLeft,
  fromRight,
  fromTop,
  fade,
}

class ScreenWidget<A extends Application> extends StatefulWidget implements IView {
  final String name;
  final String title;
  final A application;
  final bool root;
  final Key key;

  ScreenWidget(
    this.name, {
    this.title,
    this.application,
    this.root,
    this.key,
  })  : assert(name != null),
        super(key: key);

  @override
  ScreenView createState() => ScreenView();
}

abstract class ScreenState<T extends ScreenWidget> extends State<T> {
  String name;
  ScreenScope scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop({dynamic result, bool force});

  GlobalKey<ScaffoldState> get scaffold;
}

class ScreenView<T extends ScreenWidget, A extends Application> extends ScreenState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  ScreenActionLocator _locator;
  ScreenScope _scope;
  ScreenScope _parent;
  A _application;
  ScreenPanel _panel;
  ScreenRefresher _refresher;
  ScreenHeader _header;
  ScreenFooter _footer;
  ScreenAction _action;
  ScreenTabs _tabs;
  _ScreenParts _parts;
  bool _initialized;
  bool _initializing;
  bool _postinitialized;
  dynamic value;

  @protected
  bool resizeToAvoidBottomInset;

  ScreenView() {
    _scaffold = GlobalKey<ScaffoldState>();
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
    _scope = ScreenScope(context, this);
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
    _locator = _locator ?? _action?.locator ?? ScreenActionLocator();

    prebuild();
    var $drawer = drawer();

    var scaffoldContent = Scaffold(
      key: _scaffold,
      appBar: _header?.build(),
      drawer: $drawer == true ? application.drawer(scope) : ($drawer is Drawer ? $drawer : null),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      floatingActionButton: _action?.build(),
      floatingActionButtonLocation: _locator,
      bottomNavigationBar: _footer?.build(),
      backgroundColor: _scope.application.settings.colors.background,
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
  ScreenHeader header() => null;

  @protected
  ScreenRefresher refresher() => null;

  @protected
  ScreenPanel panel() => null;

  @protected
  ScreenTabs tabs() => null;

  @protected
  ScreenAction action() => null;

  @protected
  ScreenFooter footer() => null;

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

  Future<bool> dismiss() async => await pop();

  Future<bool> submit([value]) async => await pop(result: value, force: true);

  Future<bool> pop({dynamic result, bool force}) async {
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

  Future<T> push<T>(ScreenWidget screen, {ScreenTransitionType transition, int delay, ScreenPushAction action}) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    var settings = RouteSettings(
      name: screen.name,
      arguments: _PushedScreenArguments<A>(
        application: application,
        scope: _scope,
      ),
    );

    var $route;
    if (transition != null) {
      $route = PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => screen,
        settings: settings,
        transitionDuration: Duration(milliseconds: delay ?? 200),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          if (transition == ScreenTransitionType.fade) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: FadeTransition(opacity: Tween<double>(begin: 1, end: .5).animate(secondaryAnimation), child: child),
            );
          } else {
            Offset from = Offset.zero;
            Offset to = Offset.zero;

            switch (transition) {
              case ScreenTransitionType.fromBottom:
                from = Offset(0, 1);
                to = Offset(0, -.5);
                break;
              case ScreenTransitionType.fromLeft:
                from = Offset(-1, 0);
                to = Offset(.5, 0);
                break;
              case ScreenTransitionType.fromRight:
                from = Offset(1, 0);
                to = Offset(-.5, 0);
                break;
              case ScreenTransitionType.fromTop:
                from = Offset(0, -1);
                to = Offset(0, .5);
                break;
              case ScreenTransitionType.fade:
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
      $route = MaterialPageRoute(builder: (BuildContext context) => screen, settings: settings);
    }

    var result;
    if (action == ScreenPushAction.replace) {
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

    _parts = _ScreenParts(
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

  Future process(Future Function() func, {String busyLabel}) async {
    await scope.busy(text: busyLabel ?? translate('anxeb.common.loading'));
    try {
      await func();
    } catch (err) {
      scope.alerts.error(err).show();
    } finally {
      await scope.idle();
    }
  }

  bool equals(String name) {
    return this.name == name;
  }

  String get name => widget.name;

  ScreenScope get scope => _scope;

  ScreenScope get parent => _parent;

  Window get window => _scope.window;

  A get application => (_application ?? widget.application) as A;

  Settings get settings => application?.settings;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;

  String get title => widget?.title;

  bool get isFooter => _footer != null;

  bool get isHeader => _header != null;

  ScreenActionLocator get locator => _locator;

  _PushedScreenArguments get arguments => ModalRoute.of(context).settings?.arguments;

  _ScreenParts get parts => _parts;
}

class _ScreenParts {
  final ScreenHeader header;
  final ScreenRefresher refresher;
  final ScreenPanel panel;
  final ScreenAction action;
  final ScreenFooter footer;
  final ScreenTabs tabs;

  _ScreenParts({
    this.header,
    this.refresher,
    this.panel,
    this.action,
    this.footer,
    this.tabs,
  });
}

class _PushedScreenArguments<A extends Application> {
  final A application;
  final Scope scope;

  _PushedScreenArguments({
    @required this.application,
    @required this.scope,
  });
}
