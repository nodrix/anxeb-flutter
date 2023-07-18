import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as Path;
import 'package:credit_card_type_detector/constants.dart' as CCTypes;

class Converters {
  List<String> _digits;
  RegExp _commaRegex;
  String _fullDateFormat;
  String _dateFormat;
  String _normalDateFormat;
  String _fileDateFormat;
  String _timeFormat;

  Converters() {
    _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    _commaRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    _fullDateFormat = 'dd/MM/yyyy h:mm:ss a';
    _dateFormat = 'dd/MM/yyyy';
    _normalDateFormat = 'dd/MM/yyyy h:mm a';
    _fileDateFormat = 'dd_MM_yyyy_h_mm_a';
    _timeFormat = 'h:mm aa';
  }

  String fromCreditCardTypeToString(CreditCardType type) {
    return type.name;
  }

  CreditCardType fromCreditCardNumberToType(String value) {
    final validator = CreditCardValidator();
    final valres = value != null ? validator.validateCCNum(value.toString()) : null;
    if (valres?.isValid == true) {
      switch (valres.ccType.type) {
        case CCTypes.TYPE_VISA:
          return CreditCardType.visa;
        case CCTypes.TYPE_AMEX:
          return CreditCardType.amex;
        case CCTypes.TYPE_DISCOVER:
          return CreditCardType.discover;
        case CCTypes.TYPE_MAESTRO:
          return CreditCardType.maestro;
        case CCTypes.TYPE_MASTERCARD:
          return CreditCardType.mastercard;
      }
    }

    return null;
  }

  String fromCreditCardNumberToBrand(String value) {
    CreditCardType type = fromCreditCardNumberToType(value);

    if (type != null) {
      switch (type) {
        case CreditCardType.visa:
          return 'visa';
        case CreditCardType.amex:
          return 'american_express';
        case CreditCardType.mastercard:
          return 'master_card';
        case CreditCardType.discover:
          return 'discover';
        case CreditCardType.maestro:
          return 'maestro';
      }
    }

    return null;
  }

  CreditCardType fromCreditCardBrandToType(String value) {
    if (value == 'visa') {
      return CreditCardType.visa;
    } else if (value == 'master_card') {
      return CreditCardType.mastercard;
    } else if (value == 'american_express') {
      return CreditCardType.amex;
    } else if (value == 'discover') {
      return CreditCardType.discover;
    }
    return null;
  }

  String fromNamesToSingleName(String names) {
    if (names == null) {
      return null;
    }
    var parts = names.split(' ');
    if (parts.length > 2 && parts[0].toLowerCase() == 'de') {
      return '${parts[0]} ${parts[1]} ${parts[2]}';
    } else {
      return parts[0];
    }
  }

  Color fromHexToColor(String hexString) {
    if (hexString == null) {
      return null;
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', '').replaceFirst('0x', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String fromColorToHex(Color color) {
    if (color == null) {
      return null;
    }
    return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  IconData fromHexToIconData(String hexString) {
    if (hexString == null) {
      return null;
    }
    final int iconCode = int.tryParse(hexString);
    if (iconCode == null) {
      return null;
    }
    return IconData(iconCode, fontFamily: 'MaterialIcons');
  }

  String fromNamesToFullName(String firstNames, String lastNames) {
    return '${fromNamesToSingleName(firstNames) ?? ''} ${fromNamesToSingleName(lastNames) ?? ''}'.trim();
  }

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

  String fromPathToFilename(String value) {
    if (value == null) {
      return null;
    }
    return Path.basename(value);
  }

  String fromStringToPhoneDigits(String value) {
    String result = '';
    for (var i = 0; i < value.length; i++) {
      var char = value[i];
      if (_digits.contains(char) || char == '+' || char == '*' || char == '#' || char == ' ') {
        result += char;
      }
    }
    return result;
  }

  String fromStringToUpperCase(String value) {
    return value.toUpperCase().trim();
  }

  String fromStringToTrimedString(String value) {
    return value != null ? value.trim() : null;
  }

  String fromDurationToDetail(Duration duration, {bool showDays = true, bool showHours = true, bool showMinutes = true, bool showSeconds = true, bool showZeros = false}) {
    if (duration == null) {
      return null;
    }
    int days = duration.inDays;
    int hours = duration.inHours - (days * 24);
    int minutes = duration.inMinutes - (duration.inHours * 60);
    int seconds = duration.inSeconds - (duration.inMinutes * 60);
    return '${showDays && (showZeros || days > 0) ? '${days}d ' : ''}${showHours && (showZeros || hours > 0) ? '${hours}h ' : ''}${showMinutes && (showZeros || minutes > 0) ? '${minutes}m ' : ''}${showSeconds && (showZeros || seconds > 0) ? '${seconds}s' : ''}';
  }

  String fromSecondsToDurationCaption(int seconds) {
    if (seconds == null) {
      return null;
    }
    Duration duration = Duration(seconds: seconds);
    int value;
    String sufix;
    bool isFuture = duration.inSeconds < 0;

    if (isFuture) {
      if (-duration.inHours >= 24) {
        value = -duration.inDays;
        sufix = 'd';
      } else if (-duration.inMinutes >= 60) {
        value = -duration.inHours;
        sufix = 'h';
      } else if (-duration.inSeconds >= 60) {
        value = -duration.inMinutes;
        sufix = 'm';
      } else {
        value = -duration.inSeconds;
        sufix = 's';
      }
    } else {
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
    }

    if (isFuture) {
      return fromAnyToNumber(value, comma: true, decimals: 0) + sufix + ' res';
    } else {
      return fromAnyToNumber(value, comma: true, decimals: 0) + sufix;
    }
  }

  String fromDateToDurationCaption(DateTime date) {
    if (date == null) {
      return null;
    }
    Duration duration = DateTime.now().difference(date);
    return fromDurationToHumanCaption(duration);
  }

  String fromDurationToHumanCaption(Duration duration) {
    if (duration == null) {
      return null;
    }
    int value;
    String sufix;
    bool isFuture = duration.inSeconds < 0;

    if (isFuture) {
      if (-duration.inHours >= 24) {
        value = -duration.inDays;
        sufix = 'd';
      } else if (-duration.inMinutes >= 60) {
        value = -duration.inHours;
        sufix = 'h';
      } else if (-duration.inSeconds >= 60) {
        value = -duration.inMinutes;
        sufix = 'm';
      } else {
        value = -duration.inSeconds;
        sufix = 's';
      }
    } else {
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
    }

    if (isFuture) {
      return fromAnyToNumber(value, comma: true, decimals: 0) + sufix + ' res';
    } else {
      return fromAnyToNumber(value, comma: true, decimals: 0) + sufix;
    }
  }

  String fromMetersToDistanceCaption(double meters) {
    if (meters == null) {
      return null;
    }
    double value = meters;
    String sufix = 'm';

    if (meters >= 1000) {
      value = (meters / 1000.0);
      sufix = 'km';
    }

    return '${fromAnyToNumber(value, comma: true, decimals: 0)} $sufix';
  }

  String fromAnyToNumber(value, {int decimals, bool comma, String prefix, String sufix}) {
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
    return (prefix ?? '') + result + (sufix ?? '');
  }

  String fromDateToFullDateString(DateTime date, {bool seconds, bool time}) {
    if (date == null) {
      return null;
    }

    if (time == false) {
      return DateFormat(_dateFormat).format(date);
    } else if (seconds == true) {
      return DateFormat(_fullDateFormat).format(date);
    } else {
      return DateFormat(_normalDateFormat).format(date);
    }
  }

  String fromCmToHeightMetric(double cm) {
    if (cm == null) {
      return null;
    }
    var foot = cm / 30.48;
    var parts = foot.toString().split('.');
    var feets = parts[0];
    var fraction = double.parse('0.' + parts[1]);
    var inches = (fraction * 12.0).toInt();
    return '$feets\' $inches\'\'';
  }

  String fromDateToLocalizedDate(DateTime date, {bool withTime}) {
    if (date == null) return null;

    if (withTime == true) {
      return DateFormat.yMd(translate('anxeb.formats.date_locale')).format(date.toLocal()) + ' ' + DateFormat.jms(translate('anxeb.formats.date_locale')).format(date.toLocal()).replaceAll('.', '').replaceAll(' ', '').toUpperCase();
    } else {
      return DateFormat.yMMMMd(translate('anxeb.formats.date_locale')).format(date.toLocal());
    }
  }

  String fromDateToLocalizedTime(DateTime date, {bool duration}) {
    if (date == null) return null;
    final prefix = DateFormat.jms(translate('anxeb.formats.date_locale')).format(date.toLocal()).replaceAll('.', '').replaceAll(' ', '').toUpperCase();

    return duration == false ? prefix.toUpperCase() : translate('anxeb.formats.date_duration', args: {"date": prefix, "duration": fromDateToDurationCaption(date)}).toUpperCase();
  }

  String fromDateToHumanString(DateTime date, {bool complete, bool withTime, String timeSeparator}) {
    if (date == null) {
      return null;
    }

    if (withTime == true) {
      if (complete == true) {
        return '${DateFormat.yMMMMd('es_DO').format(date)}${timeSeparator ?? ' '}${DateFormat(_timeFormat).format(date)}'.replaceAll('.', '').toLowerCase();
      } else {
        return '${DateFormat.yMMMd('es_DO').format(date)}${timeSeparator ?? ' '}${DateFormat(_timeFormat).format(date)}'.replaceAll('.', '').toLowerCase();
      }
    } else {
      if (complete == true) {
        return DateFormat.yMMMMd('es_DO').format(date);
      } else {
        return DateFormat.yMMMd('es_DO').format(date);
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
    return DateFormat(_fileDateFormat).format(date);
  }

  DateTime fromTickToDate(int timestamp) {
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
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
    if (value == null) {
      return null;
    }
    var items = value.split(' ');
    var result = <String>[];

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

  MultipartFile fromBytesToMultipartFile(String fileName, data) {
    var contentType = lookupMimeType(fileName);
    return MultipartFile.fromBytes(data, filename: Path.basename(fileName), contentType: MediaType.parse(contentType));
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

  fromIndexToMonth(int month) {
    switch (month) {
      case 1:
        return translate('anxeb.common.months.jan');
      case 2:
        return translate('anxeb.common.months.feb');
      case 3:
        return translate('anxeb.common.months.mar');
      case 4:
        return translate('anxeb.common.months.apr');
      case 5:
        return translate('anxeb.common.months.may');
      case 6:
        return translate('anxeb.common.months.jun');
      case 7:
        return translate('anxeb.common.months.jul');
      case 8:
        return translate('anxeb.common.months.aug');
      case 9:
        return translate('anxeb.common.months.sep');
      case 10:
        return translate('anxeb.common.months.oct');
      case 11:
        return translate('anxeb.common.months.nov');
      case 12:
        return translate('anxeb.common.months.dec');
    }
    return null;
  }
}

enum CreditCardType { visa, amex, mastercard, discover, maestro }
