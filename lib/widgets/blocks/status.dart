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
    this.action,
    this.cancel,
    this.busy,
    this.enabled,
    this.icon,
    this.iconScale,
    this.iconColor,
    this.titleColor,
    this.captionColor,
  }) : assert(title != null);
  
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String title;
  final String caption;
  final Future Function() action;
  final Future Function() cancel;
  final bool busy;
  final bool enabled;
  final IconData icon;
  final double iconScale;
  final Color iconColor;
  final Color titleColor;
  final Color captionColor;
  
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
              color: widget.iconColor ?? Colors.green,
              child: InkWell(
                splashColor: Colors.white,
                onTap: _enableAction == true ? () async {
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
                } : () async {
                  if (widget.cancel != null) {
                    await widget.cancel();
                  }
                },
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Container(
                      child: _busy == true
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
            padding: EdgeInsets.only(left: 10),
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
              child: new Text(
                widget.caption,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                  color: widget.captionColor ?? Colors.green,
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
