import 'dart:io';
import '../../middleware/utils.dart';
import '../../screen/scope.dart';
import 'file.dart';
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

class FilesInputField extends FieldWidget<List<FileInputValue>> {
  final bool allowMultiples;
  final List<String> allowedExtensions;
  final String launchUrlPrefix;
  final Future Function({String launchUrl, FileInputValue file, bool readonly}) onPreview;

  FilesInputField({
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
    ValueChanged<List<FileInputValue>> onSubmitted,
    ValueChanged<List<FileInputValue>> onApplied,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<List<FileInputValue>> onChanged,
    FormFieldValidator<List<FileInputValue>> validator,
    List<FileInputValue> Function(dynamic value) parser,
    FieldFocusType focusType,
    Future<List<FileInputValue>> Function() fetcher,
    Function(List<FileInputValue> value) applier,
    FieldWidgetTheme theme,
    bool keepLookingUp,
    this.allowMultiples = false,
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
          onApplied: onApplied,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          keepLookingUp: keepLookingUp,
          sufixIcon: Icons.add,
        );

  @override
  _FilesInputFieldState createState() => _FilesInputFieldState();
}

class _FilesInputFieldState extends Field<List<FileInputValue>, FilesInputField> {
  final GlobalIcons icons = GlobalIcons();
  List<FileInputValue> files = [];

  @override
  Future<List<FileInputValue>> lookup() async {
    if (Device.isWeb == true) {
      List<PlatformFile> dataFiles = await Device.browse<List<PlatformFile>>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: widget.allowMultiples,
        allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async {
          return files;
        },
      );

      if (dataFiles?.isNotEmpty == true) {
        return dataFiles.map((e) => FileInputValue(data: e.bytes, title: basename(e.name), extension: e.extension)).toList();
      }
    } else {
      final shouldUseCamera = await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);
      List<File> pathFiles;

      if (shouldUseCamera == true) {
        final picture = await Device.photo(
          scope: widget.scope,
          title: widget.label,
          fullImage: true,
          initFaceCamera: false,
          allowMainCamera: true,
          fileName: widget.label.toLowerCase().replaceAll(' ', '_'),
          flash: true,
          resolution: ResolutionPreset.high,
        );

        if (picture != null) {
          pathFiles = [];
          pathFiles.add(picture);
        }
      } else if (shouldUseCamera == false) {
        pathFiles = await Device.browse<List<File>>(
          scope: widget.scope,
          type: FileType.custom,
          allowMultiple: widget.allowMultiples,
          showBusyOnPicking: false,
          allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
          callback: (files) async {
            return files.map((file) => File(file.path)).toList();
          },
        );
      }

      if (pathFiles?.isNotEmpty == true) {
        files.addAll(pathFiles
            .map((file) => FileInputValue(
                  path: file.path,
                  title: basename(file.path),
                  extension: (extension(file.path ?? '') ?? '').replaceFirst('.', '').toLowerCase(),
                  url: null,
                  id: null,
                ))
            .toList());
        super.submit(files);
      }
    }

    return null;
  }

  @override
  Widget display([String text]) {
    if (value?.isNotEmpty == true) {
      return Column(
        children: value
            .map(
              (file) => Container(
                padding: EdgeInsets.only(top: file == value.first ? 2 : 6, bottom: 1),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      //child: _getMimeIcon(file),
                      child: GestureDetector(
                        onTap: () {
                          _remove(file);
                        },
                        child: Icon(
                          Icons.delete,
                          color: widget.scope.application.settings.colors.danger,
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: GestureDetector(
                          onTap: () async {
                            _preview(file);
                          },
                          child: Text(
                            file.previewText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1,
                              fontSize: 16,
                              color: widget.scope.application.settings.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 2),
        child: super.display(widget.label),
      );
    }
  }

  Future _remove(FileInputValue file) async {
    if (widget.readonly != true) {
      files.remove(file);
      super.submit(files);
    }
  }

  Future _preview(FileInputValue value) async {
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

  @override
  void clear() {
    files.clear();
    super.clear();
  }
}
