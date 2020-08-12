import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/blocks/paragraph.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    this.padding,
    this.margin,
    this.onTap,
    this.loadingThickness,
    this.loadingColor,
    this.loadingPadding,
    this.imageScale,
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
  });

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
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Future Function() onTap;
  final double loadingThickness;
  final Color loadingColor;
  final EdgeInsets loadingPadding;
  final double imageScale;
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
    _displayImage = false;

    _netImage = SecuredImage(
      widget.imageUrl,
      scale: widget.imageScale ?? 1,
      headers: widget.headers,
    );

    _netImage.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) {
            _imageLoaded = true;
            Future.delayed(Duration(milliseconds: 50), () {
              setState(() {
                _displayImage = true;
              });
            });
            if (mounted) {
              setState(() {});
            }
          }, onError: (exception, StackTrace stackTrace) {
            Future.delayed(Duration(milliseconds: 50), () {
              setState(() {
                _displayImage = true;
              });
            });
            _imageLoaded = false;
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
                height: widget.height,
                width: widget.width,
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
                height: widget.height,
                width: widget.width,
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
      key: GlobalKey(),
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap != null
            ? () async {
                if (widget.enabled != false) {
                  setState(() {
                    _busy = true;
                  });
                  await widget.onTap();
                  setState(() {
                    _busy = false;
                  });
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

    var loadingWidget = widget.loadingThickness != null && widget.loadingThickness > 0 && (_imageLoaded == null || _busy == true)
        ? Center(
            child: Container(
              height: widget.height,
              width: widget.width,
              padding: widget.loadingPadding ?? EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Container(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                    strokeWidth: widget.loadingThickness,
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
                                  colorFilter: widget.enabled != false ? null : ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.screen),
                                  fit: widget.fit ?? BoxFit.cover,
                                  alignment: Alignment.center,
                                  image: _netImage ?? widget.imageAsset,
                                )
                              : null,
                        ),
                      ),
                      widget.body ?? Container()
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Container(
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
                                  colorFilter: widget.enabled != false ? null : ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.screen),
                                  fit: widget.fit ?? BoxFit.cover,
                                  alignment: Alignment.center,
                                  image: _netImage ?? widget.imageAsset,
                                )
                              : null,
                        ),
                      ),
                      widget.body != null ? (widget.expanded == true ? Expanded(child: widget.body) : widget.body) : Container()
                    ],
                  ),
          )
        : null;

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Stack(
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
  }
}
