import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CaptionBlock extends StatelessWidget {
  final Scope scope;
  final String title;
  final String trailTitle;
  final EdgeInsets margin;
  final IconData icon;
  final double iconSize;
  final bool visible;

  const CaptionBlock({
    @required this.scope,
    @required this.title,
    this.trailTitle,
    this.margin,
    this.icon,
    this.iconSize,
    this.visible,
  }) : assert(title != null);

  @override
  Widget build(BuildContext context) {
    if (this.visible == false) {
      return Container();
    }

    return Container(
      margin: margin,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 5, top: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.5, color: scope.application.settings.colors.primary)),
              ),
              child: Row(
                children: <Widget>[
                  icon != null
                      ? Container(
                          width: 33,
                          child: Icon(icon, size: iconSize != null ? iconSize : 25, color: scope.application.settings.colors.primary),
                        )
                      : Container(),
                  Expanded(
                    child: new Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: scope.application.settings.colors.secudary,
                      ),
                    ),
                  ),
                  trailTitle != null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            trailTitle,
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              color: scope.application.settings.colors.text.withOpacity(0.8),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
