import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class BasicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets fadding;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Scope scope;

  BasicContainer({
    Key key,
    @required this.child,
    @required this.scope,
    this.fadding,
    this.padding,
    this.margin,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Container(
          padding: Utils.convert.toFraction(fadding, scope.window.size),
          margin: margin ?? EdgeInsets.zero,
          child: this.child,
        ),
      ),
    );
  }
}
