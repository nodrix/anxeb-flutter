import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart' hide Dialog;

class DateTimeDialog extends ScopeDialog {
  final DateTime value;
  final bool pickTime;
  final Locale locale;

  DateTimeDialog(Scope scope, {this.value, this.pickTime, this.locale}) : super(scope);

  @override
  Future show() async {
    var initialDate = value;
    var finalDate = await showDatePicker(
      context: scope.context,
      locale: locale ?? scope.application?.localization?.currentLocale ?? Locale('es', 'DO'),
      initialDate: initialDate ?? DateTime.now(),
      firstDate: new DateTime(1900),
      lastDate: new DateTime(2101),
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
