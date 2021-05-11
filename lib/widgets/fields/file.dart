import 'dart:io';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class FileInputField extends FieldWidget<List<String>> {
  final bool allowMultiples;
  final List<String> allowedExtensions;
  final String url;

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
    ValueChanged<List<String>> onSubmitted,
    ValueChanged<List<String>> onValidSubmit,
    GestureTapCallback onTab,
    GestureTapCallback onBlur,
    GestureTapCallback onFocus,
    ValueChanged<List<String>> onChanged,
    FormFieldValidator<String> validator,
    List<String> Function(List<String> value) parser,
    bool focusNext,
    double fontSize,
    double labelSize,
    this.allowMultiples,
    this.allowedExtensions,
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
  _FileInputFieldState createState() => _FileInputFieldState();
}

class _FileInputFieldState extends Field<List<String>, FileInputField> {
  final GlobalIcons icons = GlobalIcons();
  List<File> _files;

  @override
  void present() {
    setState(() {
      if (value != null) {
        _files = [];
        value.forEach((filePath) {
          final file = File(filePath);
          _files.add(file);
        });
      } else {
        _files = null;
      }
    });
  }

  @override
  Widget field() {
    var previewContent;

    if (_files != null || widget.url != null) {
      previewContent = GestureDetector(
        onTap: () async {},
        child: Container(
          padding: EdgeInsets.only(top: 2),
          child: Column(
            children: _files.map((file) {
              final iconMeta = icons.getFileMeta(
                extension(file.path).replaceFirst('.', ''),
              );
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      iconMeta.icon,
                      color: iconMeta.color,
                      size: 24,
                    ),
                    Text(
                      basename(file.path),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.scope.application.settings.colors.link,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
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
          _pickFiles();
        }
      },
      child: new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            isFocused: focused,
            decoration: InputDecoration(
              filled: true,
              contentPadding:
                  EdgeInsets.only(left: 0, top: 7, bottom: 0, right: 0),
              prefixIcon: Icon(
                widget.icon ?? FontAwesome5.dot_circle,
                size: widget.iconSize,
                color: widget.scope.application.settings.colors.primary,
              ),
              labelText:
                  (_files != null || widget.url != null) ? widget.label : null,
              labelStyle: widget.labelSize != null
                  ? TextStyle(fontSize: widget.labelSize)
                  : null,
              fillColor: focused
                  ? widget.scope.application.settings.colors.focus
                  : widget.scope.application.settings.colors.input,
              errorText: warning,
              border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
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
                    _pickFiles();
                  }
                },
                child: _getIcon(),
              ),
            ),
            child: Padding(
              padding:
                  value == null ? EdgeInsets.only(top: 5) : EdgeInsets.zero,
              child: previewContent,
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
      return Icon(Icons.clear,
          color: widget.scope.application.settings.colors.primary);
    } else {
      return Icon(Icons.search,
          color: warning != null
              ? widget.scope.application.settings.colors.danger
              : widget.scope.application.settings.colors.primary);
    }
  }

  void _pickFiles() async {
    try {
      final picker = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions.isEmpty ? FileType.any : FileType.custom,
        allowMultiple: widget.allowMultiples,
        allowedExtensions: widget.allowedExtensions,
        onFileLoading: (state) async {
          await widget.scope.busy();
        },
      );

      await Future.delayed(Duration(milliseconds: 350));
      await widget.scope.idle();

      if (picker != null) {
        this.submit(picker.files.map((file) => file.path).toList());
      }
    } catch (err) {
      await widget.scope.idle();
      widget.scope.alerts
          .asterisk('Debe permitir el acceso al sistema de archivos')
          .show();
    }
  }
}
