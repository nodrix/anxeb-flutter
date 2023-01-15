import 'package:flutter/material.dart';

class LinkButton extends StatefulWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final TextAlign textAlign;
  final TextStyle style;

  const LinkButton({
    this.margin,
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.onPressed,
    this.textAlign,
    this.style,
  });

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        child: GestureDetector(
          onTap: () async {
            widget.onPressed?.call();
          },
          child: Text(
            widget.text,
            textAlign: widget.textAlign,
            style: widget.style ?? TextStyle(color: widget.color ?? Colors.blue, fontSize: widget.fontSize ?? 17, fontWeight: widget.fontWeight ?? FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
