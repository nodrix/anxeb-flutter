import 'package:anxeb_flutter/utils/converters.dart';
import 'package:anxeb_flutter/utils/device.dart';
import 'package:anxeb_flutter/utils/validators.dart';

class Utils {
  static final Utils _singleton = Utils._internal();

  static Validators validators = Validators();
  static Converters convert = Converters();
  static Device device = Device();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();
}
