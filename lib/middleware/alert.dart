import 'package:anxeb_flutter/services/alerts/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'scope.dart';

class Alert {
  final Scope scope;

  bool _disposed = false;

  Alert(this.scope);

  void dispose({bool quick}) {
    if (_disposed == false) {
      _disposed = true;
      try {
        if (quick == true) {
          scope.scaffold.currentState.removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
        } else {
          scope.scaffold.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
        }
      } catch (err) {}
    }
  }

  @protected
  Widget build() {
    return Container();
  }

  Future show() async {
    if (_disposed == false) {
      await scope.idle();
      return await scope.scaffold.currentState.showSnackBar(build()).closed;
    } else {
      return null;
    }
  }
}

class ScopeAlerts {
  Scope _scope;
  Alert _current;

  ScopeAlerts(Scope scope) {
    _scope = scope;
  }

  void dispose({bool quick}) {
    if (_current != null) {
      _current.dispose(quick: quick);
    }
  }

  bool get isAny {
    return !(_current == null || _current._disposed);
  }

  Alert _initialize(Alert current) {
    dispose();
    _current = current;
    return current;
  }

  SnackAlert information(String title, {String message, int delay}) => _initialize(SnackAlert(
        _scope,
        title: title,
        message: message,
        icon: Icons.info,
        color: _scope.application.settings.colors.info,
        delay: delay,
      ));

  SnackAlert success(String title, {String message, int delay}) => _initialize(SnackAlert(
        _scope,
        title: title,
        message: message,
        icon: Icons.check_circle,
        color: _scope.application.settings.colors.success,
        delay: delay,
      ));

  SnackAlert asterisk(String title, {String message, int delay}) => _initialize(SnackAlert(
        _scope,
        title: title,
        message: message,
        icon: FlutterIcons.asterisk_mco,
        color: _scope.application.settings.colors.asterisk,
        delay: delay,
      ));

  SnackAlert exception(err, {String title, int delay}) {
    String message;

    if (err is AssertionError) {
      message = err.message;

      print('\n');
      print('-----------[ INTERNAL EXCEPTION ]-----------\n');
      print(message);
      print('\n');
      print(err.stackTrace);
      print('\n');
    } else if (err is Error) {
      message = err.toString();
      print('\n');
      print('-----------[ INTERNAL EXCEPTION ]-----------\n');
      print(message);
      print('\n');
      print(err.stackTrace);
      print('\n');
    } else if (err is String) {
      message = err.toString();
    } else {
      if (err.message != null) {
        message = err.message;
      } else if (err.data != null && err.data.message != null) {
        message = err.data.message;
      }
    }

    return _initialize(SnackAlert(
      _scope,
      title: title ?? 'Error',
      message: message,
      icon: Icons.warning,
      color: _scope.application.settings.colors.danger,
      delay: delay,
    ));
  }
}
