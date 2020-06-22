import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'disk.dart';

class Application {
  Settings _settings;
  Api _api;
  String _title;
  Disk _disk;

  Application() {
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    init();
  }

  @protected
  void init() {}

  Settings get settings => _settings;

  String get version => 'v0.0.0';

  Api get api => _api;

  @protected
  set api(value) {
    _api = value;
  }

  String get title => _title;

  @protected
  set title(value) {
    _title = value;
  }

  Disk get disk => _disk;

//navigator (Drawer) shoud be somewhere here
//data shoud be called each view call.. must send as parameter the view key amomg the scope etc..
}
