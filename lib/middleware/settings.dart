import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screen/screen.dart';
import 'api.dart';

class _General {
  bool badges;
}

class _Panels {
  double buttonRadius;
}

class _Dialogs {
  double buttonRadius;
  double dialogRadius;
  Color headerColor;
  Color footerColor;
  EdgeInsets buttonPaddingWithIcon;
  EdgeInsets buttonPaddingWithoutIcon;
  TextStyle buttonTextStyle;
  double width;
  TextStyle messageTitleTextStyle;
  TextStyle messageContentTextStyle;
  TextStyle panelTitleTextStyle;
  TextStyle panelContentTextStyle;
  TextStyle formContentTextStyle;
  TextStyle formTitleTextStyle;
  TextStyle formSubtitleTextStyle;
  double iconScale;
  EdgeInsets messageContentPadding;
  TextStyle busyBoxTextStyle;
  double busyBoxIndicatorSize;
}

class _Alerts {
  bool Function() showFromBottom;
  EdgeInsets Function() margin;
  BorderRadius borderRadius;
}

class _Fields {
  double radius;
  Color fillColor;
  double fontSize;
  InputBorder border;
  InputBorder disabledBorder;
  InputBorder enabledBorder;
  InputBorder focusedBorder;
  InputBorder errorBorder;
  InputBorder focusedErrorBorder;
  Color hoverColor;
  Color focusColor;
  TextStyle errorStyle;
  EdgeInsets contentPaddingWithIcon;
  EdgeInsets contentPaddingNoIcon;
  bool isDense;
  TextStyle hintStyle;
  Color iconColor;
  Color suffixIconColor;
}

class _Colors {
  Color action = Colors.blue.shade500;
  Color background = Color(0xfffafafa);
  Color primary = Color(0xff2e7db2);
  Color secudary = Color(0xff026299);
  Color accent = Color(0xffef6c00);
  Color success = Color(0xff4a934a);
  Color neutral = Color(0xff0c7272);
  Color info = Color(0xff333377);
  Color warning = Color(0xffffbb33);
  Color danger = Color(0xffff4444);
  Color asterisk = Color(0xff605156);
  Color active = Color(0xffffff99);
  Color tip = Color(0xffffffaf);
  Color link = Color(0xff0055ff);
  Color separator = Color(0xffcccccc);
  Color text = Color(0xff222222);
  Color header = Color(0xff195279);
  Color focus = Color(0x15111111);
  Color input = Color(0x10111111);
  Color navigation = Color(0xff053954);
  Color backdrop = Color(0x8A000000);
  Color busybox = Color(0x8A000000);
  Color foreground = Color(0xffffffff);
}

class _AuthsApple {
  _AuthsApple();

  String fetchCallbackRoute;
  String Function() nonce;
  Api api;
}

class _AuthsGoogle {
  _AuthsGoogle();

  String clientId;
  String hostedDomain;
  SignInOption signInOption = SignInOption.standard;
  List<String> scopes = <String>[];
}

class _AuthsTwitter {
  _AuthsTwitter();

  String apiKey;
  String apiSecret;
}

class _AuthsFacebook {
  _AuthsFacebook();

  String appId;
  String appSecret;
  String clientToken;
}

class _Auths {
  _AuthsGoogle _google;
  _AuthsTwitter _twitter;
  _AuthsFacebook _facebook;
  _AuthsApple _apple;

  _Auths() {
    _google = _AuthsGoogle();
    _twitter = _AuthsTwitter();
    _facebook = _AuthsFacebook();
    _apple = _AuthsApple();
  }

  _AuthsGoogle get google => _google;

  _AuthsTwitter get twitter => _twitter;

  _AuthsFacebook get facebook => _facebook;

  _AuthsApple get apple => _apple;
}

class _Overlay {
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
}

class _Screen {
  ScreenTransitionType transition;
  int delay;
}

class Settings {
  _Colors _colors;
  _Auths _auths;
  _Dialogs _dialogs;
  _Alerts _alerts;
  _Fields _fields;
  _Panels _panels;
  _General _general;
  _Overlay _overlay;
  _Screen _screen;

  Settings() {
    _colors = _Colors();
    _auths = _Auths();
    _dialogs = _Dialogs();
    _alerts = _Alerts();
    _fields = _Fields();
    _panels = _Panels();
    _general = _General();
    _overlay = _Overlay();
    _screen = _Screen();
  }

  _Colors get colors => _colors;

  _Auths get auths => _auths;

  _Dialogs get dialogs => _dialogs;

  _Alerts get alerts => _alerts;

  _Fields get fields => _fields;

  _Panels get panels => _panels;

  _General get general => _general;

  _Overlay get overlay => _overlay;

  _Screen get screen => _screen;
}
