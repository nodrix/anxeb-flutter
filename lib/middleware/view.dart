import 'dart:async';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:after_init/after_init.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'application.dart';
import 'panel.dart';
import 'scope.dart';

enum ViewTransitionType {
  fromBottom,
  fromLeft,
  fromRight,
  fromTop,
  fade,
}

class ViewWidget extends StatefulWidget {
  final String name;
  final String title;
  final Application application;
  final Key key;

  ViewWidget(
    this.name, {
    this.title,
    this.application,
    this.key,
  })  : assert(name != null),
        super(key: key);

  @override
  View createState() => View();
}

abstract class ViewState<T extends ViewWidget> extends State<T> {
  String name;

  Scope scope;

  Future<bool> dismiss();

  Future<bool> submit([value]);

  Future<bool> pop(result, {bool force});
}

class View<T extends ViewWidget, A extends Application> extends ViewState<T> with AfterInitMixin<T> {
  GlobalKey<ScaffoldState> _scaffold;
  ViewActionLocator _locator;
  Scope _scope;
  Scope _parent;
  Application _application;
  ViewPanel _panel;
  PanelController _panelController;

  View() {
    _scaffold = GlobalKey<ScaffoldState>();
    _locator = ViewActionLocator();
    _panelController = PanelController();
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
    _panel = _panel ?? panel(_panelController);

    prebuild();
    var $drawer = drawer();

    var scaffoldContent = Scaffold(
      key: _scaffold,
      appBar: header(),
      drawer: $drawer == true ? application.navigator.drawer() : ($drawer is Drawer ? $drawer : null),
      floatingActionButton: action(),
      floatingActionButtonLocation: _locator,
      bottomNavigationBar: footer(),
      extendBody: _scope.window.overlay.extendBody,
      extendBodyBehindAppBar: _scope.window.overlay.extendBodyBehindAppBar,
      body: WillPopScope(
        onWillPop: () async {
          if (_scope.isBusy) {
            return false;
          } else {
            if (_scope.alerts.isAny) {
              _scope.alerts.dispose();
              return false;
            } else if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
              scaffold.currentState.openEndDrawer();
              return false;
            }
            var result = await beforePop();
            if (result == true) {
              await closing();
            }
            return result;
          }
        },
        child: Container(
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            _scope.window.update(constraints: viewportConstraints);
            return GestureDetector(
              onTap: () {
                _scope.unfocus();
                _scope.alerts.dispose();
              },
              child: _panel != null ? _getPanel(_panel, content()) : content(),
            );
          }),
        ),
      ),
    );

    return scaffoldContent;
  }

  @protected
  void prebuild() {}

  @protected
  PreferredSizeWidget header() => null;

  @protected
  dynamic drawer() => null;

  @protected
  Widget content() => Container();

  @protected
  ViewPanel panel(PanelController controller) => null;

  @protected
  Widget footer() => null;

  @protected
  Widget action() => null;

  @protected
  Future<bool> beforePop() async => !_scope.isBusy;

  @protected
  Future closing() async {}

  Future<bool> dismiss() async => await pop(null);

  Future<bool> submit([value]) async => await pop(value, force: true);

  Future<bool> pop(result, {bool force}) async {
    scope.idle();
    scope.alerts.dispose(quick: true);

    if (force == true) {
      await _beginPop(result);
      return true;
    } else {
      try {
        var value = await beforePop();
        if (value == true) {
          await _beginPop(result);
          return true;
        }
      } catch (err) {}
    }
    return false;
  }

  Future<T> push<T>(ViewWidget view, {ViewTransitionType transition, int delay}) async {
    scope.idle();
    scope.alerts.dispose(quick: true);

    var settings = RouteSettings(
        arguments: _PushedViewArguments<A>(
      application: application,
      scope: _scope,
    ));

    var result = await Navigator.of(_scope.context).push(
      transition != null
          ? PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => view,
              settings: settings,
              transitionDuration: Duration(milliseconds: delay ?? 200),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                if (transition == ViewTransitionType.fade) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(animation),
                    child: FadeTransition(opacity: Tween<double>(begin: 1, end: .5).animate(secondaryAnimation), child: child),
                  );
                } else {
                  Offset from = Offset.zero;
                  Offset to = Offset.zero;

                  switch (transition) {
                    case ViewTransitionType.fromBottom:
                      from = Offset(0, 1);
                      to = Offset(0, -.5);
                      break;
                    case ViewTransitionType.fromLeft:
                      from = Offset(-1, 0);
                      to = Offset(.5, 0);
                      break;
                    case ViewTransitionType.fromRight:
                      from = Offset(1, 0);
                      to = Offset(-.5, 0);
                      break;
                    case ViewTransitionType.fromTop:
                      from = Offset(0, -1);
                      to = Offset(0, .5);
                      break;
                    case ViewTransitionType.fade:
                  }

                  return SlideTransition(
                    position: Tween<Offset>(begin: from, end: Offset.zero).animate(animation),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset.zero, end: to).animate(secondaryAnimation),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 1, end: 0.5).animate(secondaryAnimation),
                        child: child,
                      ),
                    ),
                  );
                }
              },
            )
          : MaterialPageRoute(builder: (BuildContext context) => view, settings: settings),
    );

    setup();
    _scope.window.overlay.apply();
    Future.delayed(Duration(milliseconds: 150), rasterize);
    Future.delayed(Duration(milliseconds: 250), rasterize);
    return result as T;
  }

  Future _beginPop(result) async {
    if (scaffold != null && scaffold.currentState != null && scaffold.currentState.isDrawerOpen) {
      scaffold.currentState.openEndDrawer();
    }
    await closing();
    Navigator.of(_scope.context).pop(result);
  }

  _getPanel(ViewPanel panel, Widget content) {
    return SlidingUpPanel(
      controller: _panelController,
      panel: Container(
        width: window.available.width,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: AnimatedOpacity(
                opacity: _panelController.isAttached && _panelController.isPanelClosed ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  height: 10,
                  width: 100,
                  margin: EdgeInsets.only(bottom: 40, top: 20),
                  decoration: BoxDecoration(
                    color: settings.colors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(30, 9),
                      topRight: Radius.elliptical(30, 9),
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(4),
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            panel.build(),
          ],
        ),
      ),
      backdropEnabled: true,
      renderPanelSheet: false,
      backdropTapClosesPanel: true,
      backdropOpacity: 0.36,
      body: content,
      minHeight: 48,
      maxHeight: panel.height ?? 200,
    );
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
}

class _PushedViewArguments<A extends Application> {
  final A application;
  final Scope scope;

  _PushedViewArguments({
    this.application,
    this.scope,
  });
}
