import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:anxeb_flutter/parts/dialogs/date_time.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:anxeb_flutter/parts/dialogs/options.dart';
import 'package:flutter/material.dart';

import 'scope.dart';

class ScopeDialog {
  final Scope scope;

  @protected
  bool dismissible = false;

  ScopeDialog(this.scope) : assert(scope != null);

  @protected
  Widget build(BuildContext context) {
    return Container();
  }

  Future show() {
    return showDialog(
      context: scope.context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return build(context);
      },
    );
  }
}

class ScopeDialogs {
  Scope _scope;

  ScopeDialogs(Scope scope) {
    _scope = scope;
  }

  OptionsDialog options(String title, {IconData icon, List<KeyValue> options, String selectedValue}) {
    return OptionsDialog(
      _scope,
      title: title,
      icon: icon,
      options: options,
      selectedValue: selectedValue,
    );
  }

  MessageDialog information(String title, {String message, List<KeyValue<ResultCallback>> buttons}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: Icons.info,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.primary,
      buttons: buttons,
    );
  }

  MessageDialog success(String title, {String message, List<KeyValue<ResultCallback>> buttons}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: Icons.check_circle,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.success,
      buttons: buttons,
    );
  }

  MessageDialog exception(String title, {String message, List<KeyValue<ResultCallback>> buttons}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: Icons.error,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons,
    );
  }

  MessageDialog error(error, {List<KeyValue<ResultCallback>> buttons}) {
    return MessageDialog(
      _scope,
      title: error is FormatException ? error.message : error.toString(),
      icon: Icons.error,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons,
    );
  }

  MessageDialog confirm(String message, {String title, String yesLabel, String noLabel, Widget body}) {
    return MessageDialog(
      _scope,
      title: title ?? 'Confirmar Acción',
      message: message,
      icon: Icons.help,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: body,
      iconColor: _scope.application.settings.colors.info,
      buttons: [
        KeyValue(yesLabel ?? 'Sí', () => true),
        KeyValue(noLabel ?? 'No', () => false),
      ],
    );
  }

  DateTimeDialog dateTime([DateTime value]) {
    return DateTimeDialog(_scope, value: value);
  }
}
