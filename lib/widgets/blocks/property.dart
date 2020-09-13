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

  @override
  _PropertyBlockState createState() => _PropertyBlockState();
}

class _PropertyBlockState extends State<PropertyBlock> {
  @override
  Widget build(BuildContext context) {
    if (widget.visible == false || (widget.value == null && widget.showOnNull != true)) {
      return Container();
    }

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          widget.icon != null
              ? Container(
                  margin: widget.iconMargin ?? EdgeInsets.only(right: 5),
                  child: ClipOval(
                    child: SizedBox(
                      width: 30* (widget.iconScale ?? 1.0),
                      height: 30* (widget.iconScale ?? 1.0),
                      child: Container(
                        color: widget.iconColor ?? Colors.blue,
                        child: Icon(
                          widget.icon,
                          size: 20 * (widget.iconScale ?? 1.0),
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
                        Expanded(
                          child: Text(
                            widget.value,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              height: 0.95,
                              fontSize: 17.5 * (widget.valueScale ?? 1),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.1,
                              color: widget.valueColor ?? Colors.indigo,
                            ),
                          ),
                        ),
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
  }
}
