import 'package:anxeb_flutter/anxeb.dart';
import 'dart:convert';
import 'dart:io';
import 'package:anxeb_flutter/helpers/preview.dart';
import 'package:flutter/material.dart';

enum ImageInputFieldType { front, rear, local, web }

class ImageInputField extends FieldWidget<String> {
  final ImageInputFieldType type;
  final bool fullImage;
  final bool initFaceCamera;
  final bool flash;
  final double height;
  final bool returnPath;
  final ResolutionPreset resolution;
  final FileSourceOption fileSourceOption;
  final bool showSize;
  final String url;
  final Future Function({String title, ImageProvider image, bool fullImage}) onPreview;

  ImageInputField({
    @required Scope scope,
    Key key,
    @required String name,
    String group,
    String label,
    IconData icon,
    EdgeInsets margin,
    EdgeInsets padding,
    bool readonly,
    bool visible,
    ValueChanged<String> onSubmitted,
    ValueChanged<String> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<String> onChanged,
    FormFieldValidator<String> validator,
    String Function(String value) parser,
    bool focusNext,
    String Function() fetcher,
    Function(String value) applier,
    this.type,
    this.fullImage,
    this.initFaceCamera,
    this.flash,
    this.height,
    this.returnPath,
    this.resolution,
    this.fileSourceOption,
    this.showSize,
    this.url,
    this.onPreview,
  })  : assert(name != null),
        super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onValidSubmit: onValidSubmit,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
          parser: parser,
          focusNext: focusNext,
          fetcher: fetcher,
          applier: applier,
        );

  @override
  _ImageInputFieldState createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends Field<String, ImageInputField> {
  ImageProvider _imageData;
  String _imageSize;

  @override
  void fetch() {
    super.fetch();
    _loadImage();
  }

  Future _loadImage() async {
    if (widget.url?.isEmpty == true) {
      return;
    }
    try {
      rasterize(() async {
        busy = true;
      });
      final req = await widget.scope.api.request(
        ApiMethods.GET,
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      _imageData = Image.memory(req.data).image;
      _imageSize = Utils.convert.fromAnyToDataSize(req.data.length);
      value = '';
    } catch (err) {
      _imageData = null;
      _imageSize = null;
    } finally {
      rasterize(() async {
        busy = false;
      });
    }
  }

  @override
  Future<String> lookup() async {
    if (Device.isWeb == true) {
      PlatformFile dataFile = await Device.browse<PlatformFile>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpeg', 'jpg', 'png'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async {
          return files.single;
        },
      );

      if (dataFile?.bytes?.isNotEmpty == true) {
        return 'data:image/png;base64,${base64Encode(dataFile.bytes)}';
      }
    } else {
      File result = await Device.photo(
        scope: widget.scope,
        title: widget.label,
        fullImage: widget.fullImage,
        initFaceCamera: widget.initFaceCamera,
        allowMainCamera: widget.type == ImageInputFieldType.rear,
        flash: widget.flash,
        resolution: widget.resolution,
        option: widget.fileSourceOption,
      );

      if (result != null) {
        if (widget.returnPath == true) {
          return result.path;
        } else {
          return 'data:image/png;base64,${base64Encode(result.readAsBytesSync())}';
        }
      }
    }
    return null;
  }

  @override
  void clear() {
    rasterize(() {
      _imageData = null;
      _imageSize = null;
    });
    return super.clear();
  }

  @override
  Widget display([String text]) {
    if (super.busy == true || _imageData == null) {
      return Container(
        padding: EdgeInsets.only(top: 2),
        child: super.display(widget.label),
      );
    }

    Widget previewImage = GestureDetector(
      onTap: () async {
        _preview();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: _imageData,
          ),
        ),
      ),
    );

    return Container(
      child: Container(
        padding: EdgeInsets.only(bottom: 10, top: 6),
        child: widget.height == null ? AspectRatio(aspectRatio: 1, child: previewImage) : SizedBox(height: widget.height, child: previewImage),
      ),
    );
  }

  @override
  String label() => widget.showSize == true && _imageSize != null ? '${widget.label} - $_imageSize' : null;

  @override
  void present() {
    if (value?.isNotEmpty == true && mounted) {
      if (value != null) {
        if (Device.isWeb == false && widget.returnPath == true) {
          var file = File(value);
          if (file.existsSync()) {
            _imageData = Image.file(file).image;
            _imageSize = Utils.convert.fromAnyToDataSize(file.lengthSync());
          } else {
            _imageData = null;
            _imageSize = null;
          }
        } else {
          _imageData = Image.memory(base64Decode(value.substring(22))).image;
          _imageSize = Utils.convert.fromAnyToDataSize(value.length);
        }
      } else {
        _imageData = null;
        _imageSize = null;
      }
      setState(() {});
    }
  }

  Future _preview() async {
    var image = _imageData; // ?? (widget.url != null ? NetworkImage(widget.url) : null);
    if (image != null) {
      var result;
      if (widget.onPreview != null) {
        result = await widget.onPreview.call(
          title: widget.label,
          image: image,
          fullImage: widget.fullImage,
        );
      } else if (widget.scope is ScreenScope) {
        result = await (widget.scope as ScreenScope).push(ImagePreviewHelper(
          title: widget.label,
          image: image,
          canRemove: true,
          fullImage: widget.fullImage,
        ));
      } else {
        final $value = await lookup();
        if ($value != null) {
          submit($value);
        }
      }
      if (result == false) {
        clear();
      }
    }
  }

  @override
  bool get canClear => _imageData != null;
}
