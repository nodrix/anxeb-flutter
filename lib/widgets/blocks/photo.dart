import 'package:flutter/cupertino.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class PhotoBlock extends StatefulWidget {
  final Anxeb.Scope scope;
  final String url;
  final int tick;
  final int width;
  final int quality;
  final ColorFilter filter;
  final BorderRadius border;
  final EdgeInsets padding;
  final Color fill;
  final BoxFit fit;
  final Alignment alignment;
  final Icon failIcon;
  final GestureTapCallback onTap;
  final Color progressColor;
  final double progressSize;

  PhotoBlock({
    @required this.scope,
    @required this.url,
    this.tick,
    this.width,
    this.quality,
    this.filter,
    this.border,
    this.padding,
    this.fill,
    this.fit,
    this.alignment,
    this.failIcon,
    this.onTap,
    this.progressColor,
    this.progressSize,
  });

  @override
  _PhotoBlockState createState() => _PhotoBlockState();
}

class _PhotoBlockState extends State<PhotoBlock> {
  Anxeb.SecuredImage _netImage;
  bool _imageLoaded;
  int _tick;
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

    return Stack(
      children: <Widget>[
        AnimatedOpacity(
          opacity: isLoaded ? 1.0 : 0,
          duration: Duration(milliseconds: 300),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
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
          child: Container(
            alignment: Alignment.center,
            child: widget.failIcon ??
                Icon(
                  Anxeb.FlutterIcons.broken_image_mdi,
                  color: Colors.black12,
                  size: 90,
                ),
          ),
        ),
        widget.onTap != null
            ? Material(
                key: GlobalKey(),
                color: Colors.transparent,
                borderRadius: widget.border,
                child: InkWell(
                  onTap: widget.onTap,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.black12,
                  borderRadius: widget.border,
                ),
              )
            : Container(),
      ],
    );
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
    _tick = widget.tick;
    _setLoadedState(null);

    if (_stream != null && _listener != null) {
      _stream.removeListener(_listener);
    }

    _netImage = Anxeb.SecuredImage(
      widget.scope.application.api.getUri('${widget.url}?webp=${widget.quality ?? '60'}&width=${widget.width ?? '300'}&tick=${_tick ?? '0'}'),
      scale: 1,
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
