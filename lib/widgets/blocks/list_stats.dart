import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class ListStatsBlock extends StatelessWidget {
  final Anxeb.Scope scope;
  final String text;
  final Color color;
  final IconData icon;
  final EdgeInsets iconPadding;
  final bool visible;
  final double scale;
  final double fontSize;

  ListStatsBlock({
    this.scope,
    this.text,
    this.color,
    this.icon,
    this.iconPadding,
    this.visible,
    this.scale,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (visible == false || text == null) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: <Widget>[
          Container(
            padding: iconPadding,
            child: Icon(
              icon,
              size: 12 * (scale ?? 1.0),
              color: color,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Settings get settings => scope.application.settings;
}
