import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart' hide Navigator;
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

  Application() {
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    _navigator = Navigator(this);
    init();
    _auths = AuthProviders(this);
    _analytics = Analytics();
  }

  Future setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (_settings.analytics.available == true) {
      await _analytics.init();
    }
  }

  @protected
  void init() {}

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
