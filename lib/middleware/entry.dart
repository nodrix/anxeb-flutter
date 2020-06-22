library anxeb_flutter;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'view.dart';

class Entry extends StatelessWidget {
  final ViewWidget home;
  final ThemeData theme;

  Entry({this.home, this.theme}) : assert(home != null);

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
        home: this.home,
        theme: this.theme ??
            ThemeData(
              primaryColor: this.home.application.settings.colors.primary,
              accentColor: this.home.application.settings.colors.accent,
              fontFamily: 'Montserrat',
            ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('es'),
          const Locale.fromSubtags(languageCode: 'es'),
        ],
        debugShowCheckedModeBanner: false);
    return app;
  }
}
