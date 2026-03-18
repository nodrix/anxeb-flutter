import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../anxeb.dart';

class IconButton extends StatefulWidget {
  final bool keyless;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Future Function() action;
  final Future Function() cancel;
  final bool busy;
  final bool enabled;
  final IconData icon;
  final double iconSize;
  final double scale;
  final EdgeInsets iconPadding;
  final double size;
  final Color borderColor;
  final Color fillColor;
  final Color innerColor;
  final Color innerBorderColor;
  final double borderWidth;
  final double borderPadding;
  final bool opaque;
  final double contextMenuItemHeight;
  final double contextMenuIconSize;
  final Offset contextMenuOffset;
  final TextStyle contextMenuTextStyle;
  final Future<List<ContextMenuItem>> Function() contextMenuItems;
  final Color contextMenuTextColor;
  final Widget tooltipContent;
  final String tooltipText;
  final AxisDirection tooltipDirection;
  final double tooltipElevation;
  final double tooltipTailBaseWidth;
  final Color tooltipFillColor;
  final Border tooltipBorderRadius;
  final double tooltipOffset;
  final double tooltipTailLength;
  final Duration tooltipFadeDuration;
  final Color splashColor;
  final Color hoverColor;
  final bool visible;
  final bool reloadContextMenuEachTap;

  IconButton({
    this.keyless,
    this.margin,
    this.padding,
    this.action,
    this.cancel,
    this.busy,
    this.enabled,
    this.icon,
    this.scale,
    this.iconSize,
    this.iconPadding,
    this.size,
    this.borderColor,
    this.fillColor,
    this.innerColor,
    this.innerBorderColor,
    this.borderWidth,
    this.borderPadding,
    this.opaque,
    this.contextMenuItemHeight,
    this.contextMenuIconSize,
    this.contextMenuOffset,
    this.contextMenuTextStyle,
    this.contextMenuItems,
    this.contextMenuTextColor,
    this.tooltipContent,
    this.tooltipText,
    this.tooltipDirection,
    this.tooltipElevation,
    this.tooltipTailBaseWidth,
    this.tooltipFillColor,
    this.tooltipBorderRadius,
    this.tooltipOffset,
    this.tooltipTailLength,
    this.tooltipFadeDuration,
    this.splashColor,
    this.hoverColor,
    this.visible,
    this.reloadContextMenuEachTap = true,
  });

  @override
  _IconButtonState createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  bool _busy = false;
  bool _enableAction = true;
  List<ContextMenuItem> _items;

  Future _retrieveContextItems() async {
    if (widget.contextMenuItems != null) {
      try {
        if (mounted) {
          setState(() {
            _busy = true;
          });
        }
        _items = await widget.contextMenuItems();
        setState(() {
          _busy = false;
        });
        await Future.delayed(Duration(milliseconds: 5));
        PopupMenuButtonState<Function> state = _menu.currentState;
        state.showButtonMenu();
      } catch (err) {
        //ignore
      } finally {
        setState(() {
          _busy = false;
        });
      }
    } else {
      _items = [];
    }
  }

  GlobalKey _menu = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.visible == false) {
      return Container();
    }

    var $fill = widget.fillColor ?? Colors.green;
    var $fore = widget.innerColor ?? Colors.white;
    PopupMenuButton<Function> contextMenu;

    if (widget.contextMenuItems != null) {
      contextMenu = PopupMenuButton<Function>(
        key: _menu,
        icon: Icon(
          widget.icon ?? Icons.more_vert,
          size: widget.iconSize ?? (30 * (widget.scale ?? 1.0)),
          color: $fore,
        ),
        offset: widget.contextMenuOffset ?? Offset(10, 50),
        tooltip: '',
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
        onSelected: (func) {
          func?.call();
        },
        padding: EdgeInsets.all(0),
        constraints: BoxConstraints(minWidth: 0),
        itemBuilder: (BuildContext context) {
          var result = <PopupMenuEntry<Function>>[];
          if ((_items == null && widget.contextMenuItems != null)) {
            if (_busy != true) {
              _retrieveContextItems();
            }
            return [];
          }

          for (var i = 0; i < _items.length; i++) {
            var item = _items[i];
            if (item.onTap == null || item.visible == false) {
              continue;
            }

            if (item.title != null) {
              result.add(
                PopupMenuItem<Function>(
                  height: 20,
                  enabled: false,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(item.title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xff333333))),
                          margin: EdgeInsets.only(bottom: 9, top: 6),
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 0.7, color: const Color(0xff333333)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (item.divided == true) {
              result.add(PopupMenuDivider());
            }

            result.add(PopupMenuItem<Function>(
              height: widget.contextMenuItemHeight ?? 35,
              onTap: () {
                if (item.enabled == false) {
                  return;
                }
                item.onTap?.call();
              },
              enabled: item.enabled != false,
              child: Opacity(
                opacity: item.enabled == false ? 0.6 : 1.0,
                child: Row(
                  children: [
                    Container(
                      child: Icon(item.icon, size: widget.contextMenuIconSize, color: item.iconColor ?? widget.contextMenuTextColor ?? const Color(0xff333333)),
                      width: 26,
                    ),
                    Container(
                      child: Text(item.label, style: widget.contextMenuTextStyle ?? TextStyle(color: item.textColor ?? widget.contextMenuTextColor ?? const Color(0xff333333))),
                      padding: EdgeInsets.only(left: 12),
                    ),
                  ],
                ),
              ),
            ));
          }
          if (widget.reloadContextMenuEachTap == true) {
            _items = null;
          }
          return result;
        },
      );
    }

    final iconBody = SizedBox(
      width: widget.size ?? 42,
      height: widget.size ?? 42,
      child: Container(
        padding: widget.iconPadding,
        child: widget.busy == true || _busy == true
            ? Container(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>($fore ?? Color(0xf0ffffff)),
                ),
              )
            : AnimatedOpacity(
                opacity: _enableAction == true ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: contextMenu ??
                    Icon(
                      widget.icon,
                      size: widget.iconSize ?? (30 * (widget.scale ?? 1.0)),
                      color: $fore,
                    ),
              ),
      ),
    );

    final body = ClipOval(
      child: Material(
        key: widget.keyless == true ? null : GlobalKey(),
        color: $fill,
        child: widget.enabled != false && (widget.action != null || contextMenu != null)
            ? InkWell(
                splashColor: widget.splashColor ?? Colors.white,
                hoverColor: widget.hoverColor,
                splashFactory: InkSplash.splashFactory,
                onTap: _enableAction == true
                    ? () async {
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
                          await widget.action?.call();
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
                      }
                    : () async {
                        if (widget.cancel != null) {
                          await widget.cancel();
                        }
                      },
                child: iconBody,
              )
            : Opacity(opacity: 0.6, child: iconBody),
      ),
    );

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: <Widget>[
          Container(
            padding: widget.borderPadding != null ? EdgeInsets.all(widget.borderPadding) : null,
            decoration: widget.borderWidth != null && widget.borderWidth > 0
                ? BoxDecoration(
                    color: widget.innerBorderColor,
                    borderRadius: BorderRadius.all(Radius.circular(45)),
                    border: Border.all(width: widget.borderWidth, color: widget.borderColor ?? widget.fillColor),
                  )
                : null,
            child: widget.tooltipContent != null || widget.tooltipText != null
                ? JustTheTooltip(
                    content: widget.tooltipContent ??
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(widget.tooltipText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                    preferredDirection: widget.tooltipDirection ?? AxisDirection.right,
                    elevation: widget.tooltipElevation ?? 4.0,
                    tailBaseWidth: widget.tooltipTailBaseWidth ?? 12,
                    tailLength: widget.tooltipTailLength ?? 8,
                    backgroundColor: widget.tooltipFillColor ?? Colors.blue,
                    borderRadius: widget.tooltipBorderRadius ?? BorderRadius.circular(6),
                    offset: widget.tooltipOffset ?? 12,
                    hoverShowDuration: Duration.zero,
                    fadeOutDuration: widget.tooltipFadeDuration ?? Duration(milliseconds: 500),
                    enableFeedback: false,
                    waitDuration: const Duration(milliseconds: 500),
                    child: Opacity(opacity: widget.opaque == true ? 0.6 : 1.0, child: body),
                  )
                : Opacity(opacity: widget.opaque == true ? 0.6 : 1.0, child: body),
          ),
        ],
      ),
    );
  }
}
