import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Color _DEFAULT_HEADER_COLOR = Color(0xff195279);
const Color _DEFAULT_SUBTITLE_COLOR = Color(0xff444444);

class HeaderBlock extends StatelessWidget {
  const HeaderBlock({
    this.icon,
    this.iconColor,
    this.iconSize,
    this.title,
    this.padding,
    this.subtitle,
    this.titleAlign,
    this.bodyAlign,
    this.body,
  });

  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String title;
  final EdgeInsets padding;
  final String subtitle;
  final TextAlign titleAlign;
  final TextAlign bodyAlign;
  final List<TextSpan> body;

  @override
  Widget build(BuildContext context) {
    var rh = MediaQuery.of(context).size.height;

    return Container(
      padding: padding != null ? padding : EdgeInsets.only(bottom: rh * 0.04),
      child: Column(
        children: <Widget>[
          icon != null
              ? Padding(
                  padding: EdgeInsets.only(bottom: rh * 0.003),
                  child: Icon(
                    icon,
                    color: iconColor != null ? iconColor : _DEFAULT_HEADER_COLOR,
                    size: iconSize != null ? iconSize : rh * 0.16,
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(bottom: rh * 0.008),
            child: title != null
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          textAlign: titleAlign != null ? titleAlign : TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w400,
                            color: _DEFAULT_HEADER_COLOR,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
          subtitle != null
              ? Text(
                  subtitle,
                  textAlign: bodyAlign != null ? bodyAlign : TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.3,
                    color: _DEFAULT_SUBTITLE_COLOR,
                  ),
                )
              : Container(),
          body != null
              ? RichText(
                  textAlign: bodyAlign != null ? bodyAlign : TextAlign.justify,
                  text: new TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.3,
                      color: _DEFAULT_SUBTITLE_COLOR,
                    ),
                    children: body,
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
