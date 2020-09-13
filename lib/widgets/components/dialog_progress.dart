import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DialogProgress extends StatefulWidget {
  final DialogProcessController controller;
  final Scope scope;
  final bool isDownload;
  final String failedMessage;
  final String successMessage;
  final String busyMessage;

  const DialogProgress({
    this.scope,
    this.controller,
    this.isDownload,
    this.failedMessage,
    this.successMessage,
    this.busyMessage,
  });

  @override
  _DialogProgressState createState() => _DialogProgressState();
}

class _DialogProgressState extends State<DialogProgress> {
  @override
  void initState() {
    widget.controller._subscribe(() {
      if (mounted) {
        setState(() {});
        return true;
      } else {
        return false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isFailed) {
      return Container(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: widget.scope.window.horizontal(0.32),
              color: widget.scope.application.settings.colors.danger,
            ),
            Container(
              margin: EdgeInsets.only(top: 1),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(widget.failedMessage ?? 'Error completando ${(widget.isDownload == true ? 'descarga' : 'carga')} de archivo', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.danger)),
            )
          ],
        ),
      );
    }

    if (widget.controller.isSuccess) {
      return Container(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: widget.scope.window.horizontal(0.32),
              color: widget.scope.application.settings.colors.success,
            ),
            Container(
              margin: EdgeInsets.only(top: 1),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(widget.successMessage ?? '${(widget.isDownload == true ? 'Descarga' : 'Carga')} completada exitosamente', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.success)),
            )
          ],
        ),
      );
    }

    if (_percent == 0 || (widget.controller.isCompleted && !widget.controller.isDone)) {
      var size = widget.scope.window.horizontal(0.32) - 6;
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.success),
              ),
              height: size,
              width: size,
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Text(_percent == 0 ? '   Iniciando...' : (widget.busyMessage ?? '  Completando...'), style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.primary)),
            )
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(5),
      child: CircularPercentIndicator(
        radius: widget.scope.window.horizontal(0.32),
        lineWidth: 5.0,
        animation: true,
        backgroundColor: widget.scope.application.settings.colors.separator,
        animationDuration: 0,
        percent: _percent,
        progressColor: widget.scope.application.settings.colors.primary,
        center: Text(
          Utils.convert.fromAnyToNumber((_percent * 100), comma: false, decimals: 2),
          style: TextStyle(
            fontSize: 25,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w300,
            color: widget.scope.application.settings.colors.primary,
          ),
        ),
      ),
    );
  }

  double get _percent => widget.controller == null || widget.controller.total == 0 ? 0 : ((widget.controller.value ?? 0) / (widget.controller.total ?? 1));
}

enum DialogProcessState { idle, process, completed, success, failed, canceled, done }

class DialogProcessController {
  double total;
  double value;
  DialogProcessState _state;
  bool Function() _refreshHandler;
  Function() _completeHandler;
  Function() _cancelHandler;

  void _subscribe(Function() refresher) {
    _refreshHandler = refresher;
  }

  void onCompleted(Function() completer) {
    _completeHandler = completer;
  }

  void onCanceled(Function() canceler) {
    _cancelHandler = canceler;
  }

  void update({double total, double value}) {
    this.total = total;
    this.value = value;

    if (this.value != null && this.total != null && this.value >= this.total && this.value > 0) {
      _state = DialogProcessState.completed;
      Future.delayed(Duration(milliseconds: 800), () {
        _refreshHandler?.call();
      });
    } else {
      _state = DialogProcessState.process;
    }
    if (_refreshHandler?.call() == false) {
      _cancel(pop: false);
    }
  }

  Future cancel() async {
    await _cancel(pop: false);
  }

  Future _cancel({bool pop}) async {
    if (_state == DialogProcessState.process) {
      _cancelHandler?.call();
      _state = DialogProcessState.canceled;
      if (pop != false) {
        await _pop();
      }
    }
  }

  Future failed() async {
    _state = DialogProcessState.failed;
    _refreshHandler?.call();
  }

  Future _pop({bool quick, int delay}) async {
    try {
      if (_refreshHandler?.call() == true) {
        if (quick == true) {
          _completeHandler?.call();
        } else {
          await Future.delayed(Duration(milliseconds: delay ?? 1000));
          _completeHandler?.call();
          await Future.delayed(Duration(milliseconds: 200));
        }
      }
    } catch (err) {}
  }

  Future pop() async {
    _pop(quick: true);
  }

  Future success({bool silent}) async {
    if (silent == true) {
      _state = DialogProcessState.done;
      if (!isCanceled) {
        _pop(quick: true);
      }
    } else {
      _state = DialogProcessState.success;
      if (!isCanceled) {
        await _pop();
      }
    }
  }

  bool get isDone => _state == DialogProcessState.done;

  bool get isProcess => _state == DialogProcessState.process;

  bool get isCanceled => _state == DialogProcessState.canceled;

  bool get isFailed => _state == DialogProcessState.failed;

  bool get isCompleted => _state == DialogProcessState.completed;

  bool get isSuccess => _state == DialogProcessState.success;
}
