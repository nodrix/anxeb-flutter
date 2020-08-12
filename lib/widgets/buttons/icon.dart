import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class IconButton extends StatefulWidget {
  IconButton({
    this.margin,
    this.padding,
    this.action,
    this.cancel,
    this.busy,
    this.enabled,
    this.icon,
    this.scale,
    this.size,
    this.borderColor,
    this.fillColor,
    this.innerColor,
    this.borderWidth,
    this.borderPadding,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final Future Function() action;
  final Future Function() cancel;
  final bool busy;
  final bool enabled;
  final IconData icon;
  final double scale;
  final double size;
  final Color borderColor;
  final Color fillColor;
  final Color innerColor;
  final double borderWidth;
  final double borderPadding;

  @override
  _IconButtonState createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  bool _busy = false;
  bool _enableAction = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(widget.borderPadding),
            decoration: widget.borderWidth != null && widget.borderWidth > 0
                ? BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(45)),
                    border: Border.all(width: widget.borderWidth, color: widget.borderColor ?? widget.fillColor),
                  )
                : null,
            child: ClipOval(
              child: Material(
                key: GlobalKey(),
                color: widget.fillColor ?? Colors.green,
                child: InkWell(
                  splashColor: Colors.white,
                  onTap: _enableAction == true
                      ? () async {
                          if (mounted) {
                            setState(() {
                              _busy = true;
                              _enableAction = false;
                            });
                          } else {
                            _busy = true;
                            _enableAction = false;
                          }
                          try {
                            await widget.action();
                          } finally {
                            if (mounted) {
                              setState(() {
                                _busy = false;
                              });

                              Future.delayed(Duration(milliseconds: 50), () {
                                if (mounted) {
                                  setState(() {
                                    _enableAction = true;
                                  });
                                } else {
                                  _enableAction = true;
                                }
                              });
                            } else {
                              _busy = false;
                              _enableAction = true;
                            }
                          }
                        }
                      : () async {
                          if (widget.cancel != null) {
                            await widget.cancel();
                          }
                        },
                  child: SizedBox(
                    width: widget.size ?? 42,
                    height: widget.size ?? 42,
                    child: Container(
                        child: widget.busy == true || _busy == true
                            ? Container(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xf0ffffff)),
                                ),
                              )
                            : AnimatedOpacity(
                                opacity: _enableAction == true ? 1 : 0,
                                duration: Duration(milliseconds: 300),
                                child: Icon(
                                  widget.icon,
                                  size: 30 * (widget.scale ?? 1.0),
                                  color: widget.innerColor ?? Colors.white,
                                ),
                              )),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
