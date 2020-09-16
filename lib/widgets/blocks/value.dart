import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ValueBlock extends StatefulWidget {
  final Scope scope;
  final EdgeInsets margin;
  final bool highlight;
  final GestureTapCallback onTap;
  final GestureTapCallback onPrefixTap;
  final ValueChanged<dynamic> onNewValue;
  final String title;
  final String units;
  final String caption;
  final bool visible;
  final String prefix;
  final double value;
  final bool discrete;
  final MessageDialog dialog;
  final Color valueColor;
  final Color titleColor;
  final Color borderColor;
  final Color backgroundColor;
  final Color separatorColor;
  final double decimalSize;
  final double integerSize;
  final String symbol;
  final double symbolOffset;
  final List<Widget> buttons;
  final double scale;
  final double titleSize;
  final Widget icon;

  ValueBlock({
    @required this.scope,
    this.margin,
    this.highlight,
    this.title,
    this.units,
    this.caption,
    this.visible,
    this.prefix,
    this.value,
    this.discrete,
    this.dialog,
    this.onNewValue,
    this.onTap,
    this.onPrefixTap,
    this.valueColor,
    this.titleColor,
    this.borderColor,
    this.backgroundColor,
    this.separatorColor,
    this.decimalSize,
    this.integerSize,
    this.symbol,
    this.symbolOffset,
    this.buttons,
    this.scale,
    this.titleSize,
    this.icon,
  });

  @override
  _ValueBlockState createState() => _ValueBlockState();
}

class _ValueBlockState extends State<ValueBlock> {
  @override
  initState() {
    super.initState();
  }

  String get _value {
    return Utils.convert.fromAnyToNumber(widget.value, decimals: widget.discrete == true ? 0 : 2);
  }

  String get _integers {
    var value = _value;
    var dotIndex = value.indexOf('.');
    if (dotIndex > -1) {
      return value.substring(0, dotIndex);
    }
    return value;
  }

  String get _decimals {
    var value = _value;
    var dotIndex = value.indexOf('.');
    if (dotIndex > -1) {
      return value.substring(dotIndex + 1);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.visible == false) {
      return Container();
    }

    var titleRow = widget.title != null
        ? Row(
            children: <Widget>[
              widget.prefix != null
                  ? GestureDetector(
                      onTap: widget.onPrefixTap,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(bottom: 2, right: widget.buttons != null ? 4 : 3),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 0.7, color: widget.separatorColor ?? widget.scope.application.settings.colors.separator)),
                        ),
                        child: Text(
                          widget.prefix.toUpperCase(),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.titleSize ?? 14,
                            fontWeight: FontWeight.w400,
                            color: widget.titleColor ?? widget.scope.application.settings.colors.primary,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(bottom: 2, right: widget.buttons != null ? 4 : 3),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.7, color: widget.separatorColor ?? widget.scope.application.settings.colors.separator)),
                  ),
                  child: Text(
                    widget.title.toUpperCase(),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.titleSize ?? 14,
                      fontWeight: FontWeight.w400,
                      color: widget.titleColor ?? widget.scope.application.settings.colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          )
        : null;
    var valueRow = Row(
      children: <Widget>[
        Expanded(
            child: widget.buttons != null
                ? Container(
                    child: Row(
                      children: widget.buttons,
                    ),
                  )
                : Container()),
        widget.symbol != null
            ? Container(
                alignment: Alignment.topCenter,
                height: (widget.integerSize ?? 37) * (widget.scale ?? 1),
                padding: EdgeInsets.only(right: 3, left: widget.buttons != null ? 2 : 0, top: widget.symbolOffset ?? 2),
                child: Text(
                  widget.symbol,
                  style: TextStyle(
                    fontSize: (widget.decimalSize ?? 20) * (widget.scale ?? 1),
                    letterSpacing: -0.9,
                    fontWeight: FontWeight.w400,
                    color: widget.valueColor ?? widget.scope.application.settings.colors.primary,
                  ),
                ),
              )
            : Container(),
        Text(
          _integers,
          style: TextStyle(
            fontSize: (widget.integerSize ?? 39) * (widget.scale ?? 1),
            letterSpacing: -0.9,
            fontWeight: FontWeight.w300,
            color: widget.valueColor ?? widget.scope.application.settings.colors.primary,
          ),
        ),
        Container(
          alignment: Alignment.topCenter,
          height: (widget.integerSize ?? 39) * (widget.scale ?? 1),
          padding: EdgeInsets.only(left: 2, right: widget.buttons != null ? 2 : 0),
          child: Text(
            _decimals,
            style: TextStyle(
              fontSize: (widget.decimalSize ?? 24) * (widget.scale ?? 1),
              letterSpacing: -0.9,
              fontWeight: FontWeight.w400,
              color: widget.valueColor ?? widget.scope.application.settings.colors.primary,
            ),
          ),
        ),
      ],
    );
    var content = titleRow != null
        ? Column(
            children: <Widget>[titleRow, valueRow],
          )
        : valueRow;

    var borderRadius = const BorderRadius.all(
      Radius.circular(12.0),
    );

    var container = Container(
      margin: widget.margin,
      padding: EdgeInsets.only(top: titleRow != null ? 5 : 0, left: 5, right: 5),
      decoration: BoxDecoration(
        color: widget.onTap == null ? widget.backgroundColor : null,
        gradient: widget.highlight == true
            ? LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Color(0x34ffffff),
                  
                  Color(0x00ffffff),
                ],
                stops: [0.0, 1.0],
              )
            : null,
        border: Border.all(color: widget.borderColor ?? widget.scope.application.settings.colors.separator),
        borderRadius: borderRadius,
      ),
      child: widget.icon != null
          ? Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: titleRow != null ? 5 : 0),
                  child: widget.icon,
                ),
                Expanded(
                  child: content,
                )
              ],
            )
          : content,
    );

    if (widget.onTap != null) {
      return Material(
        key: GlobalKey(),
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: borderRadius,
          child: container,
        ),
      );
    } else {
      return container;
    }
  }
}
