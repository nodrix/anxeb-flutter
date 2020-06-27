import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'scope.dart';

class ViewRefresher {
  final Scope scope;
  final Future Function() action;
  final Future Function(dynamic err) completed;
  final IconData completedIcon;
  final String completedText;
  final IconData busyIcon;
  final String busyText;
  final IconData failedIcon;
  final String failedText;

  RefreshController _refreshController;

  ViewRefresher({
    this.scope,
    this.action,
    this.completed,
    this.completedIcon,
    this.completedText,
    this.busyIcon,
    this.busyText,
    this.failedIcon,
    this.failedText,
  }) {
    _refreshController = RefreshController(initialRefresh: false);
  }

  Widget wrap(Widget body) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(
        completeDuration: Duration(milliseconds: 400),
        complete: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(completedIcon ?? Icons.check_circle_outline, color: scope.application.settings.colors.success, size: 30),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(completedText ?? 'Actualización Completada', style: TextStyle(fontSize: 18, color: scope.application.settings.colors.success)),
              )
            ],
          ),
        ),
        failed: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(failedIcon ?? Icons.error_outline, color: scope.application.settings.colors.danger, size: 30),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(failedText ?? 'Error Actualizando', style: TextStyle(fontSize: 18, color: scope.application.settings.colors.danger)),
            )
          ],
        ),
        refresh: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(busyIcon ?? Icons.sync, color: scope.application.settings.colors.success, size: 30),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(busyText ?? 'Actualizado Vista', style: TextStyle(fontSize: 18, color: scope.application.settings.colors.success)),
            )
          ],
        ),
      ),
      controller: _refreshController,
      onRefresh: () async {
        try {
          await action();
          _refreshController.refreshCompleted();
          completed(null);
        } catch (err) {
          _refreshController.refreshFailed();
          completed(err);
        }
      },
      child: body,
    );
  }
}
