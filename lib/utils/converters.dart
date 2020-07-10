import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Converters {
  final _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  final _commaRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final _fullDateFormat = DateFormat("dd/MM/yyyy h:mm:ss a");
  final _normalDateFormat = DateFormat("dd/MM/yyyy h:mm a");

  String fromStringToDigits(String value) {
    String result = '';
    for (var i = 0; i < value.length; i++) {
      var char = value[i];
      if (_digits.contains(char)) {
        result += char;
      }
    }
    return result;
  }

  String fromStringToUpperCase(String value) {
    return value.toUpperCase().trim();
  }

  String fromStringToTrimedString(String value) {
    return value.trim();
  }

  String fromAnyToNumber(value, {int decimals, bool comma}) {
    if (value == null) {
      return null;
    }
    String $value = decimals != null ? (value is double ? value : double.parse(value.toString())).toStringAsFixed(decimals) : value.toString();
    if (comma == null || comma == true) {
      return $value.replaceAllMapped(_commaRegex, (Match m) => '${m[1]},');
    } else {
      return $value;
    }
  }

  String fromDateToFullDateString(DateTime date, {bool seconds}) {
    if (date == null) {
      return null;
    }
    if (seconds == true) {
      return _fullDateFormat.format(date);
    } else {
      return _normalDateFormat.format(date);
    }
  }

  DateTime fromTickToDate(int timestamp) {
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      return null;
    }
  }

  double fromAnyToDouble(value, {int decimals}) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return fromStringToDouble(value);
    } else {
      return double.parse((value as num).toDouble().toStringAsFixed(decimals ?? 2));
    }
  }

  double fromStringToDouble(String value, {int decimals}) {
    if (value != null && value.isNotEmpty) {
      value = value.replaceAll(',', '');
      return double.parse(double.parse(value).toStringAsFixed(decimals ?? 2));
    } else {
      return null;
    }
  }

  EdgeInsets fromInsetToFraction(EdgeInsets inset, Size screenSize) {
    return EdgeInsets.only(left: inset.left * screenSize.width, right: inset.right * screenSize.width, top: inset.top * screenSize.height, bottom: inset.bottom * screenSize.height);
  }

  TimeOfDay fromDateToTime(DateTime date) {
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  int fromDateToTick(DateTime date) {
    return date != null ? (date.toUtc().millisecondsSinceEpoch ~/ 1000) : null;
  }

  double fromAnyToMoney(value) {
    if (value == null) {
      return 0;
    }
    if (value is String) {
      return double.parse(double.parse(value).toStringAsFixed(2));
    } else {
      return double.parse(value.toStringAsFixed(2));
    }
  }

  String fromStringToNameCase(String value) {
    var items = value.split(' ');
    var result = List<String>();

    for (var item in items) {
      if (item.length > 1) {
        result.add(item[0].toUpperCase() + item.substring(1).toLowerCase());
      }
    }

    return result.join(' ');
  }

  int fromStringToPositive(String value) {
    if (value != null && value.isNotEmpty) {
      value = value.replaceAll(',', '');
      var result = int.parse(value);
      return result < 0 ? -result : result;
    } else {
      return null;
    }
  }

  int fromStringToInteger(String value) {
    if (value != null && value.isNotEmpty) {
      value = value.replaceAll(',', '');
      return int.parse(value);
    } else {
      return null;
    }
  }

  int fromAnyToInteger(value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return fromStringToInteger(value);
    } else {
      return (value as num).toInt();
    }
  }

  fromStringToDate(String text) {
    return DateTime.parse(text);
  }
}
