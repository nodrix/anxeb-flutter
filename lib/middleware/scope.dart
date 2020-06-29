import 'dart:async';

import 'package:flutter/material.dart';
import 'api.dart';
import 'application.dart';
import 'dialog.dart';
import 'disk.dart';
import 'form.dart';
import 'view.dart';
import 'alert.dart';
import 'sheet.dart';
import 'window.dart';

typedef void RefreshCallback(VoidCallback fn);

class Scope {
  BuildContext _context;
  View _view;
  Window _window;
  BuildContext _busyContext;
  ScopeDialogs _dialogs;
  ScopeAlerts _alerts;
  ScopeSheets _sheets;
  ScopeForms _forms;
  bool _idling;
  bool _busying;
  int _busyCountDown;

  Scope(BuildContext context, View view) {
    _context = context;
    _view = view;
    _window = Window(this);
    _dialogs = ScopeDialogs(this);
    _alerts = ScopeAlerts(this);
    _sheets = ScopeSheets(this);
    _forms = ScopeForms(this);
    _idling = false;
    _busying = false;
    _busyCountDown = 0;
  }

  void rasterize() {
    _view.rasterize();
  }

  Future _checkBusyCountDown() async {
    if (_busyCountDown == 1) {
      await idle();
      alerts.exception('Tiempo de espera excedido', title: 'Error de Proceso').show();
    } else if (_busyCountDown > 1) {
      Future.delayed(Duration(milliseconds: 1000), () {
        _busyCountDown--;
        _checkBusyCountDown();
      });
    }
  }

  Future busy({int timeout}) {
    var busyPromise = Completer();
    if (_busying == true || _busyContext != null) {
      busyPromise.complete();
    } else {
      _busying = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: ($context) {
          var length = window.horizontal(0.16);
          Future.delayed(Duration(milliseconds: 100), () {
            _busyContext = $context;
            _busying = false;
            busyPromise.complete();
          });
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
        },
      ).then((idlePromise) {
        Future.delayed(Duration(milliseconds: 100), () {
          _busyContext = null;
          _idling = false;
          (idlePromise as Completer).complete();
          rasterize();
        });
      });

      _busyCountDown = timeout ?? 8;
      _checkBusyCountDown();
    }
    return busyPromise.future;
  }

  Future idle() {
    _busyCountDown = 0;
    var idlePromise = Completer();
    if (_idling == true || _busyContext == null) {
      idlePromise.complete();
    } else {
      _idling = true;
      Navigator.of(_busyContext).pop(idlePromise);
    }
    return idlePromise.future;
  }

  void unfocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void focus(FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  BuildContext get context => _context;

  Window get window => _window;

  Application get application => _view.application;

  GlobalKey<ScaffoldState> get scaffold => _view.scaffold;

  View get view => _view;

  Api get api => application.api;

  Disk get disk => application.disk;

  ScopeDialogs get dialogs => _dialogs;

  ScopeAlerts get alerts => _alerts;

  ScopeSheets get sheets => _sheets;

  ScopeForms get forms => _forms;

  bool get isBusy => _busyContext != null;

  bool get isIdle => _busyContext == null;
}
