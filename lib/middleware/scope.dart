import 'dart:async';
import 'package:anxeb_flutter/screen/scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'api.dart';
import 'application.dart';
import 'auth.dart';
import 'dialog.dart';
import 'disk.dart';
import 'analytics.dart';
import 'form.dart';
import 'alert.dart';
import 'sheet.dart';
import 'window.dart';

typedef void RefreshCallback(VoidCallback fn);

abstract class IScope {
  Application get application;

  String get key;

  String get title;

  bool get mounted;

  int get tick;

  void rasterize([VoidCallback fn]);

  void retick();

  Future<bool> dismiss();
}

class Scope {
  BuildContext _context;
  Window _window;
  BuildContext _busyContext;
  ScopeDialogs _dialogs;
  ScopeAlerts _alerts;
  ScopeSheets _sheets;
  ScopeForms _forms;
  bool _idling;
  bool _busying;
  int _busyCountDown;
  int tick;

  dynamic box;

  Scope(BuildContext context) {
    _context = context;
    _window = Window(this);
    _dialogs = ScopeDialogs(this);
    _alerts = ScopeAlerts(this);
    _sheets = ScopeSheets(this);
    _forms = ScopeForms(this);
    _idling = false;
    _busying = false;
    _busyCountDown = 0;
    tick = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  bool get mounted => null;

  void rasterize([VoidCallback fn]) {}

  Future<bool> dismiss() => null;

  Future _checkBusyCountDown() async {
    if (_busyCountDown == 1) {
      await idle();
      alerts.exception(translate('anxeb.middleware.scope.busy_timeout'), title: translate('anxeb.middleware.scope.process_error')).show();
    } else if (_busyCountDown > 1) {
      Future.delayed(Duration(milliseconds: 1000), () {
        _busyCountDown--;
        _checkBusyCountDown();
      });
    }
  }

  void retick() {
    tick = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  Future setup() async {
    if (application.settings.analytics.available == true) {
      application.analytics.setup(scope: this);
    }
    application?.onEvent?.call(ApplicationEventType.view, reference: key);
  }

  void dispose() {
    if (application.settings.analytics.available == true) {
      application.analytics.reset();
    }
  }

  Future busy({int timeout, String text, bool dismissable = true}) {
    var busyPromise = Completer();
    var textedDialog = text != null;
    alerts.dispose().then((value) {
      if (_busying == true || _busyContext != null) {
        busyPromise.complete();
      } else {
        _busying = true;

        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            return WillPopScope(
              onWillPop: () async {
                return dismissable != false;
              },
              child: SafeArea(
                child: Builder(builder: (BuildContext $context) {
                  var length = window.horizontal(0.16);
                  if (length > 60) {
                    length = 60;
                  }
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (_busying == true || _busyContext != null) {
                      _busying = false;
                      _busyContext = $context;
                      if (!busyPromise.isCompleted) {
                        busyPromise.complete();
                      }
                    }
                  });
                  if (textedDialog) {
                    return Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 15),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: application.settings.colors.busybox ?? Color(0xd9666666),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 8),
                                  blurRadius: 20,
                                  spreadRadius: -10,
                                  color: Color(0x98000000),
                                )
                              ],
                              borderRadius: new BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(application.settings.colors.foreground ?? Color(0xffefefef)),
                                  ),
                                  height: 32,
                                  width: 32,
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(text ?? translate('anxeb.common.loading'), //TR 'Cargando'
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w200,
                                        color: application.settings.colors.foreground ?? Colors.white,
                                        decoration: TextDecoration.none,
                                      )),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffefefef)),
                      ),
                      height: length,
                      width: length,
                    ),
                  );
                }),
              ),
            );
          },
          barrierDismissible: false,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: textedDialog ? Colors.transparent : (application.settings.colors.backdrop ?? Colors.black54),
          transitionDuration: const Duration(milliseconds: 150),
        ).then((idlePromise) {
          Future.delayed(Duration(milliseconds: 100), () {
            _busyContext = null;
            _idling = false;
            (idlePromise as Completer)?.complete?.call();
            rasterize();
          });
        });

        if (timeout == null || timeout > 0) {
          _busyCountDown = timeout ?? 30;
          _checkBusyCountDown();
        }
      }
    });
    return busyPromise.future;
  }

  Future idle() {
    _busyCountDown = 0;
    var idlePromise = Completer();
    if (_idling == true || _busyContext == null) {
      idlePromise.complete();
    } else {
      _idling = true;
      if (this is ScreenScope) {
        Navigator.of(_busyContext).pop(idlePromise);
      } else {
        GoRouter.of(_busyContext).pop(idlePromise);
      }
    }
    rasterize();
    return idlePromise.future;
  }

  final _focusNode = new FocusNode();

  void unfocus() {
    if (mounted == true && _focusNode.hasFocus != true) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void focus(FocusNode node) {
    if (mounted == true && node?.context != null && node.hasFocus != true) {
      FocusScope.of(context).requestFocus(node);
    }
  }

  BuildContext get context => _context;

  Window get window => _window;

  Analytics get analytics => application.analytics;

  Api get api => application.api;

  Disk get disk => application.disk;

  ScopeDialogs get dialogs => _dialogs;

  ScopeAlerts get alerts => _alerts;

  ScopeSheets get sheets => _sheets;

  ScopeForms get forms => _forms;

  Application get application => null;

  String get key => null;

  String get title => null;

  AuthProviders get auths => application.auths;

  bool get isBusy => _busyContext != null;

  bool get isIdle => _busyContext == null;
}
