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

  ScrollableContainer({
    Key key,
    @required this.child,
    @required this.scope,
    this.fadding,
    this.padding,
    this.controller,
    this.fixedHeight,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        controller: controller,
        child: Container(
          height: fixedHeight == true ? scope.window.available.height : null,
          padding: Utils.convert.toFraction(fadding, scope.window.size),
          child: Padding(
            padding: padding != null ? padding : const EdgeInsets.all(0),
            child: child,
          ),
        ),
      ),
    );
  }
}
