import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../middleware/application.dart';

class SwitchButton extends StatelessWidget {
  final Anxeb.Scope scope;
  final Widget text;
  final EdgeInsets margin;
  final Function(bool value) onToggle;
  final bool value;
  final IconData icon;
  final List<BoxShadow> shadows;
  final TextStyle style;
  final bool readonly;
  final EdgeInsets padding;
  final double height;
  final Color color;
  final BorderRadius borderRadius;

  const SwitchButton({
    Key key,
    @required this.scope,
    @required this.onToggle,
    @required this.text,
    this.value,
    this.margin,
    this.icon,
    this.shadows,
    this.style,
    this.readonly,
    this.padding,
    this.height,
    this.color,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        boxShadow: shadows,
      ),
      child: Material(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        child: InkWell(
          onTap: readonly == true ? null : () async {},
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
          child: Container(
            padding: padding ?? const EdgeInsets.only(left: 12, right: 12),
            height: height ?? 48,
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: application.settings.colors.primary,
                    size: 22,
                  ),
                const SizedBox(width: 8),
                Expanded(child: text),
                CupertinoSwitch(
                  value: value == true || value == null,
                  onChanged: (value) {
                    if (readonly != true) {
                      onToggle(value);
                    }
                  },
                  activeColor: application.settings.colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Application get application => scope.application;
}
