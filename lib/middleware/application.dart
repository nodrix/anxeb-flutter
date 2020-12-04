import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart' hide Navigator;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'analytics.dart';
import 'api.dart';
import 'disk.dart';
import 'navigator.dart';

class Application {
  Settings _settings;
  Api _api;
  String _title;
  Disk _disk;
  Navigator _navigator;
  AuthProviders _auths;
  Analytics _analytics;
  bool _badgesSupport;

  Application() {
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    _navigator = Navigator(this);
    init();
    _auths = AuthProviders(this);
    _analytics = Analytics();
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

  Future setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    _badgesSupport = await FlutterAppBadger.isAppBadgeSupported();
    if (_settings.analytics.available == true) {
      await _analytics.init(onMessage: onMessage);
    }
  }

  @protected
  void init() {}

  @protected
  void onMessage(Map<String, dynamic> message, MessageEventType event) {
    setBadge(analytics.notifications.length);
  }

  Settings get settings => _settings;

  String get version => 'v0.0.0';

  Api get api => _api;

  AuthProviders get auths => _auths;

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
}
