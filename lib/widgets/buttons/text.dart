import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/misc/common.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:flutter/material.dart';

enum ButtonType { primary, secundary, link }
enum ButtonSize { normal, small, medium }

const Color _BASE_COLOR = Color(0xff2e7db2);
const Color _LINK_COLOR = Color(0xff0055ff);

const double _NORMAL_SIZE = 18.0;
const double _SMALL_SIZE = 16.0;
const double _MEDIUM_SIZE = 18.0;

class TextButton extends StatefulWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String caption;
  final String subtitle;
  final IconData icon;
  final List<BoxShadow> shadow;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final double fontSize;
  final double iconSize;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool enabled;

  const TextButton({
    this.padding,
    this.margin,
    this.caption,
    this.subtitle,
    this.icon,
    this.shadow,
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
                margin: EdgeInsets.symmetric(vertical: 5),
                onPressed: () {
                  Navigator.of(context).pop($option.value);
                },
                type: ButtonType.primary,
                size: ButtonSize.small,
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
        margin: EdgeInsets.only(top: 10),
        onPressed: () {
          var btnResult = $button.value();
          if (btnResult != null) {
            Navigator.of(context).pop(btnResult);
          }
        },
        type: ButtonType.primary,
        size: ButtonSize.small,
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
    var $padding = EdgeInsets.all(12);
    var fontSize = widget.fontSize ?? _NORMAL_SIZE;
    var borderRadius = 30.0;

    if (widget.size == ButtonSize.small) {
      $padding = EdgeInsets.all(8);
      fontSize = widget.fontSize ?? _SMALL_SIZE;
    }

    if (widget.size == ButtonSize.medium) {
      $padding = EdgeInsets.all(10);
      fontSize = widget.fontSize ?? _MEDIUM_SIZE;
    }

    var textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.white, fontWeight: FontWeight.normal);
    var subtitleStyle = TextStyle(fontSize: fontSize - 5, color: (widget.textColor ?? Colors.white).withOpacity(0.9), fontWeight: FontWeight.w300);
    var color = widget.color ?? _BASE_COLOR;

    if (widget.type == ButtonType.secundary) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.black, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.white.withOpacity(0.5);
    } else if (widget.type == ButtonType.link) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? _LINK_COLOR, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.transparent;
      $padding = EdgeInsets.all(5);
    }

    final button = Material(
      key: GlobalKey(),
      color: color,
      borderRadius: new BorderRadius.all(
        Radius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: widget.enabled != false ? widget.onPressed : () {},
        borderRadius: new BorderRadius.all(
          Radius.circular(borderRadius),
        ),
        child: Padding(
            padding: $padding ?? EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: <Widget>[
                widget.icon != null
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
                          Text(
                            widget.caption,
                            style: textStyle,
                          ),
                        ],
                      )
                    : Text(
                        widget.caption,
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                widget.subtitle != null
                    ? Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Text(
                          widget.subtitle.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: subtitleStyle,
                        ),
                      )
                    : Container()
              ],
            )),
      ),
    );

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        boxShadow: widget.shadow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: widget.enabled == false
          ? Opacity(
              child: button,
              opacity: 0.3,
            )
          : button,
    );
  }
}
