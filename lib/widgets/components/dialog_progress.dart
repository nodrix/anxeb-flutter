import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

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
    var size = widget.scope.window.horizontal(0.28);
    if (size > 140) {
      size = 140;
    }

    if (widget.controller.isFailed) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10.0,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.danger),
                  ),
                  height: size,
                  width: size,
                ),
                Icon(
                  FontAwesome5.exclamation,
                  size: size - 40,
                  color: widget.scope.application.settings.colors.danger,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.controller.failedMessage ?? widget.failedMessage ?? (widget.isDownload == true ? translate('anxeb.widgets.components.dialog_progress.download_failed') : translate('anxeb.widgets.components.dialog_progress.upload_failed')),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.danger),
              ),
            )
          ],
        ),
      );
    }

    if (widget.controller.isSuccess) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10.0,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.success),
                  ),
                  height: size,
                  width: size,
                ),
                Icon(
                  Icons.check,
                  size: size - 40,
                  color: widget.scope.application.settings.colors.success,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.successMessage ?? (widget.isDownload == true ? translate('anxeb.widgets.components.dialog_progress.download_success') : translate('anxeb.widgets.components.dialog_progress.upload_success')),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.success),
              ),
            )
          ],
        ),
      );
    }

    if (_percent == 0 || (widget.controller.isCompleted && !widget.controller.isDone)) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 10.0,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.success),
                  ),
                  height: size,
                  width: size,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _percent == 0 ? translate('anxeb.widgets.components.dialog_progress.init_label') : (widget.busyMessage ?? translate('anxeb.widgets.components.dialog_progress.processing_label')),
                style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.primary),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                child: CircularProgressIndicator(
                  value: _percent,
                  strokeWidth: 10.0,
                  backgroundColor: widget.scope.application.settings.colors.separator,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.primary),
                ),
                height: size,
                width: size,
              ),
              Text(
                '${Utils.convert.fromAnyToNumber((_percent * 100), comma: false, decimals: 1)}%',
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w300,
                  color: widget.scope.application.settings.colors.primary,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.busyMessage ?? translate('anxeb.widgets.components.dialog_progress.processing_label'),
              style: TextStyle(fontSize: 16, color: widget.scope.application.settings.colors.primary),
            ),
          )
        ],
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
  Function(dynamic result) _completeHandler;
  Function() _cancelHandler;
  String _failedMessage;

  void _subscribe(Function() refresher) {
    _refreshHandler = refresher;
  }

  void onCompleted(Function(dynamic result) completer) {
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

  Future failed({String message}) async {
    _failedMessage = message;
    _state = DialogProcessState.failed;

    _refreshHandler?.call();
  }

  Future _pop({dynamic result, bool quick, int delay}) async {
    try {
      if (_refreshHandler?.call() == true) {
        if (quick == true) {
          _completeHandler?.call(result);
        } else {
          await Future.delayed(Duration(milliseconds: delay ?? 1000));
          _completeHandler?.call(result);
          await Future.delayed(Duration(milliseconds: 200));
        }
      }
    } catch (err) {}
  }

  Future pop() async {
    _pop(quick: true);
  }

  Future success({dynamic result, bool silent}) async {
    if (silent == true) {
      _state = DialogProcessState.done;
      if (!isCanceled) {
        _pop(quick: true, result: result);
      }
    } else {
      _state = DialogProcessState.success;
      if (!isCanceled) {
        await _pop(result: result);
      }
    }
  }

  String get failedMessage => _failedMessage;

  bool get isDone => _state == DialogProcessState.done;

  bool get isProcess => _state == DialogProcessState.process;

  bool get isCanceled => _state == DialogProcessState.canceled;

  bool get isFailed => _state == DialogProcessState.failed;

  bool get isCompleted => _state == DialogProcessState.completed;

  bool get isSuccess => _state == DialogProcessState.success;
}
