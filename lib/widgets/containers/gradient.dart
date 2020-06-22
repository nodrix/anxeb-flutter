import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets fadding;
  final EdgeInsets padding;
  final Gradient gradient;
  final Scope scope;
  final Image image;

  GradientContainer({
    Key key,
    @required this.child,
    @required this.scope,
    this.fadding,
    this.padding,
    this.gradient,
    this.image,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: gradient != null
                ? BoxDecoration(
                    gradient: gradient,
                  )
                : null,
          ),
          image ?? Container(),
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Container(
              padding: Utils.convert.toFraction(fadding, scope.window.size),
              child: this.child,
            ),
          ),
        ],
      ),
    );
  }
}
