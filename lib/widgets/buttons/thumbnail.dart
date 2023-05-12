import 'dart:io';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../middleware/application.dart';

class ThumbnailButton extends StatefulWidget {
  final Anxeb.Scope scope;
  final GestureTapCallback onTap;
  final GestureTapCallback onDeleteTap;
  final File file;
  final String previewUrl;
  final String title;
  final String subtitle;
  final String extension;
  final DateTime modifiedDate;
  final BorderRadius borderRadius;
  final double width;
  final double height;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String toolTipTag;

  const ThumbnailButton({
    Key key,
    @required this.scope,
    this.onTap,
    this.onDeleteTap,
    this.file,
    this.previewUrl,
    this.title,
    this.subtitle,
    this.extension,
    this.modifiedDate,
    this.borderRadius,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.toolTipTag,
  }) : super(key: key);

  @override
  createState() => _ThumbnailButtonState();
}

class _ThumbnailButtonState extends State<ThumbnailButton> {
  ImageProvider _netImage;
  bool _imageLoaded;
  final GlobalIcons _icons = GlobalIcons();

  @override
  void initState() {
    _setupImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setupImage();
    var borderRadius = widget.borderRadius ?? const BorderRadius.all(Radius.circular(12.0));

    const $icon = Icons.image;

    Widget defailtIcon;

    if (meta?.image == false) {
      defailtIcon = Icon(
        meta.icon,
        color: meta.color ?? widget.scope.application.settings.colors.primary,
        size: 28,
      );
    } else if (_imageLoaded == null && _netImage != null) {
      defailtIcon = SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.primary),
        ),
      );
    } else if (_netImage == null) {
      defailtIcon = Icon(
        $icon,
        color: widget.scope.application.settings.colors.primary,
        size: 28,
      );
    }

    var stack = Stack(
      children: <Widget>[
        AnimatedOpacity(
          opacity: _imageLoaded == true ? 1 : 0,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              image: _netImage != null
                  ? DecorationImage(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                image: _netImage,
              )
                  : null,
            ),
          ),
        ),
        Container(
          decoration: _netImage == null
              ? BoxDecoration(
            color: meta?.color?.withOpacity(0.1) ?? widget.scope.application.settings.colors.primary.withOpacity(0.1),
            borderRadius: borderRadius,
          )
              : BoxDecoration(
            borderRadius: borderRadius,
            backgroundBlendMode: BlendMode.darken,
            gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              stops: const [0, 0.5, 1],
              colors: [
                const Color(0xff000000).withOpacity(0.0),
                const Color(0xff000000).withOpacity(0.0),
                const Color(0xff000000).withOpacity(0.8),
              ],
            ),
          ),
          child: defailtIcon != null
              ? Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 8, top: 10),
                    child: defailtIcon,
                  ),
                ],
              )
            ],
          )
              : Container(),
        ),
        Material(
          key: GlobalKey(),
          color: settings.colors.navigation.withOpacity(0.1),
          borderRadius: borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: borderRadius,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 6, left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: JustTheTooltip(
                            content: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      widget.toolTipTag == null
                                          ? Container()
                                          : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Anxeb.CommunityMaterialIcons.tag, size: 9, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            widget.toolTipTag,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      widget.subtitle == null
                                          ? Container()
                                          : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Anxeb.CommunityMaterialIcons.database, size: 9, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            widget.subtitle,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      widget?.file?.lastModifiedSync?.call() == null
                                          ? Container()
                                          : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.access_time_filled_outlined, size: 9, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            Anxeb.Utils.convert.fromDateToHumanString(widget.modifiedDate ?? widget.file.lastModifiedSync(), complete: true),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            preferredDirection: AxisDirection.up,
                            elevation: 4.0,
                            tailBaseWidth: 12,
                            tailLength: 8,
                            backgroundColor: widget.scope.application.settings.colors.primary,
                            borderRadius: BorderRadius.circular(6),
                            offset: 12,
                            hoverShowDuration: Duration.zero,
                            fadeOutDuration: Duration(milliseconds: 500),
                            enableFeedback: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: meta?.image == true && _imageLoaded == true ? Colors.white : widget.scope.application.settings.colors.primary,
                                  ),
                                ),
                                widget.subtitle == null
                                    ? Container()
                                    : Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                    height: 1.15,
                                    color: meta?.image == true && _imageLoaded == true ? Colors.white : widget.scope.application.settings.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        widget.onDeleteTap == null
                            ? Container()
                            : Anxeb.IconButton(
                          icon: Icons.delete,
                          iconSize: 18,
                          innerColor: application.settings.colors.danger,
                          fillColor: Colors.transparent,
                          borderWidth: 0,
                          borderPadding: 0,
                          size: 20,
                          action: () async {
                            widget.onDeleteTap();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      child: stack,
    );
  }

  void _setupImage() async {
    if (widget.file != null) {
      _netImage = meta.image == true ? Image
          .file(widget.file)
          .image : null;
      _imageLoaded = _netImage != null;
      return;
    }

    if (widget.previewUrl != null && meta?.image == true) {
      _netImage = Anxeb.SecuredImage(
        application.api.getUri(widget.previewUrl),
        headers: application?.api?.token != null ? {'Authorization': 'Bearer ${application.api.token}'} : null,
        scale: 1,
      );

      _imageLoaded = null;

      _netImage.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo image, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _imageLoaded = true;
            });
          }
        }, onError: (exception, StackTrace stackTrace) {
          _imageLoaded = false;
          if (mounted) {
            setState(() {});
          }
        }),
      );
    } else {
      _netImage = null;
      _imageLoaded = null;
    }
  }

  IconFileMeta get meta =>
      _icons.getFileMeta(widget.file?.path
          ?.split('.')
          ?.last ?? widget.extension);

  Settings get settings => widget.scope.application.settings;

  Application get application => widget.scope.application;
}
