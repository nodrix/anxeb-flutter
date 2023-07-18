library anxeb_flutter;

import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class EntryScreen extends StatelessWidget {
  final ScreenWidget home;
  final ThemeData theme;

  EntryScreen({this.home, this.theme}) : assert(home != null);

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

class EntryPage<A extends Application, M extends PageInfo> extends StatefulWidget {
  final ThemeData theme;
  final String title;
  final PageMiddleware<A, M> middleware;
  final List<PageWidget Function()> pages;
  final List<PageContainer<A, M> Function()> containers;
  final PageWidget Function() errorPage;

  EntryPage({
    @required this.middleware,
    this.pages,
    this.containers,
    this.theme,
    this.title,
    this.errorPage,
  }) : assert(middleware != null);

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  GoRouter _router;

  @override
  Widget build(BuildContext context) {
    final isLocalized = application.localization != null;
    var localizationDelegate = application.localization;

    if (_router == null) {
      final pages = this.widget.pages;
      final containers = this.widget.containers;
      var routes = <RouteBase>[];

      if (containers != null) {
        for (var i = 0; i < containers.length; i++) {
          final getContainer = containers[i];
          final container = getContainer();
          container.init(widget.middleware);

          routes.add(ShellRoute(
            navigatorKey: GlobalKey<NavigatorState>(),
            pageBuilder: (context, state, child) {
              container.prepare(context, state);
              return PageWidget.transitionBuilder(context: context, state: state, child: container.build(context, state, child));
            },
            routes: container.getRoutes(),
          ));
        }
      }

      if (pages != null) {
        for (var i = 0; i < pages.length; i++) {
          final getPage = pages[i];
          final page = getPage();
          page.init(widget.middleware);

          routes.add(GoRoute(
            name: page.name,
            path: '/${page.path}',
            pageBuilder: (context, state) {
              page.prepare(context, state);
              return PageWidget.transitionBuilder(context: context, state: state, child: page);
            },
            redirect: (context, GoRouterState state) async {
              return await page.redirect(context, state);
            },
            routes: page.getRoutes(),
          ));
        }
      }
      _router = GoRouter(
        routes: routes,
        errorPageBuilder: (context, state) {
          final page = widget.errorPage();
          page.init(widget.middleware, context: context, state: state);
          return PageWidget.transitionBuilder(context: context, state: state, child: page);
        },
        redirect: (context, GoRouterState state) async {
          return await widget.middleware?.redirect?.call(context, state, widget.middleware.scope);
        },
      );
    }

    return MaterialApp.router(
        routerConfig: _router,
        title: this.widget.title,
        theme: this.widget.theme ??
            ThemeData(
              primaryColor: application.settings.colors.primary,
              colorScheme: ColorScheme.light(
                primary: application.settings.colors.primary,
                secondary: application.settings.colors.secudary,
                secondaryContainer: application.settings.colors.navigation,
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
        debugShowCheckedModeBanner: false);
  }

  Application get application => widget.middleware.application;
}
