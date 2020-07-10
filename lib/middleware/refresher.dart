import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'scope.dart';

class ViewRefresher {
  final Scope scope;
  final Future Function() action;
  final Future Function() onCompleted;
  final Future Function(dynamic err) onError;
  RefreshController _refreshController;

  ViewRefresher({this.scope, this.action, this.onCompleted, this.onError}) {
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
          onCompleted?.call();
        } catch (err) {
          onError?.call(err);
        }
      },
      child: body,
    );
  }

  void scrollToEnd() {
    // ignore: deprecated_member_use
    _refreshController.scrollController.animateTo(_refreshController.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void scrollToStart() {
    // ignore: deprecated_member_use
    _refreshController.scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  bool get rebuild => false;
}
