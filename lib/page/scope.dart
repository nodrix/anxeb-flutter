import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/widgets.dart';
import '../middleware/application.dart';
import '../middleware/scope.dart';

class PageScope<A extends Application> extends Scope implements IScope {
  Anxeb.PageView view;

  PageScope(BuildContext context, this.view) : super(context);

  void go(String route, {Map<String, String> params, Map<String, dynamic> query}) async => view.go(route, params: params, query: query);

  void push(String route, {Map<String, String> params, Map<String, dynamic> query}) async => view.push(route, params: params, query: query);

  @override
  A get application => view.application as A;

  @override
  String get key => view.path;

  @override
  String get title => view.title;

  @override
  bool get mounted => view.mounted == true;

  @override
  void rasterize([VoidCallback fn]) {
    view.rasterize(fn);
  }
}
