library anxeb_flutter;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AnxebEntry extends StatelessWidget {
  final ThemeData theme;
  final Widget home;

  AnxebEntry({this.theme, this.home}) : assert(theme != null, home != null);

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
        home: this.home,
        theme: this.theme,
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
