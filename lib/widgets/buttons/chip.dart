import 'package:flutter/material.dart';

const Color _BASE_COLOR = Color(0xff2e7db2);

class ChipButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color fillColor;
  final Color textColor;
  final bool disabled;
  final EdgeInsets margin;
  final IconData icon;

  final borderRadius = const BorderRadius.all(
    Radius.circular(12.0),
  );

  const ChipButton({
    this.text,
    this.onPressed,
    this.fillColor,
    this.textColor,
    this.disabled,
    this.margin,
    this.icon,
  });

  @override
  _ChipButtonState createState() => _ChipButtonState();
}

class _ChipButtonState extends State<ChipButton> {
  @override
  Widget build(BuildContext context) {
    var body = Container(
      padding: EdgeInsets.only(left: widget.icon != null ? 8 : 10, right: 10, top: 2, bottom: 2),
      child: Row(
        children: [
          widget.icon != null
              ? Container(
                  child: Icon(widget.icon, color: widget.textColor ?? Colors.white, size: 13),
                  padding: EdgeInsets.only(right: 4),
                )
              : Container(),
          Text(
            widget.text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: widget.textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );

    if (widget.disabled == true) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: (widget.fillColor ?? _BASE_COLOR).withOpacity(0.5),
          borderRadius: widget.borderRadius,
        ),
        child: body,
      );
    }

    return Container(
      margin: widget.margin,
      child: Material(
        key: GlobalKey(),
        color: widget.fillColor ?? _BASE_COLOR,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: widget.onPressed ?? () {},
          enableFeedback: widget.disabled != true,
          borderRadius: widget.borderRadius,
          child: body,
        ),
      ),
    );
  }
}
