import 'package:flutter/material.dart' hide Overlay;
import 'package:go_router/go_router.dart';
import '../middleware/application.dart';
import 'page.dart';
import 'scope.dart';

class PageContainer<A extends Application> {
  final Key key;
  PageMiddleware _middleware;
  BuildContext _context;
  GoRouterState _state;

  PageContainer({this.key});

  @protected
  Future setup() async {}

  Widget build(BuildContext context, GoRouterState state, Widget child) {
    return child;
  }

  @protected
  List<PageWidget Function()> pages() {
    return [];
  }

  Future init(PageMiddleware middleware) async {
    _middleware = middleware;
    setup();
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
          page.prepare(context, state);
          return PageWidget.transitionBuilder<void>(context: context, state: state, child: page);
        },
        redirect: (context, GoRouterState state) async {
          return await page.redirect(context, state);
        },
        routes: page.getRoutes(),
      ));
    }
    return routes;
  }

  PageMiddleware get middleware => _middleware;

  A get application => _middleware.application as A;

  PageScope get scope => _middleware.scope;

  PageInfo get info => _middleware.info;

  BuildContext get context => _context;

  GoRouterState get state => _state;
}
