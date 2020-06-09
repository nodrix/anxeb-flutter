import 'package:android_middleware/android_middleware.dart';
import 'package:android_middleware/middleware/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class _PageContextScreen {
  final Size size;

  _PageContextScreen({this.size}) : assert(size != null);
}

class _PageContextOverlay {
  void setStyle({Brightness navigationBrightness, Color navigationFill, Brightness statusBrightness, Color statusFill, Brightness brightness, Color fill}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: fill ?? statusFill ?? Colors.transparent,
        statusBarBrightness: brightness ?? statusBrightness ?? Brightness.light,
        statusBarIconBrightness: brightness ?? statusBrightness ?? Brightness.light,
        systemNavigationBarColor: fill ?? navigationFill ?? Colors.transparent,
        systemNavigationBarIconBrightness: brightness ?? navigationBrightness ?? Brightness.light));
  }
}

class _PageContext {
  _PageContextScreen screen;
  _PageContextOverlay overlay;

  _PageContext(BuildContext context) {
    screen = _PageContextScreen(size: MediaQuery.of(context).size);
    overlay = _PageContextOverlay();
  }
}

abstract class AnxebPage extends StatelessWidget {
  final bool extendBodyFullScreen;
  final bool extendBodyBehindAppBar;
  final Brightness navigationBrightness;
  final Color navigationFill;
  final Brightness statusBrightness;
  final Color statusFill;
  final Brightness brightness;
  final Color fill;
  final String title;

  AnxebPage({this.extendBodyFullScreen, this.extendBodyBehindAppBar, this.navigationBrightness, this.navigationFill, this.statusBrightness, this.statusFill, this.brightness, this.fill, this.title});

  Widget render(BuildContext context, _PageContext page) {
    return Container();
  }

  void setup(BuildContext context, _PageContext page);

  @override
  Widget build(BuildContext context) {
    var pageContext = _PageContext(context);
    setup(context, pageContext);

    if (this.extendBodyFullScreen == true) {
      AndroidMiddleware.windowManager.addFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
    } else {
      AndroidMiddleware.windowManager.clearFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
    }

    pageContext.overlay.setStyle(
      navigationBrightness: this.navigationBrightness,
      navigationFill: this.navigationFill,
      statusBrightness: this.statusBrightness,
      statusFill: this.statusFill,
      brightness: this.brightness,
      fill: this.fill,
    );

    return new Scaffold(
        extendBody: true,
        appBar: this.title != null
            ? AppBar(
                title: Text(this.title),
              )
            : null,
        extendBodyBehindAppBar: this.extendBodyBehindAppBar,
        body: WillPopScope(
          onWillPop: () => Future.value(true),
          child: render(context, pageContext),
        ));
  }
}
