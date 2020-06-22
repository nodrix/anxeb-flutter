import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:flutter/material.dart';

enum ButtonType { Main, Secundary, Link }
enum ButtonSize { Normal, Small }

const Color _BASE_COLOR = Color(0xff2e7db2);
const Color _LINK_COLOR = Color(0xff0055ff);

const double _NORMAL_SIZE = 18.0;
const double _SMALL_SIZE = 16.0;

class TextButton extends StatefulWidget {
  const TextButton({
    this.padding,
    this.margin,
    this.caption,
    this.icon,
    this.color,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.iconSize,
    this.onPressed,
    this.type,
    this.size,
    this.enabled,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final String caption;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final double fontSize;
  final double iconSize;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool enabled;

  @override
  _TextButtonState createState() => _TextButtonState();

  static List<Widget> createOptions(BuildContext context, List<KeyValue> options, {String selectedValue, Settings settings}) {
    var $settings = settings ?? Settings();
    return options.map(($option) {
      return Container(
          alignment: Alignment.center,
          child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
              child: TextButton(
                caption: $option.key,
                textColor: selectedValue == $option.value ? $settings.colors.active : null,
                color: $option.value == '' ? $settings.colors.danger : (selectedValue == $option.value ? $settings.colors.primary : $settings.colors.primary),
                margin: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop($option.value);
                },
                type: ButtonType.Main,
                size: ButtonSize.Small,
              ),
            ),
          ]));
    }).toList();
  }

  static List<Widget> createList(BuildContext context, List<KeyValue<ResultCallback>> buttons, {Settings settings}) {
    var $settings = settings ?? Settings();
    return buttons.map(($button) {
      var button = TextButton(
        caption: $button.key,
        color: $settings.colors.primary,
        textColor: Colors.white,
        margin: EdgeInsets.zero,
        onPressed: () {
          var btnResult = $button.value();
          if (btnResult != null) {
            Navigator.of(context).pop(btnResult);
          }
        },
        type: ButtonType.Main,
        size: ButtonSize.Small,
      );

      var isLast = buttons.last.key == $button.key;

      return Expanded(
        child: Container(
          child: button,
          padding: EdgeInsets.only(right: isLast ? 0 : 10),
        ),
      );
    }).toList();
  }
}

class _TextButtonState extends State<TextButton> {
  @override
  Widget build(BuildContext context) {
    var padding = EdgeInsets.all(12);
    var fontSize = widget.fontSize ?? _NORMAL_SIZE;
    var borderRadius = 30.0;

    if (widget.size == ButtonSize.Small) {
      padding = EdgeInsets.all(5);
      fontSize = widget.fontSize ?? _SMALL_SIZE;
    }

    var textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.white, fontWeight: FontWeight.normal);
    var color = widget.color ?? _BASE_COLOR;
    var shape = new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(borderRadius));

    if (widget.type == ButtonType.Secundary) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.black, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.white.withOpacity(0.5);
    } else if (widget.type == ButtonType.Link) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? _LINK_COLOR, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.transparent;
      shape = new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(borderRadius));
      padding = EdgeInsets.all(0);
    }

    final button = FlatButton(
      shape: shape,
      child: Padding(
        padding: widget.padding != null ? widget.padding : EdgeInsets.only(left: 8, right: 8),
        child: widget.icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor != null ? widget.iconColor : Colors.white,
                      size: widget.iconSize != null ? widget.iconSize : 20,
                    ),
                  ),
                  new Text(
                    widget.caption,
                    style: textStyle,
                  ),
                ],
              )
            : new Text(
                widget.caption,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
      ),
      color: color,
      padding: padding,
      onPressed: widget.enabled != false ? widget.onPressed : () {},
    );

    return Container(
      padding: widget.margin != null ? widget.margin : EdgeInsets.zero,
      child: widget.enabled == false
          ? Opacity(
              child: button,
              opacity: 0.3,
            )
          : button,
    );
  }
}
