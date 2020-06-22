import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ParagraphBlock extends StatelessWidget {
  const ParagraphBlock({
    this.text,
    this.content,
    this.alignment,
    this.bold,
  });

  final String text;
  final List<TextSpan> content;
  final TextAlign alignment;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: alignment != null ? alignment : TextAlign.left,
      text: new TextSpan(
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
          color: Color(0xff444444),
        ),
        children: content != null
            ? content
            : <TextSpan>[
                TextSpan(text: text, style: bold == true ? TextStyle(fontWeight: FontWeight.w400) : null),
              ],
      ),
    );
  }
}
