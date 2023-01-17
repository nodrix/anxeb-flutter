import 'package:flutter/material.dart' hide Overlay;
import 'package:go_router/go_router.dart';
import '../middleware/application.dart';
import 'page.dart';
import 'scope.dart';

class _ContainerBlock extends StatefulWidget {
  final PageWidget child;

  _ContainerBlock({Key key, this.child}) : super(key: key);

  @override
  _ContainerBlockState createState() => _ContainerBlockState();
}

class _ContainerBlockState extends State<_ContainerBlock> {
  void rasterize([VoidCallback fn]) => setState(fn ?? (() {}));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class PageContainer<A extends Application, M> {
  PageMiddleware<A, M> _middleware;
  BuildContext _context;
  GoRouterState _state;
  GlobalKey<_ContainerBlockState> _key;

  @protected
  Future setup() async {}

  Widget build(BuildContext context, GoRouterState state, Widget child) {
    return child;
  }

  Future rasterize() async {
    if (_key?.currentState?.mounted == true) {
      _key.currentState.rasterize();
    }
  }

  @protected
  List<PageWidget Function()> pages() {
    return [];
  }

  Future init(PageMiddleware<A, M> middleware) async {
    _middleware = middleware;
    await setup();
    await rasterize();
  }

  Future prepare(BuildContext context, GoRouterState state) async {
    _context = context;
    _state = state;
  }

  List<RouteBase> getRoutes() {
    var routes = <RouteBase>[];
    final items = pages();

    for (var i = 0; i < items.length; i++) {
      final getPage = items[i];
      final page = getPage();
      page.init(_middleware);

      routes.add(GoRoute(
        name: page.name,
        path: '/${page.path}',
        pageBuilder: (context, state) {
          _key = GlobalKey();
          page.prepare(context, state, container: this);
          return PageWidget.transitionBuilder<void>(context: context, state: state, child: _ContainerBlock(key: _key, child: page));
        },
        redirect: (context, GoRouterState state) async {
          return await page.redirect(context, state);
        },
        routes: page.getRoutes(),
      ));
    }
    return routes;
  }

  PageMiddleware<A, M> get middleware => _middleware;

  A get application => _middleware.application;

  PageScope<A> get scope => _middleware.scope;

  PageInfo<A, M> get info => _middleware.info;

  M get meta => info.meta;

  BuildContext get context => _context;

  GoRouterState get state => _state;
}
