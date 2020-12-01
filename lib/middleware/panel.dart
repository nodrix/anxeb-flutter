import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'scope.dart';

class ViewPanel {
  final Scope scope;
  final double height;
  final bool Function() isDisabled;
  final bool gapless;
  final Color barColor;
  final bool showBar;
  final double backdropOpacity;
  final double minHeight;
  final Function(double position) onPanelSlide;
  PanelController _controller;
  bool rebuild = false;
  bool _display;

  ViewPanel({
    @required this.scope,
    this.height,
    this.isDisabled,
    this.gapless,
    this.barColor,
    this.showBar,
    this.backdropOpacity,
    this.minHeight,
    this.onPanelSlide,
  }) {
    _controller = PanelController();
    _display = true;
  }

  Future collapse() async => await _controller?.close();

  @protected
  Widget content([Widget child]) => child ?? Container();

  Widget wrap(Widget parent) {
    if (isDisabled?.call() == true) {
      return parent;
    }

    var panelContent = content();
    if (panelContent == null) {
      return parent;
    }

    return SlidingUpPanel(
      controller: _controller,
      onPanelSlide: (position) {
        onPanelSlide?.call(position);
        var disp = _controller.isAttached && position < 0.2;
        if (_display != disp) {
          scope.rasterize(() {
            _display = disp;
          });
        }
      },
      panel: Container(
        width: scope.window.available.width,
        color: Colors.transparent,
        child: showBar != false
            ? Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: AnimatedOpacity(
                      opacity: _display ? 1 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        height: 15,
                        width: 100,
                        margin: gapless == true ? EdgeInsets.only(bottom: 20, top: 35) : EdgeInsets.only(bottom: 35, top: 20),
                        decoration: BoxDecoration(
                          color: barColor ?? (gapless == true ? scope.application.settings.colors.navigation : scope.application.settings.colors.primary),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(30, gapless == true ? 15 : 9),
                            topRight: Radius.elliptical(30, gapless == true ? 15 : 9),
                            bottomLeft: gapless == true ? Radius.zero : Radius.circular(3),
                            bottomRight: gapless == true ? Radius.zero : Radius.circular(3),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.all(4),
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  panelContent,
                ],
              )
            : panelContent,
      ),
      backdropEnabled: true,
      renderPanelSheet: false,
      backdropTapClosesPanel: true,
      backdropOpacity: backdropOpacity ?? 0.36,
      body: parent,
      minHeight: minHeight ?? 48,
      maxHeight: dynamicHeight ?? height ?? 200,
    );
  }

  @protected
  double get dynamicHeight => null;
}
