import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:anxeb_flutter/parts/dialogs/date_time.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:anxeb_flutter/parts/dialogs/options.dart';
import 'package:anxeb_flutter/parts/dialogs/referencer.dart';
import 'package:flutter/material.dart';
import 'scope.dart';

class ScopeDialog<V> {
  final Scope scope;
  @protected
  bool dismissible = false;

  ScopeDialog(this.scope) : assert(scope != null);

  @protected
  Widget build(BuildContext context) {
    return Container();
  }

  @protected
  Future setup() => null;

  Future<V> show() async {
    await setup();
    return showDialog<V>(
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

  ReferencerDialog referencer<V>(
    String title, {
    IconData icon,
    ReferenceLoaderHandler<V> loader,
    ReferenceComparerHandler<V> comparer,
    Function() updater,
    ReferenceItemWidget<V> itemWidget,
    ReferenceHeaderWidget<V> headerWidget,
  }) {
    return ReferencerDialog<V>(
      _scope,
      title: title,
      icon: icon,
      referencer: Referencer<V>(loader: loader, comparer: comparer, updater: updater),
      itemWidget: itemWidget,
      headerWidget: headerWidget,
    );
  }

  OptionsDialog options<V>(String title, {IconData icon, List<KeyValue<V>> options, V selectedValue}) {
    return OptionsDialog<V>(
      _scope,
      title: title,
      icon: icon,
      options: options,
      selectedValue: selectedValue,
    );
  }

  MessageDialog information(String title, {String message, List<KeyValue<ResultCallback>> buttons, IconData icon}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: icon ?? Icons.info,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.primary,
      buttons: buttons,
    );
  }

  MessageDialog success(String title, {String message, List<KeyValue<ResultCallback>> buttons, IconData icon}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: icon ?? Icons.check_circle,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.success,
      buttons: buttons,
    );
  }

  MessageDialog exception(String title, {String message, List<KeyValue<ResultCallback>> buttons, IconData icon}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: icon ?? Icons.error,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons,
    );
  }

  MessageDialog error(error, {List<KeyValue<ResultCallback>> buttons, IconData icon}) {
    return MessageDialog(
      _scope,
      title: error is FormatException ? error.message : error.toString(),
      icon: icon ?? Icons.error,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons,
    );
  }

  MessageDialog confirm(String message, {String title, String yesLabel, String noLabel, Widget body, bool swap}) {
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
      buttons: swap == true
          ? [
              KeyValue(noLabel ?? 'No', () => false),
              KeyValue(yesLabel ?? 'Sí', () => true),
            ]
          : [
              KeyValue(yesLabel ?? 'Sí', () => true),
              KeyValue(noLabel ?? 'No', () => false),
            ],
    );
  }

  custom({String message, String title, String yesLabel, String noLabel, Widget body, IconData icon, Color color, bool swap}) {
    return MessageDialog(
      _scope,
      title: title ?? 'Confirmar Acción',
      message: message,
      icon: icon ?? Icons.chat_bubble,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: color ?? _scope.application.settings.colors.info,
      body: body,
      iconColor: color ?? _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              KeyValue(noLabel ?? 'Cancelar', () => false),
              KeyValue(yesLabel ?? 'OK', () => true),
            ]
          : [
              KeyValue(yesLabel ?? 'OK', () => true),
              KeyValue(noLabel ?? 'Cancelar', () => false),
            ],
    );
  }

  DateTimeDialog dateTime([DateTime value]) {
    return DateTimeDialog(_scope, value: value);
  }
}
