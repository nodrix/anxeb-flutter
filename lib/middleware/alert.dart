import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/parts/alerts/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'scope.dart';

class ScopeAlert {
  final Scope scope;
  bool _disposed = false;

  ScopeAlert(this.scope);

  Future dispose({bool quick}) async {
    _disposed = true;
  }

  @protected
  Future build() {
    return Future.value(null);
  }

  Future show() async {
    if (_disposed == false) {
      scope.unfocus();
      scope.rasterize();
      await scope.idle();
      var result = await build();
      _disposed = true;
      return result;
    } else {
      return null;
    }
  }
}

class ScopeAlerts {
  Scope _scope;
  ScopeAlert _current;

  ScopeAlerts(Scope scope) {
    _scope = scope;
  }

  Future dispose({bool quick}) async {
    if (_current != null) {
      await _current.dispose(quick: quick);
    }
  }

  bool get isAny {
    return !(_current == null || _current._disposed);
  }

  ScopeAlert _initialize(ScopeAlert current) {
    dispose();
    _current = current;
    return current;
  }

  SnackAlert notification(String title, {String message, int delay, Color color}) {
    _scope.application?.onEvent?.call(ApplicationEventType.notification, reference: title, description: message);
    return _initialize(SnackAlert(
      _scope,
      title: title,
      message: message,
      icon: Icons.notifications,
      fillColor: color ?? _scope.application.settings.colors.info,
      delay: delay,
    ));
  }

  SnackAlert information(String title, {String message, int delay}) {
    _scope.application?.onEvent?.call(ApplicationEventType.information, reference: title, description: message);
    return _initialize(SnackAlert(
      _scope,
      title: title,
      message: message,
      icon: Icons.info,
      fillColor: _scope.application.settings.colors.info,
      delay: delay,
    ));
  }

  SnackAlert success(String title, {String message, int delay}) {
    _scope.application?.onEvent?.call(ApplicationEventType.success, reference: title, description: message);
    return _initialize(SnackAlert(
      _scope,
      title: title,
      message: message,
      icon: Icons.check_circle,
      fillColor: _scope.application.settings.colors.success,
      delay: delay,
    ));
  }

  SnackAlert event(String title, {String message, int delay}) {
    _scope.application?.onEvent?.call(ApplicationEventType.action, reference: title, description: message);
    return _initialize(SnackAlert(
      _scope,
      title: title,
      message: message,
      icon: Icons.check_circle,
      fillColor: _scope.application.settings.colors.primary,
      delay: delay,
    ));
  }

  SnackAlert asterisk(String title, {String message, int delay}) {
    _scope.application?.onEvent?.call(ApplicationEventType.asterisk, reference: title, description: message);
    return _initialize(SnackAlert(
      _scope,
      title: title,
      message: message,
      icon: FlutterIcons.asterisk_mco,
      fillColor: _scope.application.settings.colors.asterisk,
      delay: delay,
    ));
  }

  SnackAlert exception(String message, {String title, int delay}) {
    _scope.application?.onEvent?.call(ApplicationEventType.exception, reference: title ?? message, description: title == null ? null : message);
    return _initialize(SnackAlert(
      _scope,
      title: title ?? translate('anxeb.common.error'),
      message: message,
      icon: Icons.warning,
      fillColor: _scope.application.settings.colors.danger,
      delay: delay,
    ));
  }

  SnackAlert error(err, {String title, int delay}) {
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

    _scope.application?.onEvent?.call(ApplicationEventType.error, reference: title, description: message, data: err);

    return _initialize(SnackAlert(
      _scope,
      title: title ?? translate('anxeb.common.error'),
      //TR 'Error',
      message: message,
      icon: Icons.warning,
      fillColor: _scope.application.settings.colors.danger,
      delay: delay,
    ));
  }
}
