import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ViewPanel {
  final double height;
  final PanelController controller;
  Widget _body;
  bool rebuild;

  ViewPanel({this.height, this.controller, Widget body}) {
    _body = body;
    rebuild = false;
  }

  Future collapse() async => await controller?.close();

  Widget build() => _body ?? Container();
}
