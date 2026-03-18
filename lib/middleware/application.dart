import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart' hide Navigator, Overlay;
import 'disk.dart';
import 'printer.dart';

class Application {
  Settings _settings;
  Api _api;
  String _title;
  Disk _disk;
  AuthProviders _auths;
  LocalizationDelegate _localization;
  Printer _printer;
  DeviceInfo _info;

  Application() {
    WidgetsFlutterBinding.ensureInitialized();
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    _printer = Printer(this);
    init();
    _auths = AuthProviders(this);
    _info = Device.info;
  }

  Future setup({List<String> locales}) async {
    if (locales != null) {
      _localization = await LocalizationDelegate.create(fallbackLocale: locales[0], supportedLocales: locales);
    }
    await Device.info.init();
  }

  @protected
  void init() {}

  void onEvent(ApplicationEventType type, {String reference, String description, dynamic data}) {}

  Settings get settings => _settings;

  String get version => 'v0.0.0';

  Api get api => _api;

  AuthProviders get auths => _auths;

  Overlay get overlay => null;

  @protected
  set api(value) {
    _api = value;
  }

  String get title => _title;

  @protected
  set title(value) {
    _title = value;
  }

  Widget drawer(Scope scope) => null;

  Disk get disk => _disk;

  LocalizationDelegate get localization => _localization;

  Printer get printer => _printer;

  DeviceInfo get info => _info;
}

enum ApplicationEventType { error, exception, asterisk, success, information, notification, action, debug, prompt, view }
