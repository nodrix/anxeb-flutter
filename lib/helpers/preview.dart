import 'dart:io';
import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class ImagePreviewHelper extends ViewWidget {
  final String title;
  final ImageProvider image;
  final bool canRemove;
  final bool fullImage;
  final bool fromCamera;

  ImagePreviewHelper({this.title, this.image, this.canRemove, this.fullImage, this.fromCamera}) : super('anxeb_preview_helper', title: title);

  @override
  _ImagePreviewState createState() => new _ImagePreviewState();
}

class _ImagePreviewState extends View<ImagePreviewHelper, Application> {
  PhotoViewControllerBase _controller;

  @override
  void setup() {
    window.overlay.brightness = Brightness.light;
    window.overlay.extendBodyFullScreen = true;
  }

  @override
  Future init() async {
    _controller = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getLoading() {
    var length = window.horizontal(0.16);
    return Center(
      child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(scope.application.settings.colors.primary),
        ),
        height: length,
        width: length,
      ),
    );
  }

  @override
  Widget content() {
    double size = scope.window.horizontal(0.90);
    double topPadding = scope.window.vertical(0.1);

    if (widget.fullImage == true) {
      return PhotoView(
        imageProvider: widget.image,
        tightMode: false,
        gaplessPlayback: true,
        initialScale: PhotoViewComputedScale.covered,
        backgroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Color(0xfff0f0f0),
              Color(0xffc3c3c3),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        controller: _controller,
        loadFailedChild: Center(
          child: Icon(
            Icons.broken_image,
            size: 140,
            color: application.settings.colors.primary.withOpacity(0.2),
          ),
        ),
        loadingBuilder: (context, event) {
          return _getLoading();
        },
      );
    }

    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(offset: Offset(0, 5), blurRadius: 18, spreadRadius: 2, color: Color(0xaa888888))],
          borderRadius: new BorderRadius.all(
            Radius.circular(22.0),
          ),
          image: DecorationImage(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            image: widget.image,
          ),
        ),
      ),
    );
  }

  @override
  ViewAction action() {
    return ViewAction(
      scope: scope,
      color: () => scope.application.settings.colors.secudary,
      icon: () => widget.fromCamera == true ? null : (Platform.isAndroid ? Icons.arrow_back : Icons.chevron_left),
      onPressed: () => pop(true),
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          isVisible: () => widget.fromCamera == true,
          icon: () => Icons.delete,
          onPressed: () => dismiss(),
        ),
      ],
    );
  }
}
