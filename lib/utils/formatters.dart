import 'package:intl/intl.dart';

class Formatters {
  String nameCase(String value) {
    var items = value.split(' ');
    var result = List<String>();

    for (var item in items) {
      if (item.length > 1) {
        result.add(item[0].toUpperCase() + item.substring(1).toLowerCase());
      }
    }

    return result.join(' ');
  }

  double decimalNumber(String value) {
    if (value == null || value.isEmpty) {
      return 0;
    }
    var dvalue = double.parse(value);
    return double.parse(dvalue.toStringAsFixed(2));
  }

  String numericCleaning(String value) {
    return value.replaceAll('-', '').replaceAll(' ', '').replaceAll('.', '');
  }

  String upperCase(String value) {
    return value.toUpperCase().trim();
  }

  String text(String value) {
    return value.trim();
  }

  String number(value, {int decimals, bool comma}) {
    String $value = decimals != null ? (value is double ? value : double.parse(value.toString())).toStringAsFixed(decimals) : value.toString();
    if (comma == null || comma == true) {
      return $value.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } else {
      return $value;
    }
  }

  String fullDate(DateTime date, {bool seconds}) {
    if (date == null) {
      return null;
    }
    if (seconds == true) {
      return new DateFormat("dd/MM/yyyy h:mm:ss a").format(date);
    } else {
      return new DateFormat("dd/MM/yyyy h:mm a").format(date);
    }
  }
}
