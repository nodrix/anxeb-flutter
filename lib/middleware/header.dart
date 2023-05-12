import 'package:flutter/material.dart';
import '../screen/scope.dart';

class ScreenHeader {
  final ScreenScope scope;
  final List<Widget> childs;
  final VoidCallback dismiss;
  final VoidCallback back;
  final Widget Function() title;
  final double Function() elevation;
  final double Function() height;
  final Widget Function() bottom;
  final bool Function() isVisible;
  final Color Function() fill;
  Widget leading;

  ScreenHeader({
    @required this.scope,
    this.childs,
    this.dismiss,
    this.back,
    this.leading,
    this.title,
    this.elevation,
    this.height,
    this.bottom,
    this.isVisible,
    this.fill,
  });

  @protected
  List<Widget> content() => childs;

  @protected
  Widget body() => null;

  PreferredSizeWidget build() {
    return AppBar(
      title: body?.call() ?? this.title?.call() ?? (scope.view.title != null ? Text(scope.view.title) : null),
      elevation: elevation?.call(),
      automaticallyImplyLeading: (back == null && dismiss == null && leading == null) ? true : false,
      leading: leading ?? (back != null ? BackButton(onPressed: back) : (dismiss != null ? CloseButton(onPressed: dismiss) : null)),
      backgroundColor: scope.window?.overlay?.background ?? fill?.call() ?? scope.application.settings.colors.primary,
      bottom: scope?.view?.parts?.tabs?.header?.call(bottomBody: bottom?.call(), height: height) ?? bottom?.call(),
      actions: isVisible?.call() != false ? content() : [],
    );
  }

  bool get rebuild => false;
}
