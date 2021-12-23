import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ViewHeader {
  final Scope scope;
  final List<Widget> childs;
  final VoidCallback dismiss;
  final VoidCallback back;
  final String Function() title;
  final double Function() elevation;
  final double Function() height;
  final Widget Function() bottom;
  final bool Function() isVisible;
  final Color Function() fill;
  Widget leading;

  ViewHeader({
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
      title: body?.call() ?? Text(this.title?.call() ?? scope.view.title ?? scope.application.title),
      elevation: elevation?.call(),
      automaticallyImplyLeading: (back == null && dismiss == null && leading == null) ? true : false,
      leading: leading ?? (back != null ? BackButton(onPressed: back) : (dismiss != null ? CloseButton(onPressed: dismiss) : null)),
      backgroundColor: fill?.call() ?? scope.application.settings.colors.primary,
      bottom: scope?.view?.parts?.tabs?.header?.call(bottomBody: bottom?.call(), height: height) ?? bottom?.call(),
      actions: isVisible?.call() != false ? content() : [],
    );
  }

  bool get rebuild => false;
}
