import 'dart:async';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';

enum PagePushAction { replace, push }

typedef PageRedirectHandler<M> = Future<String> Function(BuildContext context, GoRouterState state, PageScope<Application> scope, [PageInfo<Application, M> info]);

class PageMiddleware<A extends Application, M> {
  final A application;
  final PageRedirectHandler redirect;

  PageInfo<A, M> info;

  PageScope<A> get scope => info?.scope;

  PageMiddleware({@required this.application, this.redirect});
}

class PageWidget<A extends Application, M> extends StatefulWidget implements IView {
  final String name;
  final String path;
  final String title;
  final Key key;
  final _PageArgs _inmeta = _PageArgs();

  PageWidget(
    this.name, {
    @required this.path,
    this.key,
    this.title,
  })  : assert(path != null),
        super(key: key);

  @override
  PageView createState() => PageView();

  @protected
  List<PageWidget Function()> childs() {
    return [];
  }

  Future init(PageMiddleware<A, M> middleware, {BuildContext context, GoRouterState state, PageInfo<A, M> parent}) async {
    _inmeta.middleware = middleware;
    if (context != null) {
      await prepare(context, state, parent: parent);
    }
  }

  Future prepare(BuildContext context, GoRouterState state, {PageContainer<A, M> container, PageInfo<A, M> parent}) async {
    _inmeta.info = PageInfo<A, M>(
      name: name,
      title: title,
      context: context,
      state: state,
      container: container,
      parent: parent,
      meta: meta?.call(),
    );
    middleware.info = info;
  }

  @protected
  M meta() => null;

  Future<String> redirect(BuildContext context, GoRouterState state) async {
    if (info == null) {
      prepare(context, state);
    }
    return await middleware?.redirect?.call(context, state, info?.scope ?? middleware.scope, info);
  }

  List<RouteBase> getRoutes() {
    final items = childs();
    var routes = <RouteBase>[];

    for (var i = 0; i < items.length; i++) {
      final getPage = items[i];
      final page = getPage();
      page.init(middleware);

      routes.add(GoRoute(
        name: '${name}_${page.name}',
        path: page.path,
        pageBuilder: (context, state) {
          page.prepare(context, state, parent: info);
          return transitionBuilder<void>(context: context, state: state, child: page);
        },
        redirect: (context, GoRouterState state) async {
          return await page.redirect(context, state);
        },
        routes: page.getRoutes(),
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

  PageInfo<A, M> get info => _inmeta.info;

  PageMiddleware<A, M> get middleware => _inmeta.middleware;

  A get application => middleware.application;
}

abstract class PageState<T extends PageWidget> extends State<T> {
  String path;

  PageScope scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop({dynamic result, bool force});
}

class PageView<T extends PageWidget, A extends Application, M> extends PageState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  PageScope<A> _scope;
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

  @protected
  void setup() => null;

  @override
  void didInitState() {
    _init();
  }

  Future _init() async {
    _scope = PageScope<A>(context, this);
    await _scope.setup();
    widget.info.scope = _scope;
    setup();
    container?.rasterize?.call();
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
    if (widget.info.scope == null) {
      widget.info.scope = _scope;
    }
    prebuild();
    var scaffoldContent = Scaffold(
      key: _scaffold,
      resizeToAvoidBottomInset: true,
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
              child: _initializeContent(),
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

  void go(String route) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);
    scope.context.go(route);
    await scope.setup();
    if (mounted) {
      setup();
    }
  }

  Widget _initializeContent() {
    var contentResult;
    var $content = (_initialized == true ? content() : null) ?? Container();
    contentResult = $content;

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
    await closing();
    if (result != null) {
      info.value = result;
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

  String get title => widget?.title ?? application.title;

  PageScope<A> get scope => _scope;

  Window get window => _scope.window;

  A get application => widget.middleware.application as A;

  Settings get settings => application?.settings;

  M get meta => info?.meta;

  PageInfo<A, M> get info => widget.info;

  PageContainer<A, M> get container => info.container;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;
}

class _PageArgs<A extends Application, M> {
  PageInfo<A, M> info;

  PageMiddleware<A, M> middleware;
}

class PageInfo<A extends Application, M> {
  final String name;
  final String title;
  final BuildContext context;
  final GoRouterState state;
  final PageContainer<A, M> container;
  final PageInfo<A, M> parent;
  M meta;
  PageScope<A> scope;
  dynamic value;

  PageInfo({
    @required this.name,
    @required this.title,
    @required this.context,
    @required this.state,
    this.container,
    this.parent,
    this.meta,
  });
}
