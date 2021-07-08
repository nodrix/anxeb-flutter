import 'dart:ui';
import 'package:url_launcher/url_launcher.dart' as Launcher;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PropertyBlock extends StatefulWidget {
  PropertyBlock({
    this.margin,
    this.padding,
    this.iconMargin,
    @required this.label,
    this.valueScale,
    this.labelScale,
    this.value,
    this.icon,
    this.visible,
    this.iconScale,
    this.iconColor,
    this.labelColor,
    this.valueColor,
    this.showOnNull,
    this.isPhone,
    this.isEmail,
    this.iconSize,
    this.onTap,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final EdgeInsets iconMargin;
  final String label;
  final double valueScale;
  final double labelScale;
  final String value;
  final IconData icon;
  final bool visible;
  final double iconScale;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;
  final bool showOnNull;
  final bool isPhone;
  final bool isEmail;
  final double iconSize;
  final GestureTapCallback onTap;

  @override
  _PropertyBlockState createState() => _PropertyBlockState();
}

class _PropertyBlockState extends State<PropertyBlock> {
  Widget _valueWidget;

  @override
  Widget build(BuildContext context) {
    if (widget.visible == false || ((widget.value == null || widget.value.length == 0) && widget.showOnNull != true)) {
      return Container();
    }

    _valueWidget = _valueWidget ?? _getValueWidget();

    final content = Container(
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          widget.icon != null
              ? Container(
                  margin: widget.iconMargin ?? EdgeInsets.only(right: 5),
                  child: ClipOval(
                    child: SizedBox(
                      width: 30 * (widget.iconScale ?? 1.0),
                      height: 30 * (widget.iconScale ?? 1.0),
                      child: Container(
                        color: widget.iconColor ?? Colors.blue,
                        child: Icon(
                          widget.icon,
                          size: widget.iconSize ?? (20 * (widget.iconScale ?? 1.0)),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11 * (widget.labelScale ?? 1.0),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: widget.labelColor ?? Color(0xff444444),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 3),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _valueWidget),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: widget.margin,
      child: content,
    );
  }

  Widget _getValueWidget() {
    if (widget.isPhone == true) {
      var phones = widget.value.replaceAll(' ', '').split(',');
      if (phones.length > 1) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: phones.map((phone) {
            return Padding(
              padding: EdgeInsets.only(bottom: phone == phones.last ? 0 : 8),
              child: GestureDetector(
                onTap: () => _launchValueLink(phone),
                child: _getValueTextWidget(phone),
              ),
            );
          }).toList(),
        );
      }
    }

    return Material(
      key: GlobalKey(),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          _launchValueLink(widget.value);
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.black12,
        borderRadius: BorderRadius.circular(20),
        child: _getValueTextWidget(widget.value),
      ),
    );
  }

  Widget _getValueTextWidget(String text) {
    return Text(
      text,
      overflow: TextOverflow.clip,
      style: TextStyle(
        height: 0.95,
        fontSize: 17.5 * (widget.valueScale ?? 1),
        decoration: widget.isEmail == true || widget.isPhone == true ? TextDecoration.underline : null,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.1,
        color: widget.valueColor ?? Colors.indigo,
      ),
    );
  }

  void _launchValueLink(String value) {
    if (widget.isPhone == true) {
      Launcher.canLaunch("tel://$value").then((canLaunch) {
        if (canLaunch == true) {
          Launcher.launch("tel://$value");
        }
      });
    } else if (widget.isEmail == true) {
      Launcher.canLaunch("mailto:$value").then((canLaunch) {
        if (canLaunch == true) {
          Launcher.launch("mailto:$value");
        }
      });
    } else if (widget.onTap != null) {
      widget.onTap();
    }
  }
}
