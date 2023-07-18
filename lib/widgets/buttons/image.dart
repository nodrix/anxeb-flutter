import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/blocks/paragraph.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class ImageButton extends StatefulWidget {
  ImageButton({
    this.enabled,
    this.splashColor,
    this.splashHihglight,
    this.failedIcon,
    this.failedIconSize,
    this.failedIconColor,
    this.imageAsset,
    this.imageUrl,
    this.headers,
    this.width,
    this.height,
    this.outerHeight,
    this.padding,
    this.margin,
    this.onTap,
    this.onLoaded,
    this.loadingThickness,
    this.loadingColor,
    this.loadingPadding,
    this.progressSize,
    this.imageScale,
    this.imagePadding,
    this.shape,
    this.fit,
    this.shadow,
    this.label,
    this.body,
    this.failedBody,
    this.outerRadius,
    this.outerThickness,
    this.outerFill,
    this.outerBorderColor,
    this.innerThickness,
    this.innerPadding,
    this.innerRadius,
    this.innerBorderColor,
    this.autohide,
    this.horizontal,
    this.expanded,
    this.filter,
    this.tooltip,
    this.tooltipContent,
    this.tooltipDirection,
    this.tooltipOffset,
    this.tooltipFillColor,
    this.tooltipTextColor,
    this.replaceFailedWidget,
    GlobalKey key,
  }) : super(key: key);

  final bool enabled;
  final Color splashColor;
  final Color splashHihglight;
  final IconData failedIcon;
  final double failedIconSize;
  final Color failedIconColor;
  final ImageProvider imageAsset;
  final String imageUrl;
  final Map<String, String> headers;
  final double width;
  final double height;
  final double outerHeight;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Future Function() onTap;
  final Function(bool, [ImageInfo]) onLoaded;
  final double loadingThickness;
  final Color loadingColor;
  final EdgeInsets loadingPadding;
  final double progressSize;
  final double imageScale;
  final EdgeInsets imagePadding;
  final BoxShape shape;
  final BoxFit fit;
  final List<BoxShadow> shadow;
  final String label;
  final Widget body;
  final Widget failedBody;
  final bool autohide;
  final bool horizontal;
  final bool expanded;

  final double outerRadius;
  final double outerThickness;
  final Color outerFill;
  final Color outerBorderColor;

  final double innerThickness;
  final EdgeInsets innerPadding;
  final double innerRadius;
  final Color innerBorderColor;
  final ColorFilter filter;
  final String tooltip;
  final Color tooltipFillColor;
  final Color tooltipTextColor;
  final Widget tooltipContent;
  final AxisDirection tooltipDirection;
  final double tooltipOffset;
  final bool replaceFailedWidget;

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool _imageLoaded;
  bool _busy;
  bool _displayImage;
  SecuredImage _netImage;

  @override
  void initState() {
    if (widget.imageUrl != null) {
      _setupImage(widget.imageUrl);
    } else {
      if (widget.imageAsset != null) {
        _displayImage = true;
      }
      _imageLoaded = true;
    }
    super.initState();
  }

  void _setupImage(String image) {
    _imageLoaded = null;
    _displayImage = true;

    Future.delayed(Duration(milliseconds: 60), () {
      if (_imageLoaded == null) {
        if (mounted) {
          setState(() {
            _displayImage = false;
          });
        } else {
          _displayImage = false;
        }
      }
    });

    _netImage = SecuredImage(
      widget.imageUrl,
      scale: widget.imageScale ?? 1,
      headers: widget.headers,
    );

    _netImage.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) {
            _imageLoaded = true;
            Future.delayed(Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _displayImage = true;
                });
              } else {
                _displayImage = true;
              }
              widget.onLoaded?.call(_imageLoaded, image);
            });
            if (mounted) {
              setState(() {});
            }
          }, onError: (exception, StackTrace stackTrace) {
            //TODO, try again
            _imageLoaded = false;
            Future.delayed(Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _displayImage = true;
                });
              } else {
                _displayImage = true;
              }
              widget.onLoaded?.call(_imageLoaded);
            });
            if (mounted) {
              setState(() {});
            }
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl != null && (_netImage == null || _netImage.url != widget.imageUrl)) {
      _setupImage(widget.imageUrl);
    }

    if (widget.autohide == true && widget.body == null && _imageLoaded != true) {
      return Container();
    }

    var emptyWidget = widget.horizontal != true
        ? Column(
            children: <Widget>[
              Container(
                padding: widget.imagePadding,
                child: Container(
                  height: widget.height,
                  width: widget.width,
                ),
              ),
              Opacity(
                opacity: 0,
                child: widget.body ?? Container(),
              )
            ],
          )
        : Row(
            children: <Widget>[
              Container(
                padding: widget.imagePadding,
                child: Container(
                  height: widget.height,
                  width: widget.width,
                ),
              ),
              widget.body != null
                  ? (widget.expanded == true
                      ? Expanded(
                          child: Opacity(
                          opacity: 0,
                          child: widget.body ?? Container(),
                        ))
                      : Opacity(
                          opacity: 0,
                          child: widget.body ?? Container(),
                        ))
                  : Container()
            ],
          );

    var touchWidget = Material(
      key: widget.key,
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap != null
            ? () async {
                if (widget.enabled != false) {
                  if (mounted) {
                    setState(() {
                      _busy = true;
                    });
                  } else {
                    _busy = true;
                  }
                  await widget.onTap();
                  if (mounted) {
                    setState(() {
                      _busy = false;
                    });
                  } else {
                    _busy = false;
                  }
                }
              }
            : null,
        splashColor: widget.splashColor,
        highlightColor: widget.splashHihglight,
        borderRadius: widget.shape != BoxShape.rectangle ? BorderRadius.all(Radius.circular(widget.width ?? widget.height ?? 100)) : (widget.outerRadius != null ? BorderRadius.all(Radius.circular(widget.outerRadius)) : null),
        child: Container(
          padding: widget.innerPadding,
          decoration: BoxDecoration(
            shape: widget.shape ?? BoxShape.circle,
            borderRadius: widget.outerRadius != null ? BorderRadius.all(Radius.circular(widget.outerRadius)) : null,
          ),
          child: emptyWidget,
        ),
      ),
    );

    var failedWidget = _imageLoaded == false
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _displayImage == true ? 1 : 0,
            child: widget.failedBody == null
                ? Container(
                    height: widget.height,
                    width: widget.width,
                    child: Icon(
                      widget.failedIcon ?? Icons.broken_image,
                      color: widget.failedIconColor ?? Colors.white.withAlpha(100),
                      size: widget.failedIconSize ?? ((widget.height ?? widget.width ?? 1)),
                    ),
                  )
                : widget.failedBody,
          )
        : null;

    var loadingWidget = _imageLoaded == null || _busy == true
        ? Center(
            child: Container(
              height: widget.height,
              width: widget.width,
              padding: widget.loadingPadding ?? EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Container(
                height: widget.progressSize,
                width: widget.progressSize,
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                    strokeWidth: widget.loadingThickness ?? 2,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor ?? Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
          )
        : null;

    var imageWidget = _imageLoaded == true
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _displayImage == true ? 1 : 0,
            child: widget.horizontal != true
                ? Column(
                    children: <Widget>[
                      Container(
                        padding: widget.imagePadding,
                        child: Container(
                          height: widget.height,
                          width: widget.width,
                          decoration: BoxDecoration(
                            shape: widget.shape ?? BoxShape.circle,
                            borderRadius: widget.innerRadius != null
                                ? BorderRadius.all(Radius.circular(
                                    widget.innerRadius,
                                  ))
                                : null,
                            border: widget.innerThickness != null ? Border.all(width: widget.innerThickness, color: widget.innerBorderColor) : null,
                            image: widget.imageAsset != null || _netImage != null
                                ? DecorationImage(
                                    colorFilter: widget.filter ?? (widget.enabled != false ? null : ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.screen)),
                                    fit: widget.fit ?? BoxFit.cover,
                                    alignment: Alignment.center,
                                    image: _netImage ?? widget.imageAsset,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      widget.body ?? Container()
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Container(
                        padding: widget.imagePadding,
                        child: Container(
                          height: widget.height,
                          width: widget.width,
                          decoration: BoxDecoration(
                            shape: widget.shape ?? BoxShape.circle,
                            borderRadius: widget.innerRadius != null
                                ? BorderRadius.all(Radius.circular(
                                    widget.innerRadius,
                                  ))
                                : null,
                            border: widget.innerThickness != null ? Border.all(width: widget.innerThickness, color: widget.innerBorderColor) : null,
                            image: widget.imageAsset != null || _netImage != null
                                ? DecorationImage(
                                    colorFilter: widget.filter ?? (widget.enabled != false ? null : ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.screen)),
                                    fit: widget.fit ?? BoxFit.cover,
                                    alignment: Alignment.center,
                                    image: _netImage ?? widget.imageAsset,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      widget.body != null ? (widget.expanded == true ? Expanded(child: widget.body) : widget.body) : Container()
                    ],
                  ),
          )
        : null;

    var button = Container(
      padding: widget.padding,
      margin: widget.margin,
      height: widget.outerHeight,
      child: failedWidget != null && widget.replaceFailedWidget == true ? failedWidget : Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  boxShadow: widget.shadow,
                  shape: widget.shape ?? BoxShape.circle,
                  borderRadius: widget.outerRadius != null
                      ? BorderRadius.all(Radius.circular(
                          widget.outerRadius,
                        ))
                      : null,
                  border: widget.outerThickness != null ? Border.all(width: widget.outerThickness, color: widget.outerBorderColor) : null,
                  color: widget.outerFill,
                ),
                child: Container(
                  padding: widget.innerPadding,
                  child: imageWidget ?? emptyWidget,
                ),
              ),
              widget.label == null
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(top: 6),
                      child: ParagraphBlock(
                        text: widget.label,
                        bold: widget.enabled == true,
                      ),
                    ),
            ],
          ),
          failedWidget ?? Container(),
          touchWidget,
          loadingWidget ?? Container(),
        ],
      ),
    );

    if (widget.tooltip != null || widget.tooltipContent != null) {
      return JustTheTooltip(
        content: Container(
          padding: EdgeInsets.all(6),
          child: widget.tooltipContent ??
              Text(
                widget.tooltip,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: widget.tooltipTextColor),
              ),
        ),
        preferredDirection: widget.tooltipDirection ?? AxisDirection.up,
        elevation: 4.0,
        tailBaseWidth: 12,
        tailLength: 8,
        backgroundColor: widget.tooltipFillColor,
        borderRadius: BorderRadius.circular(6),
        offset: widget.tooltipOffset ?? 12.0,
        hoverShowDuration: Duration.zero,
        fadeOutDuration: Duration(milliseconds: 500),
        enableFeedback: false,
        child: button,
      );
    }

    return button;
  }
}
