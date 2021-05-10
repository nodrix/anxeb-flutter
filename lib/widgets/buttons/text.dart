import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart';

enum ButtonType { primary, secundary, link, frame }
enum ButtonSize { normal, small, medium, chip }

const Color _BASE_COLOR = Color(0xff2e7db2);
const Color _LINK_COLOR = Color(0xff0055ff);

const double _NORMAL_SIZE = 18.0;
const double _SMALL_SIZE = 16.0;
const double _CHIP_SIZE = 14.0;
const double _MEDIUM_SIZE = 18.0;

class TextButton extends StatefulWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String caption;
  final String subtitle;
  final IconData icon;
  final bool swapIcon;
  final List<BoxShadow> shadow;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final double fontSize;
  final double radius;
  final double iconSize;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool enabled;
  final BorderRadius borderRadius;

  const TextButton({
    this.padding,
    this.margin,
    this.caption,
    this.subtitle,
    this.icon,
    this.swapIcon,
    this.shadow,
    this.color,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.radius,
    this.iconSize,
    this.onPressed,
    this.type,
    this.size,
    this.enabled,
    this.borderRadius,
  });

  @override
  _TextButtonState createState() => _TextButtonState();

  static List<Widget> createOptions<V>(BuildContext context, List<DialogButton<V>> options, {V selectedValue, Settings settings}) {
    var $settings = settings ?? Settings();
    return options.where(($option) => $option.visible != false).map(($option) {
      return Container(
          alignment: Alignment.center,
          child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
              child: TextButton(
                caption: $option.caption,
                radius: settings.dialogs.buttonRadius,
                textColor: $option.textColor ?? (selectedValue == $option.value ? $settings.colors.active : null),
                color: $option.fillColor ?? ($option.value == '*' ? $settings.colors.asterisk : ($option.value == '' ? $settings.colors.danger : (selectedValue == $option.value ? $settings.colors.secudary : $settings.colors.primary))),
                icon: $option.icon,
                swapIcon: $option.swapIcon,
                margin: EdgeInsets.symmetric(vertical: 5),
                onPressed: () {
                  if ($option.onTap != null) {
                    var tabResult = $option.onTap(context);
                    if (tabResult != null) {
                      Navigator.of(context).pop(tabResult);
                    }
                  } else {
                    Navigator.of(context).pop($option.value);
                  }
                },
                type: ButtonType.primary,
                size: ButtonSize.small,
              ),
            ),
          ]));
    }).toList();
  }

  static List<Widget> createList(BuildContext context, List<DialogButton> buttons, {Settings settings}) {
    var $settings = settings ?? Settings();
    return buttons.where(($button) => $button.visible != false).map(($button) {
      var button = TextButton(
        caption: $button.caption,
        radius: settings.dialogs.buttonRadius,
        icon: $button.icon,
        swapIcon: $button.swapIcon,
        color: $button.fillColor ?? $settings.colors.primary,
        textColor: $button.textColor ?? Colors.white,
        margin: EdgeInsets.only(top: 10, left: buttons.first == $button ? 0 : 4, right: buttons.last == $button ? 0 : 4),
        onPressed: () {
          if ($button.onTap != null) {
            var tabResult = $button.onTap(context);
            if (tabResult != null) {
              Navigator.of(context).pop(tabResult);
            }
          } else {
            Navigator.of(context).pop($button.value);
          }
        },
        type: ButtonType.primary,
        size: ButtonSize.small,
      );

      var isLast = buttons.last.value == $button.value;

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
    var $borderRadius = widget.borderRadius ?? BorderRadius.circular(widget.radius ?? 30.0);

    if (widget.size == ButtonSize.chip) {
      $padding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      fontSize = widget.fontSize ?? _CHIP_SIZE;
    }

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
    var $shape;

    if (widget.type == ButtonType.secundary) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.black, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.white.withOpacity(0.5);
    } else if (widget.type == ButtonType.link) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? _LINK_COLOR, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.transparent;
      $padding = EdgeInsets.all(5);
    } else if (widget.type == ButtonType.frame) {
      textStyle = TextStyle(fontSize: fontSize, color: widget.textColor ?? Colors.black, fontWeight: FontWeight.normal);
      color = widget.color ?? Colors.transparent;
      $shape = RoundedRectangleBorder(
        borderRadius: $borderRadius,
        side: BorderSide(color: widget.textColor ?? Colors.black, width: 1.5),
      );
    }

    final button = Material(
      key: GlobalKey(),
      color: color,
      shape: $shape,
      borderRadius: $shape == null ? $borderRadius : null,
      child: InkWell(
        onTap: widget.enabled != false ? widget.onPressed : () {},
        borderRadius: $borderRadius,
        child: Padding(
            padding: widget.padding ?? $padding ?? EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: <Widget>[
                widget.icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: widget.swapIcon == true
                            ? <Widget>[
                                Text(
                                  widget.caption,
                                  style: textStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Icon(
                                    widget.icon,
                                    color: widget.iconColor != null ? widget.iconColor : Colors.white,
                                    size: widget.iconSize != null ? widget.iconSize : 20,
                                  ),
                                ),
                              ]
                            : <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    widget.icon,
                                    color: widget.iconColor != null ? widget.iconColor : Colors.white,
                                    size: widget.iconSize != null ? widget.iconSize : 20,
                                  ),
                                ),
                                Flexible(child: Text(
                                  widget.caption,
                                  style: textStyle,
                                )),
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
        boxShadow: widget.type == ButtonType.frame ? null : widget.shadow,
        borderRadius: $borderRadius,
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
