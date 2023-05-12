import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import '../../middleware/application.dart';
import '../../screen/scope.dart';

class PreviewerBlock extends StatefulWidget {
  final ScreenScope scope;
  final File file;
  final PhotoViewComputedScale initialScale;
  final String tag;

  PreviewerBlock({
    @required this.scope,
    @required this.file,
    this.initialScale,
    this.tag,
  });

  @override
  State<PreviewerBlock> createState() => _PreviewerBlockState();
}

class _PreviewerBlockState extends State<PreviewerBlock> {
  PhotoViewControllerBase _imageController;
  Completer<PDFViewController> _controllerAlt;
  int _pages = 1;
  int _currentPage = 1;

  @override
  void initState() {
    _imageController = PhotoViewController();
    _controllerAlt = Completer<PDFViewController>();
    super.initState();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPdf) {
      return Stack(
        children: [
          Container(
            child: PDFView(
              filePath: widget.file.path,
              fitEachPage: true,
              fitPolicy: FitPolicy.WIDTH,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: false,
              preventLinkNavigation: true,
              pageSnap: false,
              onRender: (_pages) {
                setState(() {
                  _pages = _pages;
                });
              },
              onError: (error) {
                scope.alerts.error(error).show();
              },
              onPageError: (page, error) {
                scope.alerts.error(error).show();
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controllerAlt.complete(pdfViewController);
              },
              onPageChanged: (int page, int total) {
                setState(() {
                  _currentPage = (page + 1);
                  _pages = total;
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                '$_currentPage / $_pages',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
              ),
            ),
          ),
          _getTag(),
        ],
      );
    } else {
      return Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(widget.file),
            gaplessPlayback: true,
            backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                Color(0xfff0f0f0),
                Color(0xffc3c3c3),
              ],
              stops: [0.0, 1.0],
            )),
            controller: _imageController,
            initialScale: widget.initialScale ?? PhotoViewComputedScale.covered,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image,
                  size: 140,
                  color: application.settings.colors.primary.withOpacity(0.2),
                ),
              );
            },
            loadingBuilder: (context, event) {
              return _getLoading();
            },
          ),
          _getTag(),
        ],
      );
    }
  }

  Widget _getTag() {
    if (widget.tag == null) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(scope.application.settings.dialogs.dialogRadius ?? 20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        margin: EdgeInsets.only(bottom: 10),
        child: Text(
          widget.tag,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
        ),
      ),
    );
  }

  Widget _getLoading() {
    var length = scope.window.horizontal(0.16);
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

  Application get application => scope.application;

  ScreenScope get scope => widget.scope;

  bool get _isPdf => ['pdf'].contains(widget.file.path.toLowerCase().split('.').last.toLowerCase());
}
