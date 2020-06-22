import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:flutter/material.dart';

class ImagePreviewHelper extends ViewWidget {
  final String title;
  final ImageProvider image;
  final bool canRemove;

  ImagePreviewHelper({this.title, this.image, this.canRemove}) : super('anxeb_preview_helper', title: title);

  @override
  _ImagePreviewState createState() => new _ImagePreviewState();
}

class _ImagePreviewState extends View<ImagePreviewHelper, Application> {
  @override
  Future<bool> beforePop() async => true;

  @override
  PreferredSizeWidget header() {
    return new AppBar(
      title: new Text(this.title ?? 'Vista Previa'),
      automaticallyImplyLeading: false,
      leading: new BackButton(
        onPressed: dismiss,
      ),
    );
  }

  @override
  Widget content() {
    double size = scope.window.horizontal(0.90);
    double topPadding = scope.window.vertical(0.1);
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
  Widget footer() {
    if (widget.canRemove != true) {
      return null;
    }
    return BottomAppBar(
      color: settings.colors.primary,
      notchMargin: 8,
      elevation: 20,
      clipBehavior: Clip.hardEdge,
      child: Row(children: <Widget>[
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.delete),
          onPressed: () => pop(false),
        ),
      ]),
      shape: CircularNotchedRectangle(),
    );
  }

  @override
  Widget action() {
    return FloatingActionButton(
      onPressed: () => pop(true),
      backgroundColor: settings.colors.success,
      child: new Icon(Icons.check),
    );
  }
}
