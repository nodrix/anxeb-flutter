import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ViewHeader {
  final Scope scope;
  final List<Widget> childs;
  final VoidCallback dismiss;
  final VoidCallback back;
  final String Function() title;
  Widget leading;

  ViewHeader({
    @required this.scope,
    this.childs,
    this.dismiss,
    this.back,
    this.leading,
    this.title,
  });

  @protected
  List<Widget> content() => childs;

  @protected
  Widget body() => null;

  PreferredSizeWidget build() {
    return AppBar(
      title: body?.call() ?? Text(this.title?.call() ?? scope.view.title ?? scope.application.title),
      automaticallyImplyLeading: (back == null && dismiss == null && leading == null) ? true : false,
      leading: leading ?? (back != null ? BackButton(onPressed: back) : (dismiss != null ? CloseButton(onPressed: dismiss) : null)),
      brightness: scope.window.overlay.brightness,
      backgroundColor: scope.application.settings.colors.primary,
      bottom: scope?.view?.parts?.tabs?.header?.call(),
      actions: content(),
    );
  }

  bool get rebuild => false;
}
