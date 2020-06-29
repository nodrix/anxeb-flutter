import 'dart:async';

import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';
import 'actions.dart';

class SearchHeader extends ActionsHeader {
  final bool actionRightPositioned;
  final int submitDelay;
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
    List<ActionIcon> actions,
    VoidCallback dismiss,
    VoidCallback back,
    ActionIcon leading,
    this.actionRightPositioned,
    this.hint,
    this.submitDelay,
    this.onSearch,
    this.onClear,
    this.onCompleted,
    this.onBegin,
  }) : super(scope: scope, dismiss: dismiss, back: back, leading: leading) {
    super.actions = actions ?? List<ActionIcon>();

    if (actionRightPositioned == true) {
      super.actions.add(ActionIcon(icon: () => Icons.search, onPressed: _beginSearch));
    } else {
      super.actions.insert(0, ActionIcon(icon: () => Icons.search, onPressed: _beginSearch));
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
      if (submitDelay != null && submitDelay > 0) {
        searchTick = DateTime.now().toUtc().millisecondsSinceEpoch;

        if (writeTimer == null || writeTimer.isActive == false) {
          writeTimer = Timer.periodic(new Duration(milliseconds: submitDelay ?? 250), (timer) {
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

  Future _clear() async {
    _busy = true;
    scope.rasterize();
    await onClear?.call();
    _inputController.clear();
    _currentText = '';
    _busy = false;
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
    await onCompleted?.call(_inputController.text);
    _inputController.clear();
    _currentText = '';
    _active = false;
    _busy = false;
    scope.rasterize();
  }

  void _focusSearch() {
    Future.delayed(Duration(milliseconds: 200), () {
      scope.focus(_focusNode);
      _inputController.selection = TextSelection(baseOffset: 0, extentOffset: _inputController.text.length);
    });
  }

  AppBar _buildSearchBar() {
    var $actions = List<Widget>();

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
          _clear();
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
      automaticallyImplyLeading: false,
      leading: BackButton(
        onPressed: () {
          _endSearch();
        },
      ),
    );
  }

  @override
  PreferredSizeWidget build() => _active ? _buildSearchBar() : super.build();
}
