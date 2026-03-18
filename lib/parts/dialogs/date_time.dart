import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart' hide Dialog;

class DateTimeDialog extends ScopeDialog {
  final DateTime value;
  final bool pickTime;
  final Locale locale;
  final firstDate;
  final lastDate;
  final onlyMondays;

  DateTimeDialog(
    Scope scope, {
    this.value,
    this.pickTime,
    this.locale,
    this.firstDate,
    this.lastDate,
    this.onlyMondays,
  }) : super(scope);

  @override
  Future show() async {
    var initialDate = value;
    var finalDate = await showDatePicker(
      context: scope.context,
      locale: locale ?? scope.application?.localization?.currentLocale ?? Locale('es', 'DO'),
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900, 1, 1),
      lastDate: lastDate ?? DateTime(2200, 12, 31),
      selectableDayPredicate: (date) {
        if (onlyMondays == true) {
          return date.weekday == DateTime.monday;
        }
        return true;
      },
    );
    if (finalDate != null) {
      if (pickTime == true) {
        final finalTime = await showTimePicker(context: scope.context, initialTime: Utils.convert.fromDateToTime(initialDate ?? finalDate));
        if (finalTime != null) {
          return DateTime(finalDate.year, finalDate.month, finalDate.day, finalTime.hour, finalTime.minute);
        }
      } else {
        return DateTime(finalDate.year, finalDate.month, finalDate.day);
      }
    }
  }
}
