import 'package:anxeb_flutter/middleware/api.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class PhotoBlock extends StatefulWidget {
  final Anxeb.Scope scope;
  final String url;
  final int tick;
  final Api api;
  final double width;
  final double height;
  final int quality;
  final ColorFilter filter;
  final BorderRadius border;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color fill;
  final BoxFit fit;
  final Alignment alignment;
  final Icon failIcon;
  final Function(bool isFailed) onTap;
  final Widget failWidget;
  final Widget absoluteFailWidget;
  final Color progressColor;
  final double progressSize;
  final bool ignoreFailIcon;

  PhotoBlock({
    @required this.scope,
    @required this.url,
    this.tick,
    this.api,
    this.width,
    this.height,
    this.quality,
    this.filter,
    this.border,
    this.padding,
    this.margin,
    this.fill,
    this.fit,
    this.alignment,
    this.failIcon,
    this.onTap,
    this.failWidget,
    this.absoluteFailWidget,
    this.progressColor,
    this.progressSize,
    this.ignoreFailIcon,
  });

  @override
  _PhotoBlockState createState() => _PhotoBlockState();
}

class _PhotoBlockState extends State<PhotoBlock> {
  Anxeb.SecuredImage _netImage;
  bool _imageLoaded;
  ImageStream _stream;
  ImageStreamListener _listener;

  @override
  void initState() {
    _setupImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setupImage();
    var isError = _imageLoaded == false;
    var isLoaded = _imageLoaded == true;
    var isLoading = _imageLoaded == null;

    if (isError == true && widget.absoluteFailWidget != null) {
      return widget.absoluteFailWidget;
    }

    var decoration;
    if (_imageLoaded == true) {
      decoration = BoxDecoration(
        borderRadius: widget.border,
        color: widget.fill,
        image: DecorationImage(
          colorFilter: widget.filter,
          fit: widget.fit ?? BoxFit.contain,
          alignment: widget.alignment ?? Alignment.center,
          image: _netImage,
        ),
      );
    }

    var stack = Stack(
      children: <Widget>[
        AnimatedOpacity(
          opacity: isLoaded ? 1.0 : 0,
          duration: Duration(milliseconds: 300),
          child: Container(
            padding: widget.padding ?? EdgeInsets.zero,
            margin: widget.margin ?? EdgeInsets.zero,
            child: Container(
              decoration: decoration,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0,
          duration: Duration(milliseconds: 300),
          child: Center(
            child: Container(
              width: widget.progressSize ?? 48,
              height: widget.progressSize ?? 48,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor ?? widget.scope.application.settings.colors.primary),
              ),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: isError ? 1.0 : 0,
          duration: Duration(milliseconds: 300),
          child: widget.failWidget ??
              (widget.ignoreFailIcon == true
                  ? Container()
                  : Container(
                      alignment: Alignment.center,
                      child: widget.failIcon ??
                          Icon(
                            Anxeb.FlutterIcons.broken_image_mdi,
                            color: Colors.black12,
                            size: 90,
                          ),
                    )),
        ),
        widget.onTap != null
            ? Material(
                key: GlobalKey(),
                color: Colors.transparent,
                borderRadius: widget.border,
                child: InkWell(
                  onTap: () {
                    widget.onTap(_imageLoaded == false);
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.black12,
                  borderRadius: widget.border,
                ),
              )
            : Container(),
      ],
    );

    if (widget.height != null) {
      return Container(
        height: widget.height,
        child: stack,
      );
    }

    return stack;
  }

  void _setLoadedState(value) {
    if (mounted) {
      setState(() {
        _imageLoaded = value;
      });
    } else {
      _imageLoaded = value;
    }
  }

  void _setupImage() async {
    var $api = widget.api ?? widget.scope.application.api;

    _setLoadedState(null);

    String $url;
    if (widget.url != null && widget.url.startsWith('http')) {
      $url = widget.url;
    } else {
      $url = $api.getUri(widget.url);
    }
    $url = $url + ($url.contains('?') ? '&' : '?') + 'webp=${widget.quality ?? '60'}&width=${widget.width ?? '300'}&tick=${widget.tick ?? '1'}';
    if (_stream != null && _listener != null) {
      _stream.removeListener(_listener);
    }

    _netImage = Anxeb.SecuredImage(
      $url,
      scale: 1,
      headers: $api.token != null ? {'Authorization': 'Bearer ${$api.token}'} : null,
    );

    _stream = _netImage.resolve(ImageConfiguration());

    _listener = ImageStreamListener((ImageInfo image, bool synchronousCall) {
      _setLoadedState(true);
    }, onError: (exception, StackTrace stackTrace) {
      _setLoadedState(false);
    });

    _stream.addListener(_listener);
  }
}
