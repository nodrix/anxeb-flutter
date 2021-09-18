import 'dart:async';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';
import 'actions.dart';

class SearchHeader extends ActionsHeader {
  final bool actionRightPositioned;
  final int Function() submitDelay;
  final String hint;
  final Future Function(String text) onSearch;
  final Future Function() onClear;
  final Function(String text) onCompleted;
  final Future Function() onBegin;
  TextEditingController _inputController;
  FocusNode _focusNode;
  String _currentText;
  bool _active;
  bool _busy;

  SearchHeader({
    Scope scope,
    String Function() title,
    List<ActionItem> actions,
    VoidCallback dismiss,
    VoidCallback back,
    ActionIcon leading,
    Widget Function() bottom,
    double Function() elevation,
    double Function() height,
    this.actionRightPositioned,
    this.hint,
    this.submitDelay,
    this.onSearch,
    this.onClear,
    this.onCompleted,
    this.onBegin,
  }) : super(scope: scope, dismiss: dismiss, back: back, leading: leading, title: title, bottom: bottom, elevation: elevation, height: height) {
    super.actions = actions ?? <ActionItem>[];

    if (actionRightPositioned == true) {
      ActionItem item = ActionIcon(icon: () => Icons.search, onPressed: _beginSearch);
      super.actions.add(item);
    } else {
      ActionItem item = ActionIcon(icon: () => Icons.search, onPressed: _beginSearch);
      super.actions.insert(0, item);
    }
    _init();
  }

  void _init() {
    _inputController = new TextEditingController();
    _focusNode = FocusNode();
    _busy = false;
    _active = false;
    _currentText = '';
    Timer writeTimer;
    int searchTick;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_active == true && _busy != true) {
          _endSearch();
        }
      }
    });

    _inputController.addListener(() {
      if (submitDelay != null && submitDelay() != null && submitDelay() > 0) {
        searchTick = DateTime.now().toUtc().millisecondsSinceEpoch;

        if (writeTimer == null || writeTimer.isActive == false) {
          writeTimer = Timer.periodic(new Duration(milliseconds: submitDelay() ?? 250), (timer) {
            var currentTick = DateTime.now().toUtc().millisecondsSinceEpoch;
            if (currentTick - searchTick > 500) {
              _lookup(_inputController.text);
              writeTimer.cancel();
            }
          });
        }
      } else {
        _lookup(_inputController.text);
      }
    });
  }

  Future _lookup(String text) async {
    if (_currentText != text) {
      _currentText = text;
      _busy = true;
      scope.rasterize();
      await onSearch?.call(_currentText);
      _busy = false;
      scope.rasterize();
    }
  }

  Future clear({bool inactivate}) async {
    _busy = true;
    scope.rasterize();
    await onClear?.call();
    _inputController.clear();
    _currentText = '';
    _busy = false;
    if (inactivate == true) {
      _active = false;
    }
    scope.rasterize();
  }

  Future _beginSearch() async {
    _active = true;
    _busy = true;
    scope.rasterize();
    await onBegin?.call();
    _inputController.clear();
    _currentText = '';
    _focusSearch();
    _busy = false;
    scope.rasterize();
  }

  Future _endSearch() async {
    _busy = true;
    scope.rasterize();
    var result = _inputController.text;
    _inputController.clear();
    _currentText = '';
    _active = false;
    _busy = false;
    await onCompleted?.call(result);
    scope.rasterize();
  }

  Future end() async {
    await _endSearch();
  }

  void _focusSearch() {
    Future.delayed(Duration(milliseconds: 200), () {
      scope.focus(_focusNode);
      _inputController.selection = TextSelection(baseOffset: 0, extentOffset: _inputController.text.length);
    });
  }

  AppBar _buildSearchBar() {
    var $actions = <Widget>[];

    if (_busy) {
      $actions.add(Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(right: 15),
        child: SizedBox(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffffffff)),
          ),
          width: 18,
          height: 18,
        ),
      ));
    } else if (_inputController.text.length > 0) {
      $actions.add(IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          clear();
        },
      ));
    }

    return AppBar(
      title: TextField(
        controller: _inputController,
        focusNode: _focusNode,
        autofocus: true,
        cursorColor: Colors.white,
        decoration: InputDecoration.collapsed(
          hintText: hint ?? 'Búsqueda',
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.white60, fontSize: 20.0, decoration: TextDecoration.none, fontWeight: FontWeight.w500),
        ),
        style: const TextStyle(
          decoration: TextDecoration.none,
          textBaseline: TextBaseline.alphabetic,
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: (val) {
          _endSearch();
        },
        onTap: _focusSearch,
        onChanged: (val) {
          scope.rasterize();
        },
      ),
      actions: $actions,
      bottom: scope?.view?.parts?.tabs?.header?.call(bottomBody: bottom?.call(), height: height) ?? bottom?.call(),
      automaticallyImplyLeading: false,
      leading: BackButton(
        onPressed: () {
          _endSearch();
        },
      ),
    );
  }

  String get text => _currentText;

  bool get isActive => _active == true;

  bool get isNotEmpty => _currentText?.isNotEmpty == true;

  bool get isEmpty => !isNotEmpty;

  @override
  PreferredSizeWidget build() => _active ? _buildSearchBar() : super.build();
}
