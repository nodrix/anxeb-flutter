import 'package:anxeb_flutter/utils/converters.dart';
import 'package:anxeb_flutter/utils/validators.dart';
import 'package:anxeb_flutter/utils/dialogs.dart';

class Utils {
  static final Utils _singleton = Utils._internal();

  static Validators validators = Validators();
  static Converters convert = Converters();
  static Dialogs dialogs = Dialogs();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();
}
