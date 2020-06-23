import 'dart:io';

import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class FooterPart extends StatefulWidget {
  final Scope scope;
  final Widget child;

  FooterPart({this.child, this.scope});

  @override
  _FooterPartState createState() => _FooterPartState();
}

class _FooterPartState extends State<FooterPart> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: widget.scope.application.settings.colors.primary,
      notchMargin: 8,
      elevation: 20,
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: Platform.isAndroid
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.white),
                ),
              )
            : null,
        child: widget.child,
      ),
      shape: CircularNotchedRectangle(),
    );
  }
}
