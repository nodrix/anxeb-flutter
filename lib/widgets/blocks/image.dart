import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/material.dart';

class ImageLinkBlock extends StatefulWidget {
  ImageLinkBlock({
    this.failedIcon,
    this.failedIconSize,
    this.failedIconColor,
    this.url,
    this.headers,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.loadingThickness,
    this.loadingColor,
    this.loadingPadding,
    this.progressSize,
    this.imageScale,
    this.shape,
    this.fit,
    this.shadow,
    GlobalKey key,
  }) : super(key: key);

  final IconData failedIcon;
  final double failedIconSize;
  final Color failedIconColor;
  final String url;
  final Map<String, String> headers;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double loadingThickness;
  final Color loadingColor;
  final EdgeInsets loadingPadding;
  final double progressSize;
  final double imageScale;
  final BoxShape shape;
  final BoxFit fit;
  final List<BoxShadow> shadow;

  @override
  _ImageLinkBlockState createState() => _ImageLinkBlockState();
}

class _ImageLinkBlockState extends State<ImageLinkBlock> {
  bool _imageLoaded;
  bool _busy;
  bool _displayImage;
  SecuredImage _netImage;

  @override
  void initState() {
    _setupImage(widget.url);
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
      widget.url,
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
            });
            if (mounted) {
              setState(() {});
            }
          }, onError: (exception, StackTrace stackTrace) {
            print(exception);
            //TODO, try again
            Future.delayed(Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _displayImage = true;
                });
              } else {
                _displayImage = true;
              }
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
    if (widget.url != null && (_netImage == null || _netImage.url != widget.url)) {
      _setupImage(widget.url);
    }

    var failedWidget = _imageLoaded == false
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _displayImage == true ? 1 : 0,
            child: Container(
              height: widget.height,
              width: widget.width,
              child: Icon(
                widget.failedIcon ?? Icons.broken_image,
                color: widget.failedIconColor ?? Colors.white.withAlpha(100),
                size: widget.failedIconSize ?? ((widget.height ?? widget.width ?? 1)),
              ),
            ),
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
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                shape: widget.shape ?? BoxShape.rectangle,
                image: _netImage != null
                    ? DecorationImage(
                        fit: widget.fit ?? BoxFit.cover,
                        alignment: Alignment.center,
                        image: _netImage,
                      )
                    : null,
              ),
            ),
          )
        : null;

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            decoration: BoxDecoration(
              boxShadow: widget.shadow,
              shape: widget.shape ?? BoxShape.rectangle,
            ),
            child: Container(
              height: widget.height,
              width: widget.width,
              child: imageWidget,
            ),
          ),
          failedWidget ?? Container(),
          loadingWidget ?? Container(),
        ],
      ),
    );
  }
}
