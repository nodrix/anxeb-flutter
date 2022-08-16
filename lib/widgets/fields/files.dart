import 'dart:io';
import '../../middleware/utils.dart';
import 'file.dart';
import 'package:anxeb_flutter/helpers/document.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import '../../middleware/device.dart';

class FilesInputField extends FieldWidget<List<FileInputValue>> {
  final bool allowMultiples;
  final List<String> allowedExtensions;
  final String launchUrlPrefix;

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
    ValueChanged<List<FileInputValue>> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<List<FileInputValue>> onChanged,
    FormFieldValidator<String> validator,
    List<FileInputValue> Function(dynamic value) parser,
    bool focusNext,
    double fontSize,
    double labelSize,
    BorderRadius borderRadius,
    this.allowMultiples = false,
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
          borderRadius: borderRadius,
        );

  @override
  _FilesInputFieldState createState() => _FilesInputFieldState();
}

class _FilesInputFieldState extends Field<List<FileInputValue>, FilesInputField> {
  final GlobalIcons icons = GlobalIcons();
  List<FileInputValue> files = [];

  @override
  void init() {}

  @override
  void setup() {}

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
  Widget field() {
    var previewContent;

    if (value != null && value.isNotEmpty) {
      previewContent = Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
            children: value
                .map((file) => GestureDetector(
                      onTap: () async {
                        _preview(file);
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 2, bottom: 4),
                        child: Row(
                          children: [
                            if (widget.readonly != true)
                              GestureDetector(
                                  onTap: () => _removeItemFile(file),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4, top: 1),
                                    child: Icon(Icons.clear, color: widget.scope.application.settings.colors.primary, size: 16),
                                  )),
                            Padding(
                              padding: const EdgeInsets.only(right: 4, bottom: 2),
                              child: _getMimeIcon(file),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
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
                            )
                          ],
                        ),
                      ),
                    ))
                .toList()),
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
      child: FormField(
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
              labelText: (value != null && value.isNotEmpty) ? widget.label : null,
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

                  _pickFile();
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

  void _pickFile() async {
    final shouldUseCamera = await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);
    List<File> result = [];

    if (shouldUseCamera == true) {
      final title = widget.label + '_' + new DateTime.now().toIso8601String();
      final picture = await Device.photo(
        title: title,
        fullImage: true,
        initFaceCamera: false,
        allowMainCamera: true,
        fileName: title.toLowerCase().replaceAll(' ', '_'),
        flash: true,
        resolution: ResolutionPreset.high,
      );

      if (picture != null) {
        result.add(picture);
      }
    } else if (shouldUseCamera == false) {
      result = await Device.browse<List<File>>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: widget.allowMultiples,
        allowedExtensions: widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
        callback: (files) async {
          return files.map((file) => File(file.path)).toList();
        },
      );
    }

    if (result != null && result.isNotEmpty) {
      files.addAll(result
          .map((file) => FileInputValue(
                path: file.path,
                title: basename(file.path),
                extension: (extension(file.path ?? '') ?? '').replaceFirst('.', ''),
                url: null,
                id: null,
              ))
          .toList());
      super.submit(files);
    }
  }

  Future _preview(FileInputValue value) async {
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

  Icon _getMimeIcon(FileInputValue value) {
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

    return Icon(Icons.search, color: warning != null ? widget.scope.application.settings.colors.danger : widget.scope.application.settings.colors.primary);
  }

  void _removeItemFile(FileInputValue file) {
    files = value.where((element) => element != file).toList();
    if (files.isNotEmpty) {
      super.submit(files);
    } else {
      clear();
    }
  }
}
