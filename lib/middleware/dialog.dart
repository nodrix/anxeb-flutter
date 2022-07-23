import 'package:anxeb_flutter/parts/dialogs/date_time.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:anxeb_flutter/parts/dialogs/options.dart';
import 'package:anxeb_flutter/parts/dialogs/panel.dart';
import 'package:anxeb_flutter/parts/dialogs/period.dart';
import 'package:anxeb_flutter/parts/dialogs/referencer.dart';
import 'package:anxeb_flutter/parts/dialogs/selectors.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:anxeb_flutter/utils/referencer.dart';
import 'package:anxeb_flutter/widgets/blocks/selector.dart';
import 'package:anxeb_flutter/widgets/components/dialog_progress.dart';
import 'package:anxeb_flutter/widgets/fields/barcode.dart';
import 'package:anxeb_flutter/widgets/fields/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'field.dart';
import 'form.dart';
import 'scope.dart';
import 'utils.dart';

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
    try {
      scope.unfocus();
      scope.rasterize();
      await scope.idle();
      await setup();
      return showDialog<V>(
        context: scope.context,
        barrierDismissible: dismissible,
        builder: (BuildContext context) {
          return build(context);
        },
      );
    } catch (err) {
      scope.alerts.error(err).show();
      return null;
    }
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

  PanelDialog panel({String title, List<PanelMenuItem> items, bool horizontal, double iconScale, double textScale}) {
    return PanelDialog(
      _scope,
      title: title,
      items: items,
      horizontal: horizontal,
      iconScale: iconScale,
      textScale: textScale,
    );
  }

  OptionsDialog options<V>(String title, {IconData icon, List<DialogButton<V>> options, V selectedValue}) {
    return OptionsDialog<V>(
      _scope,
      title: title,
      icon: icon,
      options: options,
      selectedValue: selectedValue,
    );
  }

  MessageDialog information(String title, {String message, List<DialogButton> buttons, IconData icon, Widget Function(BuildContext context) body}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      body: body,
      icon: icon ?? Icons.info,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.primary,
      buttons: buttons,
    );
  }

  PeriodDialog period(String title, {IconData icon, PeriodValue selectedValue, bool allowAllMonths}) {
    return PeriodDialog(
      _scope,
      title: title,
      icon: icon ?? FlutterIcons.calendar_week_mco,
      selectedValue: selectedValue,
      allowAllMonths: allowAllMonths,
    );
  }

  MessageDialog success(String title, {String message, List<DialogButton> buttons, IconData icon, Widget Function(BuildContext context) body}) {
    return MessageDialog(_scope, title: title, message: message, icon: icon ?? Icons.check_circle, messageColor: _scope.application.settings.colors.text, titleColor: _scope.application.settings.colors.primary, iconColor: _scope.application.settings.colors.success, buttons: buttons, body: body);
  }

  MessageDialog exception(String title, {String message, List<DialogButton> buttons, IconData icon, bool dismissible}) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: icon ?? Icons.error,
      dismissible: dismissible,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons,
    );
  }

  MessageDialog error(error, {List<DialogButton> buttons, IconData icon}) {
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

  MessageDialog confirm(String message, {String title, String yesLabel, String noLabel, Widget Function(BuildContext context) body, bool swap}) {
    return MessageDialog(
      _scope,
      title: title ?? translate('anxeb.middleware.dialog.confirm.title'),
      //TR 'Confirmar Acción'
      message: message,
      icon: Icons.help,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: body,
      iconColor: _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              DialogButton(noLabel ?? translate('anxeb.common.no'), false),
              DialogButton(yesLabel ?? translate('anxeb.common.yes'), true),
            ]
          : [
              DialogButton(yesLabel ?? translate('anxeb.common.yes'), true),
              DialogButton(noLabel ?? translate('anxeb.common.no'), false),
            ],
    );
  }

  MessageDialog qr(String value, {IconData icon, String title, List<DialogButton> buttons, String tip}) {
    final size = _scope.window.available.width * 0.6;

    return MessageDialog(
      _scope,
      icon: icon,
      title: title,
      iconSize: 65,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      buttons: buttons,
      body: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size,
              height: size,
              child: QrImage(
                data: value,
                version: QrVersions.auto,
                foregroundColor: _scope.application.settings.colors.text,
                size: size,
              ),
            ),
            tip != null
                ? Container(
                    width: size,
                    padding: EdgeInsets.all(6),
                    child: Text(
                      tip ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _scope.application.settings.colors.primary),
                    ),
                  )
                : Container(),
          ],
        );
      },
      iconColor: _scope.application.settings.colors.primary,
      dismissible: true,
    );
  }

  MessageDialog form(String title, {List<FieldWidget> Function(Scope scope, BuildContext context, String group) fields, IconData icon, String acceptLabel, String cancelLabel, bool swap, String group}) {
    var cancel = (BuildContext context) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    var $formName = group ?? '_dialog_form';
    FieldsForm form = _scope.forms[$formName];
    form.clear();

    var accept = () {
      if (form.valid() == true) {
        Future.delayed(Duration(milliseconds: 0)).then((value) {
          _scope.unfocus();
        });
        return form.data();
      } else {
        return null;
      }
    };

    return MessageDialog(
      _scope,
      title: title,
      icon: icon ?? Icons.edit,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: (context) {
        var $fields = fields.call(_scope, context, $formName);
        return Container(
          child: Column(
            children: $fields,
          ),
        );
      },
      iconColor: _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept()),
            ]
          : [
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept()),
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
            ],
    );
  }

  MessageDialog promptScan(String title, {String value, BarcodeInputFieldType type, String label, FormFieldValidator<String> validator, String hint, IconData icon, String acceptLabel, String cancelLabel, bool swap, String group}) {
    var cancel = (BuildContext context) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    TextEditingController _controller = TextEditingController();

    var $formName = group ?? '_prompt_form';
    FieldsForm form = _scope.forms[$formName];
    form.clear();

    var accept = () {
      form.set('prompt_scan', _controller.text);
      var field = form.fields['prompt_scan'];
      if (field.validate(showMessage: true) == null) {
        Future.delayed(Duration(milliseconds: 0)).then((value) {
          _scope.unfocus();
        });
        return field.data();
      } else {
        return null;
      }
    };

    return MessageDialog(
      _scope,
      title: title,
      icon: icon ?? Icons.edit,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: (context) => BarcodeInputField(
        scope: _scope,
        controller: _controller,
        name: 'prompt_scan',
        group: $formName,
        margin: const EdgeInsets.only(top: 20),
        label: label,
        value: value,
        icon: null,
        validator: validator ?? Utils.validators.required,
        action: TextInputAction.done,
        type: type ?? TextInputFieldType.text,
        hint: hint,
        autofocus: true,
        selected: true,
        focusNext: false,
        onValidSubmit: (value) {
          var data = accept();
          if (data != null) {
            Navigator.of(context).pop(data);
          }
        },
      ),
      iconColor: _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept()),
            ]
          : [
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept()),
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
            ],
    );
  }

  MessageDialog prompt<T>(String title, {T value, String message, int maxLength, Color cancelFillColor, Color acceptFillColor, TextInputFieldType type, String label, FormFieldValidator<String> validator, String hint, IconData icon, String acceptLabel, String cancelLabel, bool swap, int lines, String group}) {
    var cancel = (BuildContext context) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    TextEditingController _controller = TextEditingController();

    var $formName = group ?? '_prompt_form';
    FieldsForm form = _scope.forms[$formName];
    form.clear();

    var accept = () {
      form.set('prompt', _controller.text);
      var field = form.fields['prompt'];
      if (field.validate(showMessage: true) == null) {
        Future.delayed(Duration(milliseconds: 0)).then((value) {
          _scope.unfocus();
        });
        return field.data();
      } else {
        field.select();
        return null;
      }
    };

    return MessageDialog(
      _scope,
      title: title,
      icon: icon ?? Icons.edit,
      iconSize: 48,
      message: message,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: (context) => TextInputField<T>(
        scope: _scope,
        controller: _controller,
        name: 'prompt',
        group: $formName,
        margin: const EdgeInsets.only(top: 20),
        label: label,
        value: value,
        validator: validator ?? Utils.validators.required,
        action: TextInputAction.done,
        maxLines: lines,
        maxLength: maxLength,
        type: type ?? TextInputFieldType.text,
        hint: hint,
        autofocus: true,
        selected: true,
        focusNext: false,
        onActionSubmit: (value) {
          var data = accept();
          if (data != null) {
            Navigator.of(context).pop(data);
          }
        },
      ),
      iconColor: _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context), fillColor: cancelFillColor),
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept(), fillColor: acceptFillColor),
            ]
          : [
              DialogButton(acceptLabel ?? translate('anxeb.common.accept'), null, onTap: (context) => accept(), fillColor: acceptFillColor),
              DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context), fillColor: cancelFillColor),
            ],
    );
  }

  MessageDialog progress<T>(String title, {T value, IconData icon, String cancelLabel, DialogProcessController controller, bool isDownload, String successMessage, String failedMessage, String busyMessage}) {
    var cancel = (BuildContext context) {
      controller.cancel();
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    return MessageDialog(_scope, title: title, icon: icon ?? Icons.edit, iconSize: 48, messageColor: _scope.application.settings.colors.text, titleColor: _scope.application.settings.colors.info, body: (context) {
      controller.onCompleted(() {
        Future.delayed(Duration(milliseconds: 0)).then((value) {
          _scope.unfocus();
        });
        Navigator.of(context).pop(null);
      });

      return DialogProgress(
        controller: controller,
        scope: _scope,
        isDownload: isDownload,
        successMessage: successMessage,
        failedMessage: failedMessage,
        busyMessage: busyMessage,
      );
    }, iconColor: _scope.application.settings.colors.info, buttons: [
      DialogButton(cancelLabel ?? translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
    ]);
  }

  SelectorsDialog selector({List<SelectorBlock> Function(BuildContext) selectors}) {
    return SelectorsDialog(_scope, selectors: selectors);
  }

  MessageDialog custom({
    String message,
    String title,
    Widget Function(BuildContext context) body,
    IconData icon,
    Color color,
    List<DialogButton> buttons,
    bool dismissible,
    EdgeInsets contentPadding,
    EdgeInsets insetPadding,
    BorderRadius borderRadius,
  }) {
    return MessageDialog(
      _scope,
      title: title,
      message: message,
      icon: icon,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: color ?? _scope.application.settings.colors.info,
      body: body,
      iconColor: color ?? _scope.application.settings.colors.info,
      buttons: buttons,
      dismissible: dismissible,
      contentPadding: contentPadding,
      insetPadding: insetPadding,
      borderRadius: borderRadius,
    );
  }

  DateTimeDialog dateTime({DateTime value, bool pickTime}) {
    return DateTimeDialog(_scope, value: value, pickTime: pickTime);
  }
}

class DialogButton<T> {
  final String caption;
  final T value;
  final Color fillColor;
  final Color textColor;
  final IconData icon;
  final T Function(BuildContext context) onTap;
  final bool swapIcon;
  final bool visible;

  DialogButton(
    this.caption,
    this.value, {
    this.onTap,
    this.fillColor,
    this.textColor,
    this.icon,
    this.swapIcon,
    this.visible,
  });
}
