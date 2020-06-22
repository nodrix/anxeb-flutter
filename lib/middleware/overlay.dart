import 'dart:io';
import 'dart:ui';

import 'package:android_middleware/android_middleware.dart';
import 'package:android_middleware/middleware/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbar/flutter_statusbar.dart';

class Overlay {
  bool extendBodyFullScreen = false;
  bool extendBodyBehindAppBar = false;
  bool extendBody = false;
  Brightness navigationBrightness;
  Color navigationFill;
  Color navigationDefaultFill;
  Brightness statusBrightness;
  Color statusFill;
  Brightness brightness;
  Color fill;
  double statusBarHeight;
  SystemUiOverlayStyle style;

  Overlay({this.navigationBrightness, this.navigationFill, this.navigationDefaultFill, this.statusBrightness, this.statusFill, this.brightness, this.fill, this.style}) {
    style = SystemUiOverlayStyle.light;
    init();
  }

  void init() async {
    try {
      statusBarHeight = await FlutterStatusbar.height;
    } on PlatformException {}
  }

  void apply() {
    var $statusBrightness = brightness ?? statusBrightness ?? Brightness.dark;
    var $navigationBrightness = brightness ?? navigationBrightness ?? Brightness.dark;

    if (Platform.isAndroid) {
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

    if (this.extendBodyFullScreen == true) {
      AndroidMiddleware.windowManager.addFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
    } else {
      AndroidMiddleware.windowManager.clearFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
    }
    Future.delayed(Duration(milliseconds: 500), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: fill ?? statusFill ?? Colors.transparent,
        statusBarBrightness: $statusBrightness,
        statusBarIconBrightness: $statusBrightness,
        systemNavigationBarColor: fill ?? navigationFill ?? navigationDefaultFill ?? Colors.black,
        systemNavigationBarIconBrightness: $navigationBrightness,
      ));
    });
  }
}
