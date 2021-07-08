import 'dart:convert';
import 'dart:io';
import 'package:anxeb_flutter/helpers/camera.dart';
import 'package:anxeb_flutter/helpers/preview.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/blocks/photo.dart';
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum ImageInputFieldType { front, rear, local, web }

class ImageInputField extends FieldWidget<String> {
  final ImageInputFieldType type;
  final bool fullImage;
  final bool initFaceCamera;
  final bool flash;
  final double height;
  final bool returnPath;
  final ResolutionPreset resolution;
  final bool askPickMethod;
  final bool showTextPreview;
  final String url;

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
    double fontSize,
    double labelSize,
    this.type,
    this.fullImage,
    this.initFaceCamera,
    this.flash,
    this.height,
    this.returnPath,
    this.resolution,
    this.askPickMethod,
    this.showTextPreview,
    this.url,
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
          fontSize: fontSize,
          labelSize: labelSize,
        );

  @override
  _ImageInputFieldState createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends Field<String, ImageInputField> {
  ImageProvider _takenPicture;
  String _previewText;

  @override
  void init() {}

  @override
  void setup() {}

  void _takePicture() async {
    File result = await CameraHelper.takePicture(
      scope: widget.scope,
      title: widget.label,
      fullImage: widget.fullImage,
      initFaceCamera: widget.initFaceCamera,
      allowMainCamera: widget.type == ImageInputFieldType.rear,
      flash: widget.flash,
      resolution: widget.resolution,
      askPickMethod: widget.askPickMethod,
    );

    if (result != null) {
      if (widget.returnPath == true) {
        super.submit(result.path);
      } else {
        super.submit('data:image/png;base64,${base64Encode(result.readAsBytesSync())}');
      }
    }
  }

  @override
  void prebuild() {}

  @override
  void onBlur() {
    super.onBlur();
  }

  @override
  void onFocus() {
    super.onFocus();
  }

  @override
  dynamic data() {
    return super.data();
  }

  @override
  void clear() {
    rasterize(() {
      _takenPicture = null;
    });
    return super.clear();
  }

  @override
  void present() {
    setState(() {
      if (value != null) {
        if (widget.returnPath == true) {
          var file = File(value);
          if (file.existsSync()) {
            _takenPicture = Image.file(file).image;
            _previewText = 'Archivo de ' + Utils.convert.fromAnyToDataSize(file.lengthSync());
          } else {
            _takenPicture = null;
            _previewText = null;
          }
        } else {
          _takenPicture = Image.memory(base64Decode(value.substring(22))).image;
          _previewText = 'Archivo de ' + Utils.convert.fromAnyToDataSize(value.length);
        }
      } else {
        _takenPicture = null;
        _previewText = null;
      }
    });
  }

  @override
  Widget field() {
    Widget previewImage;
    if (_takenPicture != null) {
      previewImage = GestureDetector(
        onTap: () async {
          _preview();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              image: _takenPicture,
            ),
          ),
        ),
      );
    } else if (widget.url != null) {
      previewImage = PhotoBlock(
        scope: widget.scope,
        tick: widget.scope.tick,
        url: widget.url,
        quality: 80,
        fill: Colors.white,
        border: BorderRadius.all(
          Radius.circular(10.0),
        ),
        failIcon: Icon(
          Icons.photo,
          color: Colors.black12,
          size: 80,
        ),
        onTap: (isFailed) async {
          if (isFailed != true) {
            _preview();
          } else if (_takenPicture == null) {
            _takePicture();
          }
        },
        fit: BoxFit.cover,
      );
    }

    var previewContent;

    if (_takenPicture != null || widget.url != null) {
      if (widget.showTextPreview == true && _previewText != null) {
        previewContent = GestureDetector(
          onTap: () async {
            _preview();
          },
          child: Container(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              _previewText,
              style: TextStyle(
                fontSize: 16,
                color: widget.scope.application.settings.colors.text,
              ),
            ),
          ),
        );
      } else {
        previewContent = Container(
          child: Container(
            padding: EdgeInsets.only(bottom: 10),
            child: widget.height == null
                ? AspectRatio(
                    aspectRatio: 1,
                    child: previewImage,
                  )
                : Container(
                    height: widget.height,
                    child: previewImage,
                  ),
          ),
        );
      }
    } else {
      previewContent = Container(
        padding: EdgeInsets.only(top: 7),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.fontSize != null ? (widget.fontSize * 0.9) : 16,
            color: Color(0x88000000),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (widget.readonly == true) {
          return;
        }
        focus();
        if (value == null) {
          _takePicture();
        }
      },
      child: new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            isFocused: focused,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.only(left: 0, top: 7, bottom: 0, right: 0),
              prefixIcon: Icon(
                widget.icon ?? FontAwesome5.dot_circle,
                size: widget.iconSize,
                color: widget.scope.application.settings.colors.primary,
              ),
              labelText: (_takenPicture != null || widget.url != null) ? widget.label : null,
              labelStyle: widget.labelSize != null ? TextStyle(fontSize: widget.labelSize) : null,
              fillColor: focused ? widget.scope.application.settings.colors.focus : widget.scope.application.settings.colors.input,
              errorText: warning,
              border: UnderlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
              suffixIcon: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.readonly == true) {
                    return;
                  }
                  if (value != null && _takenPicture != null) {
                    clear();
                  } else {
                    _takePicture();
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: previewContent,
          );
        },
      ),
    );
  }

  Future _preview() async {
    var image = _takenPicture ?? (widget.url != null ? NetworkImage(widget.url) : null);
    if (image != null) {
      var result = await widget.scope.view.push(ImagePreviewHelper(
        title: widget.label,
        image: image,
        canRemove: true,
        fullImage: widget.fullImage,
      ));
      if (result == false) {
        clear();
      }
    }
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null && _takenPicture != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(widget.askPickMethod == true ? Icons.search : Ionicons.md_camera, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }
}
