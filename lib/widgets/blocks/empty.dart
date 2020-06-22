import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'paragraph.dart';

class EmptyBlock extends StatelessWidget {
  const EmptyBlock(
    this.text,
    this.icon, {
    this.actionCallback,
    this.actionText,
    this.visible,
    this.iconSize,
    this.iconPadding,
    this.margin,
  }) : assert(text != null);

  final String text;
  final String actionText;
  final VoidCallback actionCallback;
  final bool visible;
  final IconData icon;
  final double iconSize;
  final EdgeInsets iconPadding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return visible != false
        ? Center(
            heightFactor: 2,
            child: Container(
              margin: margin ?? EdgeInsets.only(left: 30, right: 30, bottom: 30),
              padding: EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: iconPadding != null ? iconPadding : EdgeInsets.only(bottom: 5),
                    child: Icon(
                      icon,
                      size: iconSize != null ? iconSize : 160,
                      color: Color(0x332e7db2),
                    ),
                  ),
                  text != null && text.isNotEmpty
                      ? ParagraphBlock(
                          alignment: TextAlign.center,
                          content: <TextSpan>[
                            TextSpan(style: TextStyle(), text: text),
                          ],
                        )
                      : Container(),
                  actionText != null
                      ? GestureDetector(
                          onTap: actionCallback,
                          child: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: ParagraphBlock(
                              content: <TextSpan>[
                                TextSpan(
                                  text: actionText,
                                  style: TextStyle(
                                    color: Color(0xff0055ff),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          )
        : Container();
  }
}
