import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class ScrollableContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets fadding;
  final EdgeInsets padding;
  final ScrollController controller;
  final Scope scope;
  final bool fixedHeight;
  final bool disablePhysics;

  ScrollableContainer({
    Key key,
    @required this.child,
    @required this.scope,
    this.fadding,
    this.padding,
    this.controller,
    this.fixedHeight,
    this.disablePhysics,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fixedHeight == true ? scope.window.available.height : null,
      child: SingleChildScrollView(
        physics: disablePhysics == true ? NeverScrollableScrollPhysics() : null,
        controller: controller,
        child: Container(
          padding: fadding != null ? Utils.convert.fromInsetToFraction(fadding, scope.window.size) : null,
          child: Padding(
            padding: padding != null ? padding : const EdgeInsets.all(0),
            child: child,
          ),
        ),
      ),
    );
  }
}
