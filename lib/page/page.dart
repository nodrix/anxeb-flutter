import 'dart:async';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';

enum PagePushAction { replace, push }

typedef PageRedirectHandler = Future<String> Function(BuildContext context, GoRouterState state, PageScope scope, [PageInfo info]);

class PageMiddleware {
  final Application application;
  final PageRedirectHandler redirect;

  PageInfo info;

  PageScope get scope => info?.scope;

  PageMiddleware({@required this.application, this.redirect});
}

class PageWidget extends StatefulWidget implements IView {
  final String name;
  final String path;
  final String title;
  final Key key;
  final dynamic _inmeta = {};

  PageWidget(this.name, {
    @required this.path,
    this.key,
    this.title,
  })
      : assert(path != null),
        super(key: key);

  @override
  PageView createState() => PageView();

  @protected
  List<PageWidget Function()> childs() {
    return [];
  }

  Future init(PageMiddleware middleware, [BuildContext context, GoRouterState state, PageInfo parent]) async {
    _inmeta['middleware'] = middleware;
    if (context != null) {
      await prepare(context, state, parent);
    }
  }

  Future prepare(BuildContext context, GoRouterState state, [PageInfo parent]) async {
    _inmeta['info'] = PageInfo(
      name: name,
      title: title,
      context: context,
      state: state,
      parent: parent,
      meta: meta,
    );
    middleware.info = info;
  }

  @protected
  dynamic get meta => {};

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
          page.prepare(context, state, info);
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

  PageInfo get info => _inmeta['info'] as PageInfo;

  PageMiddleware get middleware => _inmeta['middleware'] as PageMiddleware;

  Application get application => middleware.application;
}

abstract class PageState<T extends PageWidget> extends State<T> {
  String path;

  PageScope scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop({dynamic result, bool force});
}

class PageView<T extends PageWidget, A extends Application> extends PageState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  PageScope _scope;
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
    _scope = PageScope(context, this);
    await _scope.setup();
    widget.info.scope = _scope;
    setup();
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

  //Page.info.meta debe guardarse en un arreglo cuando se instancian los pages en entry. Este deberia ser consumido en cada redirect mapeando un meta por cada instancia.. ese meta puede ser modificado en un constructor del page si es necesario

  /*Future<T> push<T>(PageWidget page, {PagePushAction action}) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    var settings = RouteSettings(
      name: screen.name,
      arguments: _PushedScreenArguments<A>(
        application: application,
        scope: _scope,
      ),
    );

    var result;
    if (action == ScreenPushAction.replace) {
      //result = await Navigator.of(_scope.context).pushReplacement($route);
      _scope.context.pushReplacement(location)
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
  }*/

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

  PageScope get scope => _scope;

  Window get window => _scope.window;

  A get application => widget.middleware.application as A;

  Settings get settings => application?.settings;

  PageInfo get info => widget.info;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;
}

class PageInfo<A extends Application> {
  final String name;
  final String title;
  final BuildContext context;
  final GoRouterState state;
  final PageInfo parent;
  dynamic meta = {};
  PageScope scope;
  dynamic value;

  PageInfo({
    @required this.name,
    @required this.title,
    @required this.context,
    @required this.state,
    this.parent,
    this.meta,
  });
}
