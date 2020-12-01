import 'package:anxeb_flutter/middleware/panel.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class BoardPanel extends ViewPanel {
  final Widget child;
  bool _rebuild;
  BoxDecoration _decoration;
  EdgeInsets _padding;
  EdgeInsets _margin;
  Color _fill;

  BoardPanel({
    Scope scope,
    this.child,
    double height,
    bool Function() isDisabled,
    bool gapless,
    Color barColor,
    bool showBar,
    bool rebuild,
    BoxDecoration decoration,
    EdgeInsets padding,
    EdgeInsets margin,
    Color fill,
    double backdropOpacity,
    double minHeight,
    Function(double state) onPanelSlide,
  }) : super(
          scope: scope,
          height: height ?? 400,
          isDisabled: isDisabled,
          gapless: gapless,
          barColor: barColor,
          showBar: showBar,
          backdropOpacity: backdropOpacity,
          minHeight: minHeight,
          onPanelSlide: onPanelSlide,
        ) {
    _rebuild = rebuild;
    _decoration = decoration;
    _padding = padding;
    _margin = margin;
    _fill = fill;
  }

  @override
  Widget content([Widget child]) {
    return super.content(Container(
      height: (dynamicHeight ?? height) - 70,
      width: scope.window.available.width,
      margin: _margin ?? EdgeInsets.symmetric(horizontal: margins),
      padding: _padding ?? EdgeInsets.all(paddings),
      decoration: _decoration ??
          BoxDecoration(
            boxShadow: [shadow],
            shape: BoxShape.rectangle,
            borderRadius: radius != null ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius)) : null,
            color: fill,
          ),
      child: this.child ?? child,
    ));
  }

  @protected
  BoxShadow get shadow => BoxShadow(offset: Offset(0, 6), blurRadius: 5, spreadRadius: 3, color: Color(0x3f555555));

  @protected
  double get radius => 10;

  @protected
  Color get fill => _fill ?? Colors.white;

  @protected
  double get paddings => 12;

  @protected
  double get margins => 12;

  @override
  bool get rebuild => _rebuild ?? false;
}
