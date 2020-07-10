import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart' hide Dialog;

class DateTimeDialog extends ScopeDialog {
  final DateTime value;

  DateTimeDialog(Scope scope, {this.value}) : super(scope);

  @override
  Future show() async {
    var initialDate = value ?? DateTime.now();
    var finalDate = await showDatePicker(
      context: scope.context,
      locale: Locale('es', 'DO'),
      initialDate: initialDate,
      firstDate: new DateTime(1970, 8),
      lastDate: new DateTime(2101),
    );
    if (finalDate != null) {
      final finalTime = await showTimePicker(context: scope.context, initialTime: Utils.convert.fromDateToTime(finalDate));
      if (finalTime != null) {
        return DateTime(finalDate.year, finalDate.month, finalDate.day, finalTime.hour, finalTime.minute);
      }
    }
  }
}
