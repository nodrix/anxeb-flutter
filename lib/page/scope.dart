import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/widgets.dart';
import '../middleware/application.dart';
import '../middleware/scope.dart';
import 'page.dart';

class PageScope<A extends Application, M extends PageInfo> extends Scope implements IScope {
  Anxeb.PageView<PageWidget, A, M> view;

  PageScope(BuildContext context, this.view) : super(context);

  void go(String route, {bool force, Map<String, String> params, Map<String, dynamic> query, void Function(M info) preload}) async => view.go(route, force: force, params: params, query: query, preload: preload);

  void push(String route, {Map<String, String> params, Map<String, dynamic> query}) async => view.push(route, params: params, query: query);

  @override
  A get application => view.application;

  @override
  String get key => view.path;

  @override
  bool get mounted => view.mounted == true;

  @override
  void rasterize([VoidCallback fn]) {
    view.rasterize(fn);
  }
}
