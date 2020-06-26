import 'package:anxeb_flutter/middleware/panel.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BoardPanel extends ViewPanel {
  final Scope scope;
  double _height;

  BoardPanel({this.scope, double height, PanelController controller}) : super(controller: controller) {
    _height = height ?? 400;
  }

  @override
  double get height => _height - 70;

  @protected
  Widget content() {
    return Container();
  }

  @override
  Widget build() {
    return Container(
      height: height - 70,
      margin: EdgeInsets.symmetric(horizontal: margins),
      padding: EdgeInsets.all(paddings),
      decoration: BoxDecoration(
        boxShadow: [shadow],
        shape: BoxShape.rectangle,
        borderRadius: radius != null ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius)) : null,
        color: fill,
      ),
      child: content(),
    );
  }

  @protected
  BoxShadow get shadow => BoxShadow(offset: Offset(0, 6), blurRadius: 5, spreadRadius: 3, color: Color(0x3f555555));

  @protected
  double get radius => 10;

  @protected
  Color get fill => Colors.white;

  @protected
  double get paddings => 12;

  @protected
  double get margins => 12;
}
