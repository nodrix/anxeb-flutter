import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class BasicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets fadding;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Scope scope;
  final bool fixedHeight;

  BasicContainer({
    Key key,
    @required this.child,
    @required this.scope,
    this.fadding,
    this.padding,
    this.margin,
    this.fixedHeight,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fixedHeight == true ? scope.window.available.height : null,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Container(
          padding: fadding != null ? Utils.convert.fromInsetToFraction(fadding, scope.window.size) : null,
          margin: margin ?? EdgeInsets.zero,
          child: this.child,
        ),
      ),
    );
  }
}
