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
    final isLocalized = this.home.application.localization != null;

    var localizationDelegate = this.home.application.localization;

    var app = MaterialApp(
        home: this.home,
        navigatorObservers: this.home.application.settings.analytics.available == true ? [this.home.application.analytics.observer] : [],
        theme: this.theme ??
            ThemeData(
              primaryColor: this.home.application.settings.colors.primary,
              colorScheme: ColorScheme.light(
                primary: this.home.application.settings.colors.primary,
                secondary: this.home.application.settings.colors.secudary,
                secondaryContainer: this.home.application.settings.colors.navigation,
                onSecondary: Colors.white,
                brightness: Brightness.light,
              ),
              fontFamily: 'Montserrat',
            ),
        localizationsDelegates: isLocalized
            ? [
                localizationDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ]
            : [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
        supportedLocales: isLocalized
            ? localizationDelegate.supportedLocales
            : [
                const Locale('en'),
                const Locale('es'),
                const Locale.fromSubtags(languageCode: 'es'),
              ],
        locale: localizationDelegate?.currentLocale,
        routes: <String, WidgetBuilder>{
          '/${this.home.name}': (BuildContext context) => this.home,
        },
        debugShowCheckedModeBanner: false);
    return app;
  }
}
