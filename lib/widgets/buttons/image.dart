import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/blocks/paragraph.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageButton extends StatefulWidget {
  ImageButton({
    this.width,
    this.url,
    this.headers,
    this.imageAsset,
    this.onTap,
    this.aspectRatio,
    this.color,
    this.padding,
    this.label,
    this.selected,
    this.scale,
  }) : assert(width != null);

  final GestureTapCallback onTap;
  final String url;
  final Map<String, String> headers;
  final String imageAsset;
  final double aspectRatio;
  final Color color;
  final double width;
  final EdgeInsets padding;
  final String label;
  final bool selected;
  final double scale;

  @override
  _ImageButtonState createState() => _ImageButtonState();
}


class _ImageButtonState extends State<ImageButton> {
  bool _imageLoaded;
  SecuredImage _netImage;

  @override
  void initState() {
    if (widget.imageAsset == null && widget.url != null) {
      _netImage = SecuredImage(
        widget.url,
        scale: widget.scale ?? 1,
        headers: widget.headers,
      );
      
      _netImage.resolve(ImageConfiguration()).addListener(
            ImageStreamListener((ImageInfo image, bool synchronousCall) {
              _imageLoaded = true;
              if (mounted) {
                setState(() {});
              }
            }, onError: (exception, StackTrace stackTrace) {
              print(exception);
              _imageLoaded = false;
              if (mounted) {
                setState(() {});
              }
            }),
          );
    } else {
      _imageLoaded = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new InkResponse(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        padding: widget.padding,
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.all(_imageLoaded == false ? 0 : 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: widget.selected == true ? Border.all(width: 2, color: widget.color ?? Colors.black.withOpacity(0.8)) : null,
                ),
                child: _imageLoaded == false
                    ? Container(
                        child: Icon(FontAwesome5Solid.user_circle, color: Colors.white.withAlpha(100), size: widget.width * 0.8),
                      )
                    : (_imageLoaded == null
                        ? Container(
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                colorFilter: widget.selected == true ? null : ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.screen),
                                fit: BoxFit.cover,
                                alignment: Alignment.topRight,
                                image: widget.imageAsset != null ? AssetImage(widget.imageAsset) : _netImage,
                              ),
                            ),
                          )),
              ),
            ),
            widget.label == null
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 6),
                    child: ParagraphBlock(
                      text: widget.label,
                      bold: widget.selected,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
