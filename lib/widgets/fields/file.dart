import 'dart:io';
import 'dart:typed_data';
import 'package:anxeb_flutter/helpers/document.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import '../../middleware/device.dart';
import '../../middleware/utils.dart';
import '../../screen/scope.dart';

class FileInputValue {
  final String url;
  final String path;
  final String extension;
  final Uint8List data;
  String title;
  String id;
  bool useFullUrl;

  FileInputValue({this.url, this.path, this.title, this.extension, this.data, this.id, this.useFullUrl = false});

  bool get isImage => ['jpg', 'png', 'jpeg'].contains(extension);

  String get previewText => title ?? basename(path);

  Map<String, dynamic> toJSON() {
    return {'title': title, 'extension': extension};
  }
}

class FileInputField extends FieldWidget<FileInputValue> {
  final List<String> allowedExtensions;
  final String launchUrlPrefix;
  final Future Function({String launchUrl, FileInputValue file, bool readonly}) onPreview;

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
    FileInputValue Function() fetcher,
    Function(FileInputValue value) applier,
    FieldWidgetTheme theme,
    this.allowedExtensions,
    this.launchUrlPrefix,
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
          theme: theme,
        );

  @override
  _FileInputFieldState createState() => _FileInputFieldState();
}

class _FileInputFieldState extends Field<FileInputValue, FileInputField> {
  String _previewText;
  final GlobalIcons icons = GlobalIcons();

  @override
  Future<FileInputValue> lookup() async {
    if (Device.isWeb == true) {
      PlatformFile dataFile = await Device.browse<PlatformFile>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async {
          return files.single;
        },
      );

      if (dataFile != null) {
        return FileInputValue(
          data: dataFile.bytes,
          title: basename(dataFile.name),
          extension: dataFile.extension,
        );
      }
    } else {
      final shouldUseCamera = await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);
      File pathFile;

      if (shouldUseCamera == true) {
        pathFile = await Device.photo(
          scope: widget.scope,
          title: widget.label,
          fullImage: true,
          initFaceCamera: false,
          allowMainCamera: true,
          fileName: widget.label.toLowerCase().replaceAll(' ', '_'),
          flash: true,
          resolution: ResolutionPreset.high,
        );
      } else if (shouldUseCamera == false) {
        pathFile = await Device.browse<File>(
          scope: widget.scope,
          type: FileType.custom,
          allowMultiple: false,
          showBusyOnPicking: false,
          allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
          callback: (files) async {
            return File(files.single.path);
          },
        );
      }

      if (pathFile != null) {
        return FileInputValue(
          path: pathFile.path,
          title: basename(pathFile.path),
          extension: (extension(pathFile.path ?? '') ?? '').replaceFirst('.', ''),
          url: null,
          id: null,
        );
      }
    }

    return null;
  }

  @override
  Widget display([String text]) {
    if (_previewText != null) {
      return GestureDetector(
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
      return Container(
        padding: EdgeInsets.only(top: 2),
        child: super.display(widget.label),
      );
    }
  }

  @override
  void present() {
    if (mounted) {
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
  }

  Future _preview() async {
    if (value != null) {
      var result;
      if (widget.onPreview != null) {
        result = await widget.onPreview.call(
          launchUrl: widget.launchUrlPrefix,
          file: value,
          readonly: widget.readonly,
        );
      } else if (widget.scope is ScreenScope) {
        result = await (widget.scope as ScreenScope).push(DocumentView(
          launchUrl: widget.launchUrlPrefix,
          file: value,
          initialScale: PhotoViewComputedScale.contained,
          readonly: widget.readonly,
        ));
      }
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
}
