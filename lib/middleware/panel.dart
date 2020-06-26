import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ViewPanel {
  final double height;
  final PanelController controller;
  Widget _body;

  ViewPanel({this.height, this.controller, Widget body}) {
    _body = body;
  }

  Future collapse() async => await controller?.close();

  Widget build() => _body ?? Container();
}
