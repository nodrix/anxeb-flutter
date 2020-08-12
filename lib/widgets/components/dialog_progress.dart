import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DialogProgress extends StatefulWidget {
  final DialogProcessController controller;
  final Scope scope;

  const DialogProgress({
    this.scope,
    this.controller,
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
              child: Text('Error completando carga de archivo', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.danger)),
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
              child: Text('Carga completada exitosamente', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.success)),
            )
          ],
        ),
      );
    }

    if (widget.controller.isCompleted) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.success),
              ),
              height: widget.scope.window.horizontal(0.22),
              width: widget.scope.window.horizontal(0.22),
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Text('  Completando...', style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.primary)),
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

enum DialogProcessState { idle, process, success, failed, canceled }

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
    _state = DialogProcessState.process;
    this.total = total;
    this.value = value;
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

  void failed() async {
    _state = DialogProcessState.failed;
  }

  Future _pop() async {
    if (_refreshHandler?.call() == true) {
      await Future.delayed(Duration(milliseconds: 1000));
      _completeHandler?.call();
    }
  }

  void success() async {
    _state = DialogProcessState.success;
    if (!isCanceled) {
      if (_refreshHandler?.call() == true) {
        await Future.delayed(Duration(milliseconds: 1000));
        _completeHandler?.call();
      }
    }
  }

  bool get isCanceled => _state == DialogProcessState.canceled;

  bool get isFailed => _state == DialogProcessState.failed;

  bool get isCompleted => this.value != null && this.total != null && this.value >= this.total && this.value > 0;

  bool get isSuccess => _state == DialogProcessState.success;
}
