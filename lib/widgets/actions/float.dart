import 'package:flutter/material.dart';

class FloatAction extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final bool disabled;
  final List<AltAction> alternates;
  final double separation;
  final double topOffset;
  final double bottomOffset;
  final bool mini;

  FloatAction({
    this.color,
    this.icon,
    this.onPressed,
    this.disabled,
    this.alternates,
    this.separation,
    this.topOffset,
    this.bottomOffset,
    this.mini,
  });

  @override
  _FloatActionState createState() => _FloatActionState();
}

class _FloatActionState extends State<FloatAction> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var $separation = widget.separation ?? 60;
    var $bottom = widget.bottomOffset ?? 0;
    var $offset = (widget.topOffset ?? 15) + $bottom;

    List<Widget> $actions = [];
    if (widget.alternates != null) {
      for (var i = 0; i < widget.alternates.length; i++) {
        var $action = widget.alternates[i];
        var $disabled = $action.isDisabled?.call() == true;
        var $visible = $action.isVisible?.call() != false;
        var $icon = $action.icon?.call() ?? Icons.keyboard_arrow_left;
        var $color = $action.color?.call() ?? Colors.blue;
        var $sepOffset = $separation * (i + 1);

        if ($visible) {
          $actions.add(Positioned(
            bottom: $sepOffset + $offset,
            child: Opacity(
              opacity: $disabled == true ? 0.6 : 1,
              child: FloatingActionButton(
                heroTag: i,
                mini: $action.isMini != null ? $action.isMini() : true,
                onPressed: $disabled == true ? null : $action.onPressed,
                backgroundColor: $color,
                child: Icon($icon),
              ),
            ),
          ));
        }
      }
    }

    double $padding = widget.alternates != null ? (widget.alternates.length * (widget.separation ?? 60.0)) + ($offset - 5) : 0.0;

    $actions.insert(
      0,
      Container(
        padding: EdgeInsets.only(top: $padding, bottom: $bottom),
        child: Opacity(
          opacity: widget.disabled == true ? 0.6 : 1,
          child: FloatingActionButton(
            heroTag: this,
            mini: widget.mini != null ? widget.mini : false,
            onPressed: widget.disabled == true ? null : widget.onPressed,
            backgroundColor: widget.color,
            child: Icon(widget.icon),
          ),
        ),
      ),
    );

    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.center,
      children: $actions,
    );
  }
}

class AltAction {
  final IconData Function() icon;
  final VoidCallback onPressed;
  final Color Function() color;
  final bool Function() isDisabled;
  final bool Function() isVisible;
  final bool Function() isMini;

  AltAction({
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.isMini,
  });
}
