import 'package:flutter/material.dart';

class Converters {
  EdgeInsets toFraction(EdgeInsets padding, Size screenSize) {
    return EdgeInsets.only(left: padding.left * screenSize.width, right: padding.right * screenSize.width, top: padding.top * screenSize.height, bottom: padding.bottom * screenSize.height);
  }

  DateTime fromUnixTime(int timestamp) {
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      return null;
    }
  }

  double toDouble(data) {
    if (data == null) {
      return null;
    }
    return (data as num).toDouble();
  }

  TimeOfDay toTime(DateTime date) {
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  double number(String value, {int decimals}) {
    if (value != null && value.isNotEmpty) {
      value = value.replaceAll(',', '');
      return double.parse(double.parse(value).toStringAsFixed(decimals ?? 2));
    } else {
      return null;
    }
  }

  int toUnix(DateTime date) {
    return date != null ? (date.toUtc().millisecondsSinceEpoch ~/ 1000) : null;
  }

  double toMoney(value) {
    if (value == null) {
      return 0;
    }
    if (value is String) {
      return double.parse(double.parse(value).toStringAsFixed(2));
    } else {
      return double.parse(value.toStringAsFixed(2));
    }
  }
}
