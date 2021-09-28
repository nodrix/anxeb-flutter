import 'dart:io';
import 'package:anxeb_flutter/helpers/camera.dart';
import 'package:anxeb_flutter/helpers/document.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';

class FileInputValue {
  FileInputValue({this.url, this.path, this.title, this.extension, this.useFullUrl=false});

  String url;
  String path;
  String title;
  String extension;
  bool useFullUrl;

  bool get isImage => ['jpg', 'png', 'jpeg'].contains(extension);
}

class FileInputField extends FieldWidget<FileInputValue> {
  final List<String> allowedExtensions;
  final String launchUrlPrefix;

  FileInputField({
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
    ValueChanged<FileInputValue> onSubmitted,
    ValueChanged<FileInputValue> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<FileInputValue> onChanged,
    FormFieldValidator<String> validator,
    FileInputValue Function(FileInputValue value) parser,
    bool focusNext,
    double fontSize,
    double labelSize,
    this.allowedExtensions,
    this.launchUrlPrefix,
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
  _FileInputFieldState createState() => _FileInputFieldState();
}

class _FileInputFieldState extends Field<FileInputValue, FileInputField> {
  String _previewText;
  final GlobalIcons icons = GlobalIcons();

  @override
  void init() {}

  @override
  void setup() {}

  void _pickFile() async {
    var option;
    await widget.scope.dialogs.panel(
      items: [
        PanelMenuItem(
          actions: [
            PanelMenuAction(
              label: () => 'Buscar\nDocumento',
              textScale: 0.9,
              icon: () => FlutterIcons.file_mco,
              fillColor: () => widget.scope.application.settings.colors.secudary,
              onPressed: () {
                option = 'document';
              },
            ),
            PanelMenuAction(
              label: () => 'Tomar\nFoto',
              textScale: 0.9,
              icon: () => FlutterIcons.md_camera_ion,
              fillColor: () => widget.scope.application.settings.colors.secudary,
              onPressed: () {
                option = 'photo';
              },
            ),
          ],
          height: () => 120,
        ),
      ],
    ).show();

    File result;

    if (option == 'photo') {
      result = await widget.scope.view.push(CameraHelper(
        title: widget.label,
        fullImage: true,
        initFaceCamera: false,
        allowMainCamera: true,
        fileName: widget.label.toLowerCase().replaceAll(' ', '_'),
        flash: true,
        resolution: ResolutionPreset.high,
      ));
    } else if (option == 'document') {
      try {
        final picker = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
          onFileLoading: (state) async {
            await widget.scope.busy();
          },
        );

        await Future.delayed(Duration(milliseconds: 350));
        await widget.scope.idle();

        if (picker != null && picker.files.first != null) {
          result = File(picker.files.first.path);
        }
      } catch (err) {
        await widget.scope.idle();
        widget.scope.alerts.asterisk('Debe permitir el acceso al sistema de archivos').show();
      }
    }

    if (result != null) {
      super.submit(FileInputValue(
        path: result.path,
        title: basename(result.path),
        extension: (extension(result.path ?? '') ?? '').replaceFirst('.', ''),
        url: null,
      ));
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
      if (value?.title != null) {
        _previewText = value.title;
      } else if (value?.path != null) {
        var file = File(value.path);
        _previewText = basename(file.path);
      } else {
        _previewText = null;
      }
    });
  }

  @override
  Widget field() {
    var previewContent;

    if (_previewText != null) {
      previewContent = GestureDetector(
        onTap: () async {
          _preview();
        },
        child: Container(
          padding: EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                child: _getMimeIcon(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    _previewText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1,
                      fontSize: 16,
                      color: widget.scope.application.settings.colors.primary,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      previewContent = Container(
        padding: EdgeInsets.only(top: 2),
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
          _pickFile();
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
              labelText: (value?.path != null || value?.url != null) ? widget.label : null,
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
                  if (value != null) {
                    clear();
                  } else {
                    _pickFile();
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding: value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: previewContent,
            ),
          );
        },
      ),
    );
  }

  Future _preview() async {
    if (value != null) {
      var result = await widget.scope.view.push(DocumentView(
        launchUrl: widget.launchUrlPrefix,
        file: value,
        initialScale: PhotoViewComputedScale.contained,
        readonly: widget.readonly,
      ));
      present();
      if (result == false) {
        clear();
      }
    }
  }

  Icon _getMimeIcon() {
    var ext = value?.extension ?? (value?.path != null ? extension(value.path).replaceFirst('.', '') : null) ?? 'txt';
    var meta = icons.getFileMeta(ext);

    return Icon(
      meta?.icon ?? Icons.insert_drive_file,
      color: meta?.color ?? Color(0x88000000),
      size: 12,
    );
  }

  Icon _getIcon() {
    if (widget.readonly == true) {
      return Icon(Icons.lock_outline);
    }

    if (value != null) {
      return Icon(Icons.clear, color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(Icons.search, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
    }
  }
}
