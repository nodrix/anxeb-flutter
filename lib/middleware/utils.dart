import 'package:anxeb_flutter/utils/converters.dart';
import 'package:anxeb_flutter/utils/formatters.dart';
import 'package:anxeb_flutter/utils/validators.dart';

class Utils {
  static final Utils _singleton = Utils._internal();

  static Validators validators = Validators();
  static Formatters formatters = Formatters();
  static Converters convert = Converters();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();
}
