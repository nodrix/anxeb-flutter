import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTitleBlock extends StatelessWidget {
  final Anxeb.Scope scope;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final bool busy;
  final IconData icon;
  final EdgeInsets iconPadding;
  final Color iconColor;
  final double iconScale;
  final IconData iconAlt;
  final EdgeInsets iconAltPadding;
  final Color iconAltColor;
  final double iconAltScale;
  final IconData iconTrail;
  final Color iconTrailColor;
  final double iconTrailScale;
  final bool divisor;
  final Color divisorColor;
  final TextStyle titleStyle;
  final String title;
  final TextOverflow titleOverflow;
  final Color titleColor;
  final String titleTrail;
  final Color titleTrailColor;
  final String subtitle;
  final TextOverflow subtitleOverflow;
  final Color subtitleColor;
  final String subtitleTrail;
  final TextStyle subtitleTrailStyle;
  final Color subtitleTrailColor;
  final GestureTapCallback onTap;
  final Color splashColor;
  final Color splashHihglight;
  final Widget body;
  final Color fillColor;
  final Decoration decoration;
  
  ListTitleBlock({
    this.scope,
    this.padding,
    this.margin,
    this.borderRadius,
    this.busy,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.iconScale,
    this.iconAlt,
    this.iconAltPadding,
    this.iconAltColor,
    this.iconAltScale,
    this.iconTrail,
    this.iconTrailColor,
    this.iconTrailScale,
    this.divisor,
    this.divisorColor,
    this.titleStyle,
    this.title,
    this.titleOverflow,
    this.titleColor,
    this.titleTrail,
    this.titleTrailColor,
    this.subtitle,
    this.subtitleOverflow,
    this.subtitleColor,
    this.subtitleTrail,
    this.subtitleTrailStyle,
    this.subtitleTrailColor,
    this.onTap,
    this.splashColor,
    this.splashHihglight,
    this.body,
    this.fillColor,
    this.decoration,
  });
  
  Widget _getMainIcons() {
    return Column(
      children: <Widget>[
        icon != null ? Padding(padding: iconPadding ?? EdgeInsets.zero, child: Icon(icon, size: 43.0 * (iconScale ?? 1.0), color: iconColor ?? scope.application.settings.colors.primary)) : Container(),
        iconAlt != null ? Padding(padding: iconAltPadding ?? EdgeInsets.zero, child: Icon(iconAlt, size: 43.0 * (iconAltScale ?? 1.0), color: iconAltColor ?? scope.application.settings.colors.primary)) : Container(),
      ],
    );
  }
  
  Widget _getBusyIcon(double scale, Color color) {
    return Container(
      child: SizedBox(
        child: Center(
          child: SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color ?? scope.application.settings.colors.primary),
            ),
            height: (43.0 * (scale ?? 1.0)) * 0.7,
            width: 43.0 * (scale ?? 1.0) * 0.7,
          ),
        ),
        height: (43.0 * (scale ?? 1.0)),
        width: 43.0 * (scale ?? 1.0),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        key: GlobalKey(),
        color: fillColor,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          splashColor: splashColor,
          highlightColor: splashHihglight,
          borderRadius: borderRadius,
          child: Container(
            decoration: decoration,
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                busy == true && icon != null ? _getBusyIcon(iconScale, iconColor) : _getMainIcons(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: icon != null ? 6 : 0, right: iconTrail != null ? 6 : 0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                title,
                                overflow: titleOverflow ?? TextOverflow.ellipsis,
                                style: titleStyle ??
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: titleColor ?? scope.application.settings.colors.primary,
                                    ),
                              ),
                            ),
                            titleTrail != null
                                ? Text(titleTrail,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: titleTrailColor ?? scope.application.settings.colors.primary,
                                ))
                                : Container(),
                          ],
                        ),
                        divisor == true
                            ? Container(
                          margin: EdgeInsets.only(top: 1, bottom: 1),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.5,
                                color: divisorColor ?? scope.application.settings.colors.separator,
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        (subtitle ?? subtitleTrail) != null
                            ? Row(
                          children: <Widget>[
                            subtitle != null
                                ? Expanded(
                              child: Text(subtitle,
                                  overflow: subtitleOverflow ?? TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: subtitleColor ?? scope.application.settings.colors.text,
                                  )),
                            )
                                : Container(),
                            subtitleTrail != null
                                ? Text(subtitleTrail,
                                textAlign: TextAlign.right,
                                style: subtitleTrailStyle ?? TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  color: subtitleTrailColor ?? scope.application.settings.colors.text,
                                ))
                                : Container(),
                          ],
                        )
                            : Container(),
                        body ?? Container()
                      ],
                    ),
                  ),
                ),
                iconTrail != null ? ((busy == true && icon == null) ? _getBusyIcon(iconTrailScale, iconTrailColor) : Icon(iconTrail, size: 43.0 * (iconTrailScale ?? 1.0), color: iconTrailColor ?? scope.application.settings.colors.primary)) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
