import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'scope.dart';

class ViewPanel {
  final Scope scope;
  final double height;
  final bool Function() isDisabled;
  PanelController _controller;
  bool rebuild = false;

  ViewPanel({
    @required this.scope,
    this.height,
    this.isDisabled,
  }) {
    _controller = PanelController();
  }

  Future collapse() async => await _controller?.close();

  @protected
  Widget content([Widget child]) => child ?? Container();

  Widget wrap(Widget parent) {
    if (isDisabled?.call() == true) {
      return parent;
    }
    return SlidingUpPanel(
      controller: _controller,
      panel: Container(
        width: scope.window.available.width,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: AnimatedOpacity(
                opacity: _controller.isAttached && _controller.isPanelClosed ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  height: 10,
                  width: 100,
                  margin: EdgeInsets.only(bottom: 40, top: 20),
                  decoration: BoxDecoration(
                    color: scope.application.settings.colors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(30, 9),
                      topRight: Radius.elliptical(30, 9),
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
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
            content(),
          ],
        ),
      ),
      backdropEnabled: true,
      renderPanelSheet: false,
      backdropTapClosesPanel: true,
      backdropOpacity: 0.36,
      body: parent,
      minHeight: 48,
      maxHeight: height ?? 200,
    );
  }
}
