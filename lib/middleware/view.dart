import 'dart:async';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:after_init/after_init.dart';

import 'application.dart';
import 'scope.dart';

class ViewWidget extends StatefulWidget {
  final String name;
  final String title;
  final Application application;

  ViewWidget(
    this.name, {
    this.title,
    this.application,
  }) : assert(name != null);

  @override
  View createState() => View();
}

abstract class ViewState<T extends ViewWidget> extends State<T> {}

class View<T extends ViewWidget, A extends Application> extends ViewState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  ViewActionLocator _locator;
  Scope _scope;
  Scope _parent;
  Application _application;
  bool _initialized;

  View() {
    _scaffold = GlobalKey<ScaffoldState>();
    _locator = ViewActionLocator();
    _initialized = false;
  }

  void rasterize() {
    if (!mounted) return;
    setState(() {});
  }

  @protected
  Future init() async {}

  @protected
  void setup() => null;

  @override
  void didInitState() {
    var arguments = ModalRoute.of(context).settings.arguments;
    if (arguments is _PushedViewArguments) {
      _application = arguments.application;
      _parent = arguments.scope;
    }
    _scope = Scope(context, this);
    _init();
  }

  Future _init() async {
    await init();
    setup();
    _scope.window.overlay.apply();
  }

  @override
  initState() {
    super.initState();
    rasterize();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    prebuild();
    var scaffoldContent = Scaffold(
      key: _scaffold,
      appBar: header(),
      drawer: drawer(),
      floatingActionButton: action(),
      floatingActionButtonLocation: _locator,
      bottomNavigationBar: footer(),
      extendBody: _scope.window.overlay.extendBody,
      extendBodyBehindAppBar: _scope.window.overlay.extendBodyBehindAppBar,
      body: SafeArea(
        top: false,
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            if (_scope.isBusy) {
              return Future.value(false);
            } else {
              if (_scope.alerts.isAny) {
                _scope.alerts.dispose();
                return Future.value(false);
              }
              return beforePop();
            }
          },
          child: Container(
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
              _scope.window.update(constraints: viewportConstraints);
              /*if (keyboardActive != true) {
                viewport.available = Size(viewportConstraints.maxWidth, viewportConstraints.maxHeight);
              }*/
              return GestureDetector(
                onTap: () {
                  //FocusScope.of(context).requestFocus(new FocusNode());
                  _scope.unfocus();
                  _scope.alerts.dispose();
                },
                child: content(),
              );
            }),
          ),
        ),
      ),
    );

    return scaffoldContent;
  }

  @protected
  void prebuild() {}

  @protected
  PreferredSizeWidget header() => null;

  //TODO: RECONSIDER TO GENERATE THIS FROM APPLICATION.NAVIGATION
  @protected
  Widget drawer() => null;

  @protected
  Widget content() => Container();

  @protected
  Widget footer() => null;

  @protected
  Widget action() => null;

  @protected
  Future<bool> beforePop() async => !_scope.isBusy;

  void dismiss() {
    pop(null);
  }

  void submit([value]) {
    pop(value, force: true);
  }

  void pop(result, {bool force}) async {
    scope.idle();
    scope.alerts.dispose(quick: true);
    if (force == true) {
      Navigator.of(_scope.context).pop(result);
    } else {
      try {
        var value = await beforePop();
        if (value == true) {
          Navigator.of(_scope.context).pop(result);
        }
      } catch (err) {}
    }
  }

  Future<T> push<T>(ViewWidget view) async {
    scope.idle();
    scope.alerts.dispose(quick: true);
    var result = await Navigator.of(_scope.context).push(MaterialPageRoute(
      builder: (BuildContext context) => view,
      settings: RouteSettings(
          arguments: _PushedViewArguments<A>(
        application: application,
        scope: _scope,
      )),
    ));
    setup();
    _scope.window.overlay.apply();
    Future.delayed(Duration(milliseconds: 150), rasterize);
    Future.delayed(Duration(milliseconds: 250), rasterize);
    return result as T;
  }

  bool equals(String name) {
    return this.name == name;
  }

  String get name => widget.name;

  Scope get scope => _scope;

  Scope get parent => _parent;

  Window get window => _scope.window;

  A get application => (_application ?? widget.application) as A;

  Settings get settings => application?.settings;

  GlobalKey<ScaffoldState> get scaffold => _scaffold;

  String get title => widget?.title ?? application.title;

//TODO: THIS SHOULD BE IN APPLICATION CLASS
/*void toggleDrawer() {
    if (_scaffold.currentState.isDrawerOpen) {
      _scaffold.currentState.openEndDrawer();
    } else {
      _scaffold.currentState.openDrawer();
    }
  }*/
}

class _PushedViewArguments<A extends Application> {
  final A application;
  final Scope scope;

  _PushedViewArguments({
    this.application,
    this.scope,
  });
}
