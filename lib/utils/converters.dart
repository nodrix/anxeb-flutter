import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as Path;

class Converters {
  final _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  final _commaRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final _fullDateFormat = DateFormat('dd/MM/yyyy h:mm:ss a');
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _normalDateFormat = DateFormat('dd/MM/yyyy h:mm a');
  final _fileDateFormat = DateFormat('dd_MM_yyyy_h_mm_a');
  final _humanDateFormat = DateFormat.yMMMd('es_DO');
  final _humanFullDateFormat = DateFormat.yMMMMd('es_DO');
  final _timeFormat = DateFormat('h:mm aa');
  
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
  
  String fromDateToDurationCaption(DateTime date) {
    Duration duration = DateTime.now().difference(date);
    int value;
    String sufix;
    
    if (duration.inHours >= 24) {
      value = duration.inDays;
      sufix = 'd';
    } else if (duration.inMinutes >= 60) {
      value = duration.inHours;
      sufix = 'h';
    } else if (duration.inSeconds >= 60) {
      value = duration.inMinutes;
      sufix = 'm';
    } else {
      value = duration.inSeconds;
      sufix = 's';
    }
    
    return fromAnyToNumber(value, comma: true, decimals: 0) + sufix;
  }
  
  String fromAnyToNumber(value, {int decimals, bool comma, String prefix}) {
    if (value == null) {
      return null;
    }
    String $value = decimals != null ? (value is double ? value : double.parse(value.toString())).toStringAsFixed(decimals) : value.toString();
    var result;
    if (comma == null || comma == true) {
      result = $value.replaceAllMapped(_commaRegex, (Match m) => '${m[1]},');
    } else {
      result = $value;
    }
    return (prefix ?? '') + result;
  }
  
  String fromDateToFullDateString(DateTime date, {bool seconds, bool time}) {
    if (date == null) {
      return null;
    }
    
    if (time == false) {
      return _dateFormat.format(date);
    } else if (seconds == true) {
      return _fullDateFormat.format(date);
    } else {
      return _normalDateFormat.format(date);
    }
  }
  
  String fromDateToHumanString(DateTime date, {bool complete, bool withTime}) {
    if (date == null) {
      return null;
    }
    if (withTime == true) {
      if (complete == true) {
        return '${_humanFullDateFormat.format(date)} ${_timeFormat.format(date)}'.replaceAll('.', '').toLowerCase();
      } else {
        return '${_humanDateFormat.format(date)} ${_timeFormat.format(date)}'.replaceAll('.', '').toLowerCase();
      }
    } else {
      if (complete == true) {
        return _humanFullDateFormat.format(date);
      } else {
        return _humanDateFormat.format(date);
      }
    }
  }
  
  String fromTextToEllipsis(String value, int max) {
    if (value.length > max) {
      var $value = value;
      while ($value.length > max) {
        var parts = $value.split(' ');
        if (parts.length == 1) {
          return value.substring(0, max) + '...';
        }
        parts.removeLast();
        $value = parts.join(' ');
      }
      return $value + '...';
    }
    return value;
  }
  
  String fromAnyToDataSize(int value) {
    const ONE_KB = 1000;
    const ONE_MB = 1000000;
    var sufix = 'B';
    var caption = fromAnyToNumber(value, decimals: 0, comma: true);
    
    if (value >= ONE_MB) {
      sufix = 'MB';
      caption = fromAnyToNumber((value / ONE_MB), decimals: 2, comma: true);
    } else if (value >= ONE_KB) {
      sufix = 'KB';
      caption = fromAnyToNumber((value / ONE_KB), decimals: 2, comma: true);
    }
    return '$caption $sufix';
  }
  
  String fromDateToFileDateString(DateTime date) {
    if (date == null) {
      return null;
    }
    return _fileDateFormat.format(date);
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
      return decimals != null ? double.parse((value as num).toDouble().toStringAsFixed(decimals)) : (value as num).toDouble();
    }
  }
  
  double fromStringToDouble(String value, {int decimals}) {
    if (value != null && value.isNotEmpty) {
      value = value.replaceAll(',', '');
      return decimals != null ? double.parse(double.parse(value).toStringAsFixed(decimals)) : double.parse(value);
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
    return date != null ? (date
        .toUtc()
        .millisecondsSinceEpoch ~/ 1000) : null;
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
    if (value == null) {
      return null;
    }
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
  
  Future<MultipartFile> fromPathToMultipartFile(path) async {
    var contentType = lookupMimeType(path);
    return await MultipartFile.fromFile(path, filename: Path.basename(path), contentType: MediaType.parse(contentType));
  }
  
  FormData fromMapToFormData(map) {
    return FormData.fromMap(map);
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
