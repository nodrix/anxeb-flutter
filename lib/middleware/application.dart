import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart' hide Navigator, Overlay;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'disk.dart';
import 'printer.dart';

class Application {
  Settings _settings;
  Api _api;
  String _title;
  Disk _disk;
  Navigator _navigator;
  AuthProviders _auths;
  Analytics _analytics;
  bool _badgesSupport;
  LocalizationDelegate _localization;
  Printer _printer;

  Application() {
    WidgetsFlutterBinding.ensureInitialized();
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    _navigator = Navigator(this);
    _printer = Printer(this);
    init();
    _auths = AuthProviders(this);
    if (_settings.analytics.available == true) {
      _analytics = Analytics();
    }
  }

  void setBadge(int value) {
    if (_badgesSupport == true) {
      if (value != null && value > 0) {
        FlutterAppBadger.updateBadgeCount(value);
      } else {
        FlutterAppBadger.removeBadge();
      }
    }
  }

  Future setup({List<String> locales}) async {
    if (locales != null) {
      _localization = await LocalizationDelegate.create(fallbackLocale: locales[0], supportedLocales: locales);
    }
    _badgesSupport = _settings.general.badges == true && await FlutterAppBadger.isAppBadgeSupported();
    if (_settings.analytics.available == true) {
      await _analytics.init(onMessage: onMessage);
    }
    await Device.info.init();
  }

  @protected
  void init() {}

  @protected
  void onMessage(RemoteMessage message, MessageEventType event) {
    setBadge(analytics.notifications.length);
  }

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

  Navigator get navigator => _navigator;

  Analytics get analytics => _analytics;

  @protected
  set navigator(value) {
    _navigator = value;
  }

  Disk get disk => _disk;

  LocalizationDelegate get localization => _localization;

  Printer get printer => _printer;
}

enum ApplicationEventType { error, exception, asterisk, success, information, notification, action, debug, prompt, view }
