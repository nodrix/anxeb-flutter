import 'dart:convert';
import 'dart:io';
import 'package:anxeb_flutter/helpers/camera.dart';
import 'package:anxeb_flutter/helpers/preview.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum ImageInputFieldType { front, rear, local, web }

class ImageInputField extends FieldWidget<String> {
  final ImageInputFieldType type;

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
    ValueChanged<dynamic> onSubmitted,
    ValueChanged<dynamic> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<dynamic> onChanged,
    FormFieldValidator<String> validator,
    this.type,
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
        );

  @override
  _ImageInputFieldState createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends Field<String, ImageInputField> {
  ImageProvider _takenPicture;

  @override
  void init() {}

  @override
  void setup() {}

  void _takePicture() async {
    var result = await widget.scope.view.push(CameraHelper(
      title: widget.label,
      rear: widget.type == ImageInputFieldType.rear,
    ));

    if (result != null) {
      File image = result as File;
      super.submit('data:image/png;base64,${base64Encode(image.readAsBytesSync())}');
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
  void present() {
    setState(() {
      if (value != null) {
        _takenPicture = Image.memory(base64Decode(value.substring(22))).image;
      } else {
        _takenPicture = null;
      }
    });
  }

  @override
  Widget field() {
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
                color: widget.scope.application.settings.colors.primary,
              ),
              labelText: _takenPicture != null ? widget.label : null,
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
                  if (value != null) {
                    clear();
                  } else {
                    _takePicture();
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding: value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: _takenPicture != null
                  ? Container(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () async {
                              var result = await widget.scope.view.push(ImagePreviewHelper(title: widget.label, image: _takenPicture, canRemove: true));
                              if (result == false) {
                                clear();
                              }
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
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0x88000000),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(Ionicons.md_camera, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }
}
