import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/scope.dart';
import 'screen.dart';

class ScreenScope extends Scope implements IScope {
  final ScreenView view;

  ScreenScope(BuildContext context, this.view) : super(context);

  GlobalKey<ScaffoldState> get scaffold => view.scaffold;

  @override
  Future<bool> dismiss() => view.dismiss();

  Future<T> push<T>(ScreenWidget screen, {ScreenTransitionType transition, int delay, ScreenPushAction action}) async {
    return view.push(screen, transition: transition, action: action);
  }

  @override
  Application get application => view.application;

  @override
  String get key => view.name;

  @override
  String get title => view.title;

  @override
  bool get mounted => view.mounted == true;

  @override
  void rasterize([VoidCallback fn]) {
    view.rasterize(fn);
  }
}