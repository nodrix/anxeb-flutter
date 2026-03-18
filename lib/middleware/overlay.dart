import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'device.dart';
import 'scope.dart';

class Overlay {
  final Scope scope;
  Color statusBarColor;
  Brightness statusBarBrightness;
  bool systemNavigationBarContrastEnforced;
  Color systemNavigationBarDividerColor;
  bool systemStatusBarContrastEnforced;
  Brightness statusBarIconBrightness;
  Color systemNavigationBarColor;
  Brightness systemNavigationBarIconBrightness;
  bool keepScreenOn;
  bool translucentNavigation;
  bool translucentStatus;
  bool fullScreen;
  bool extendBodyFullScreen;
  Color appBarBackgroundColor;
  bool extendScaffoldTop;
  bool extendScaffoldBottom;
  Color scaffoldBackgroundColor;
  Color fill;

  Overlay({this.scope}) {
    var settings = scope?.application?.settings?.overlay;
    var colors = scope?.application?.settings?.colors;
    statusBarColor = settings?.statusBarColor ?? colors?.primary ?? Colors.transparent;
    statusBarBrightness = settings?.statusBarBrightness ?? Brightness.dark;
    systemNavigationBarContrastEnforced = settings?.systemNavigationBarContrastEnforced ?? false;
    systemNavigationBarDividerColor = settings?.systemNavigationBarDividerColor ?? colors?.primary ?? Colors.transparent;
    systemStatusBarContrastEnforced = settings?.systemStatusBarContrastEnforced ?? false;
    statusBarIconBrightness = settings?.statusBarIconBrightness ?? Brightness.light;
    systemNavigationBarColor = settings?.systemNavigationBarColor ?? colors?.navigation ?? Colors.black;
    systemNavigationBarIconBrightness = settings?.systemNavigationBarIconBrightness ?? Brightness.light;
    keepScreenOn = settings?.keepScreenOn ?? false;
    translucentNavigation = settings?.translucentNavigation ?? false;
    translucentStatus = settings?.translucentStatus ?? false;
    fullScreen = settings?.fullScreen ?? false;
    extendBodyFullScreen = settings?.extendBodyFullScreen ?? false;
    appBarBackgroundColor = settings?.appBarBackgroundColor ?? colors?.primary ?? Colors.transparent;
    extendScaffoldTop = settings?.extendScaffoldTop ?? false;
    extendScaffoldBottom = settings?.extendScaffoldBottom ?? false;
    scaffoldBackgroundColor = settings?.scaffoldBackgroundColor ?? colors?.background ?? Colors.white;
    apply();
  }

  void apply() {
    if (Device.isAndroid == true) {
      if (keepScreenOn == true) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
      } else {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
      }

      if (translucentNavigation == true) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_TRANSLUCENT_NAVIGATION);
      } else {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_TRANSLUCENT_NAVIGATION);
      }

      if (translucentStatus == true) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_TRANSLUCENT_STATUS);
      } else {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_TRANSLUCENT_STATUS);
      }
    }
    if (Device.isWeb == false) {
      if (fullScreen == true) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
    if (Device.isAndroid == true) {
      if (extendBodyFullScreen == true) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_LAYOUT_NO_LIMITS);
      } else {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_LAYOUT_NO_LIMITS);
      }
    }
  }

  set brightness(Brightness brightness) {
    if (brightness == Brightness.dark) {
      statusBarBrightness = Brightness.dark;
      statusBarIconBrightness = Brightness.light;
      systemNavigationBarIconBrightness = Brightness.light;
    } else {
      statusBarBrightness = Brightness.light;
      statusBarIconBrightness = Brightness.dark;
      systemNavigationBarIconBrightness = Brightness.dark;
    }
    apply();
  }

  /*
 void apply() {
  void apply({bool instant}) {
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
    Future.delayed(Duration(milliseconds: instant == true ? 0 : 1000), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: fill ?? statusFill ?? Colors.transparent,
        statusBarBrightness: $statusBrightness,
        statusBarIconBrightness: $statusBrightness,
        systemNavigationBarColor: fill ?? navigationFill ?? navigationDefaultFill ?? Colors.black,
        systemNavigationBarIconBrightness: $navigationBrightness,
      ));
    });
  }
          * */

  SystemUiOverlayStyle get style {
    var $style = SystemUiOverlayStyle(
      statusBarColor: fill ?? statusBarColor,
      statusBarBrightness: statusBarBrightness,
      systemNavigationBarContrastEnforced: systemNavigationBarContrastEnforced,
      systemNavigationBarDividerColor: systemNavigationBarDividerColor,
      systemStatusBarContrastEnforced: systemStatusBarContrastEnforced,
      statusBarIconBrightness: statusBarIconBrightness,
      systemNavigationBarColor: fullScreen == true ? null : (fill ?? systemNavigationBarColor),
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
    );

    SystemChrome.setSystemUIOverlayStyle($style);

    return $style;
  }
}
