import 'dart:async';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';

enum PagePushAction { replace, push }

class PageMiddleware<A extends Application, M extends PageInfo> {
  final A application;
  final Future<String> Function(BuildContext context, GoRouterState state, PageScope<A, M> scope, [M info]) redirect;

  M info;

  PageScope<A, M> get scope => info?.scope;

  PageMiddleware({@required this.application, this.redirect});
}

class PageWidget<A extends Application, M extends PageInfo> extends StatefulWidget implements IView {
  final String name;
  final String path;
  final Key key;
  final _PageArgs _inmeta = _PageArgs<A, M>();

  PageWidget(
    this.name, {
    @required this.path,
    this.key,
  })  : assert(path != null),
        super(key: key);

  @override
  PageView createState() => PageView();

  @protected
  List<PageWidget Function()> childs() {
    return [];
  }

  Future init(PageMiddleware<A, M> middleware, {BuildContext context, GoRouterState state, M parent}) async {
    _inmeta.middleware = middleware;
    if (context != null) {
      prepare(context, state, parent: parent);
    }
  }

  void prepare(BuildContext context, GoRouterState state, {PageContainer<A, M> container, M parent}) {
    _inmeta.info = _inmeta.info ?? this.setup?.call(state) ?? PageInfo();

    _inmeta.info._name = state.name;
    _inmeta.info._context = context;
    _inmeta.info._state = state;
    _inmeta.info._container = container;
    _inmeta.info._parent = parent;
    middleware.info = _inmeta.info;

    if (state.extra != null && (state.extra as dynamic)['preload'] != null) {
      if (state.matchedLocation == state.location) {
        var obj = (state.extra as dynamic);
        if (obj['preload'] is Function) {
          obj['preload'](_inmeta.info);
          obj['preload'] = null;
        }
      }
    }
  }

  @protected
  M setup(GoRouterState state) => null;

  Future<String> redirect(BuildContext context, GoRouterState state) async {
    if (info == null) {
      prepare(context, state);
    }
    return await middleware?.redirect?.call(context, state, info?.scope ?? middleware.scope, info);
  }

  List<RouteBase> getRoutes([String prefix]) {
    final items = childs();
    var routes = <RouteBase>[];

    for (var i = 0; i < items.length; i++) {
      final getPage = items[i];
      final page = getPage();
      page.init(middleware);

      final $name = page.name.startsWith('_') ? '${prefix ?? name}${page.name}' : page.name;

      routes.add(GoRoute(
        name: $name,
        path: page.path,
        pageBuilder: (context, state) {
          page.prepare(context, state, parent: info);
          return transitionBuilder(context: context, state: state, child: page);
        },
        redirect: (context, GoRouterState state) async {
          return await page.redirect(context, state);
        },
        routes: page.getRoutes($name),
      ));
    }
    return routes;
  }

  static CustomTransitionPage transitionBuilder<T>({@required BuildContext context, @required GoRouterState state, @required Widget child}) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration(milliseconds: 50),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    );
  }

  M get info => _inmeta.info;

  PageMiddleware<A, M> get middleware => _inmeta.middleware;

  A get application => middleware.application;
}

abstract class PageState<T extends PageWidget, A extends Application, M extends PageInfo> extends State<T> {
  String path;

  PageScope<A, M> scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop({dynamic result, bool force});
}

class PageView<T extends PageWidget, A extends Application, M extends PageInfo> extends PageState<T, A, M> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  PageScope<A, M> _scope;
  bool _initialized;
  bool _initializing;
  bool _postinitialized;

  PageView() {
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

  @override
  void initState() {
    super.initState();
  }

  @protected
  Future setup([dynamic value]) => null;

  @override
  void didInitState() {
    _init();
  }

  Future _init() async {
    _scope = PageScope(context, this);
    widget.info._scope = _scope;
    await _scope.setup();
    widget.info._onChildPoped = ([value]) async {
      await setup();
      rasterize();
    };

    if (_initialized != true && _initializing != true) {
      _initializing = true;
      await init();
      if (info.state.matchedLocation == info.state.location) {
        setup().then((value) {
          rasterize();
        });
      }
      _initialized = true;
      _initializing = false;
    } else if (_initialized == true && _postinitialized != true) {
      postinit();
      _postinitialized = true;
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    prebuild();
    var $drawer = drawer();

    var scaffoldContent = Scaffold(
      key: _scaffold,
      resizeToAvoidBottomInset: true,
      drawer: $drawer == true ? application.drawer(scope) : ($drawer is Drawer ? $drawer : null),
      backgroundColor: application.settings.colors.background,
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
              child: (_initialized == true ? content() : null) ?? Container(),
            );
          }),
        ),
      ),
    );

    return scaffoldContent;
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
    await scope.idle();
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

  void go(String route, {bool force, Map<String, String> params, Map<String, dynamic> query, void Function(M info) preload}) async {
    await scope.idle();

    var value = force == true ? true : await beforePop();
    if (value == true) {
      await scope.alerts.dispose(quick: true);
      if (params != null) {
        scope.context.goNamed(route, pathParameters: params, queryParameters: query ?? Map(), extra: {'preload': preload});
      } else {
        scope.context.go(route);
      }
    }
  }

  Future push(String route, {bool force, Map<String, String> params, Map<String, dynamic> query}) async {
    await scope.idle();

    var value = force == true ? true : await beforePop();
    if (value == true) {
      await scope.alerts.dispose(quick: true);
      if (params != null) {
        scope.context.pushNamed(route, pathParameters: params, queryParameters: query ?? Map());
      } else {
        scope.context.push(route);
      }
    }
  }

  Future _beginPop(result) async {
    await closing();
    if (info?.parent != null) {
      info?.parent?._onChildPoped?.call(result);
    }
    _scope.context.pop();
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

  bool equals(String path) {
    return this.path == path;
  }

  String get path => widget.path;

  PageScope<A, M> get scope => _scope;

  Window get window => _scope.window;

  A get application => widget.middleware.application;

  Settings get settings => application?.settings;

  M get info => widget.info;

  PageContainer<A, M> get container => info.container;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;
}

class _PageArgs<A extends Application, M extends PageInfo> {
  M info;

  PageMiddleware<A, M> middleware;
}

class PageInfo {
  String _name;
  BuildContext _context;
  GoRouterState _state;
  PageContainer _container;
  PageInfo _parent;
  PageScope _scope;
  Function([dynamic value]) _onChildPoped;

  String get name => _name;

  BuildContext get context => _context;

  GoRouterState get state => _state;

  PageContainer get container => _container;

  PageInfo get parent => _parent;

  PageScope get scope => _scope;
}
