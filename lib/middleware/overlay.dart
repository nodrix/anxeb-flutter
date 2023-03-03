import 'package:android_middleware/android_middleware.dart';
import 'package:android_middleware/middleware/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'device.dart';
import 'scope.dart';

class Overlay {
  bool extendBodyFullScreen = false;
  bool extendBodyBehindAppBar = false;
  bool extendBody = false;
  Brightness navigationBrightness;
  Color navigationFill;
  Brightness statusBrightness;
  Color statusFill;
  Brightness brightness;
  Color fill;
  SystemUiOverlayStyle style;
  Scope scope;

  Overlay({this.scope, this.navigationBrightness, this.navigationFill, this.statusBrightness, this.statusFill, this.brightness, this.fill, this.style}) {
    style = SystemUiOverlayStyle.light;
  }

  void apply({bool instant}) {
    var $statusBrightness = brightness ?? statusBrightness ?? scope?.application?.settings?.overlay?.brightness ?? Brightness.dark;
    var $navigationBrightness = brightness ?? navigationBrightness ?? scope?.application?.settings?.overlay?.brightness?? Brightness.dark;

    if (Device.isAndroid) {
      if ($statusBrightness == Brightness.light) {
        $statusBrightness = Brightness.dark;
      } else {
        $statusBrightness = Brightness.light;
      }

      if ($navigationBrightness == Brightness.light) {
        $navigationBrightness = Brightness.dark;
      } else {
        $navigationBrightness = Brightness.light;
      }
    }

    if (Device.isWeb == false) {
      if (this.extendBodyFullScreen == true) {
        AndroidMiddleware.windowManager.addFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
      } else {
        AndroidMiddleware.windowManager.clearFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
      }
      Future.delayed(Duration(milliseconds: instant == true ? 0 : 1000), () {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: fill ?? statusFill ?? scope?.application?.settings?.overlay?.fill ?? Colors.transparent,
          statusBarBrightness: $statusBrightness,
          statusBarIconBrightness: $statusBrightness,
          systemNavigationBarColor: fill ?? navigationFill ?? scope?.application?.settings?.overlay?.fill ?? scope?.application?.settings?.colors?.navigation ?? Colors.black,
          systemNavigationBarIconBrightness: $navigationBrightness,
        ));
      });
    }
  }
}
