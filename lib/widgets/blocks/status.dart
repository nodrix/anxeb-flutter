import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class StatusBlock extends StatefulWidget {
  StatusBlock({
    this.margin,
    this.padding,
    this.title,
    this.caption,
    this.subcaption,
    this.action,
    this.captionAction,
    this.cancel,
    this.busy,
    this.enabled,
    this.icon,
    this.iconScale,
    this.iconColor,
    this.titleColor,
    this.captionColor,
    this.subcaptionColor,
    this.controller,
  }) : assert(title != null);

  final EdgeInsets margin;
  final EdgeInsets padding;
  final String title;
  final String caption;
  final String subcaption;
  final Future Function() action;
  final Future Function() cancel;
  final Function() captionAction;
  final bool busy;
  final bool enabled;
  final IconData icon;
  final double iconScale;
  final Color iconColor;
  final Color titleColor;
  final Color captionColor;
  final Color subcaptionColor;
  final StatusBlockController controller;

  @override
  _StatusBlockState createState() => _StatusBlockState();
}

class _StatusBlockState extends State<StatusBlock> {
  bool _busy = false;
  bool _enableAction = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          ClipOval(
            child: Material(
              key: GlobalKey(),
              color: widget.iconColor ?? Colors.green,
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
                  width: 42,
                  height: 42,
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
                                size: 30 * (widget.iconScale ?? 1.0),
                                color: Colors.white,
                              ),
                            )),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: new Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.4,
                color: widget.titleColor ?? Colors.green,
              ),
            ),
          ),
          widget.caption != null
              ? Expanded(
                  child: Container(
                    alignment: Alignment.topRight,
                    child: Material(
                      color: Colors.transparent,
                      key: GlobalKey(),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: InkWell(
                        borderRadius: new BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                        onTap: () {
                          widget.captionAction?.call();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _StatusCaption(
                                controller: widget.controller,
                                caption: widget.caption,
                                subcaption: widget.subcaption,
                                captionColor: widget.captionColor,
                                subcaptionColor: widget.subcaptionColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class _StatusCaption extends StatefulWidget {
  final StatusBlockController controller;
  final String caption;
  final String subcaption;
  final Color captionColor;
  final Color subcaptionColor;

  _StatusCaption({this.caption, this.subcaption, this.captionColor, this.subcaptionColor, this.controller});

  @override
  _StatusCaptionState createState() => _StatusCaptionState();
}

class _StatusCaptionState extends State<_StatusCaption> {
  @override
  void initState() {
    widget.controller?._onUpdate(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          widget?.controller?.caption ?? widget.caption,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: widget.captionColor ?? Colors.green,
          ),
        ),
        (widget?.controller?.subcaption ?? widget.subcaption) != null
            ? Text(
                widget?.controller?.subcaption ?? widget.subcaption,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                  color: widget.subcaptionColor ?? Colors.green,
                ),
              )
            : Container(),
      ],
    );
  }
}

class StatusBlockController {
  Function() _callback;
  String _caption;
  String _subcaption;

  void _onUpdate(Function() callback) {
    _callback = callback;
  }

  set caption(value) {
    _caption = value;
    _callback?.call();
  }

  set subcaption(value) {
    _subcaption = value;
    _callback?.call();
  }

  String get subcaption => _subcaption;

  String get caption => _caption;
}
