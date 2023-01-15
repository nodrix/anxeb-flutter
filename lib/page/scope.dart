import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/widgets.dart';
import '../middleware/application.dart';
import '../middleware/scope.dart';

class PageScope extends Scope implements IScope {
  Anxeb.PageView view;

  PageScope(BuildContext context, this.view) : super(context);

  void go(String route) async {
    return view.go(route);
  }

  @override
  Application get application => view.application;

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
