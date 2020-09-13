import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceholderBlock extends StatelessWidget implements PreferredSizeWidget {
  final double Function() height;
  final Widget Function() body;
  final bool Function() isVisible;

  PlaceholderBlock({
    @required this.height,
    @required this.body,
    this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (isVisible?.call() == false) {
      return null;
    }
    return body();
  }

  Size get preferredSize => Size.fromHeight(height());
}
