import 'package:anxeb_flutter/parts/sheets/notification.dart';
import 'package:anxeb_flutter/parts/sheets/tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'scope.dart';

class ScopeSheet {
  final Scope scope;

  ScopeSheet(this.scope);

  @protected
  Widget build(BuildContext context) {
    return Container();
  }

  Future show() async {
    return showModalBottomSheet<void>(
      context: scope.context,
      elevation: elevation,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return build(context);
      },
    );
  }

  @protected
  double get elevation => 10.0;

  @protected
  Color get barrierColor => Colors.black54;
}

class ScopeSheets {
  Scope _scope;

  ScopeSheets(Scope scope) {
    _scope = scope;
  }

  TipSheet success(String title, {String message, Widget body}) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.success,
      foreground: Colors.white,
      message: message,
      body: body,
      icon: Icons.check_circle,
    );
  }

  TipSheet information(String title, {String message, Widget body}) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.info,
      foreground: Colors.white,
      message: message,
      body: body,
      icon: Icons.info,
    );
  }

  TipSheet tip(String title, {String message, Widget body}) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.tip,
      message: message,
      body: body,
      icon: Ionicons.md_bulb,
    );
  }

  TipSheet warning(String title, {String message, Widget body}) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.danger,
      foreground: Colors.white,
      message: message,
      body: body,
      icon: Icons.warning,
    );
  }

  TipSheet neutral(String title, {String message, Widget body}) {
    return TipSheet(
      _scope,
      title: title,
      fill: Colors.white,
      message: message,
      body: body,
      icon: Icons.chat,
    );
  }

  TipSheet flat(String title, {String message, Widget body, IconData icon}) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.navigation,
      message: message,
      body: body,
      flat: true,
      foreground: Colors.white,
      icon: icon ?? Icons.info_outline,
    );
  }

  NotificationSheet notification({String title, String message, String imageUrl, Widget body, IconData icon, List<NotificationSheetAction> actions, VoidCallback onDelete, DateTime date}) {
    return NotificationSheet(
      _scope,
      title: title,
      message: message,
      body: body,
      actions: actions,
      onDelete: onDelete,
      icon: icon,
      date: date,
      imageUrl: imageUrl,
    );
  }
}
