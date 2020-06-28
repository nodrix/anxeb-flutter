import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'scope.dart';

class ViewRefresher {
  final Scope scope;
  final Future Function() action;
  final Future Function(dynamic err) completed;
  RefreshController _refreshController;

  ViewRefresher({
    this.scope,
    this.action,
    this.completed,
  }) {
    _refreshController = RefreshController(initialRefresh: false);
  }

  Widget wrap(Widget body) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      footer: null,
      header: WaterDropHeader(
        completeDuration: Duration(milliseconds: 0),
        waterDropColor: scope.application.settings.colors.primary,
        complete: Container(),
        failed: Container(),
        refresh: Container(),
      ),
      onRefresh: () async {
        _refreshController.refreshCompleted();
        try {
          await action();
          completed(null);
        } catch (err) {
          completed(err);
        }
      },
      child: body,
    );
  }
}
