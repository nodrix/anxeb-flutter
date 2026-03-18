import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import '../../anxeb.dart';

class ColorDialog extends ScopeDialog {
  final String title;
  final IconData icon;
  Color _value;

  ColorDialog(
    Scope scope, {
    Color value,
    this.title,
    this.icon,
  }) : super(scope) {
    _value = value ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
      contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
      title: icon != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 7),
                    child: Icon(
                      icon,
                      size: 29,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(bottom: 10),
              child: new Text(
                title ?? scope.title,
                textAlign: TextAlign.center,
              ),
            ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              /*child: ColorPicker(
                pickerColor: _value ?? Colors.transparent,
                hexInputBar: true,
                displayThumbColor: true,
                onColorChanged: (color) {
                  _value = color;
                },
              ),*/
              child: SizedBox(
                //constraints: Device.info.isWeb ? null : BoxConstraints(maxWidth: 432),
                width: Device.info.isWeb ? 432 : null,
                child: ColorPicker(
                  color: _value ?? Colors.transparent,
                  onColorChanged: (Color color) => _value = color,
                  width: 37,
                  height: 37,
                  borderRadius: 22,
                  wheelDiameter:189,
                  showColorCode: true,
                  enableTonalPalette: true,
                  pickersEnabled: <ColorPickerType, bool>{
                    ColorPickerType.both: true,
                    ColorPickerType.primary: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                  pickerTypeLabels: {
                    ColorPickerType.both: 'Predefinidos',
                    ColorPickerType.primary: 'Primario',
                    ColorPickerType.accent: 'Secundario',
                    ColorPickerType.custom: 'Personalizado',
                    ColorPickerType.wheel: 'Rueda',
                    ColorPickerType.bw: 'Blanco y Negro',
                  },
                  subheading: Container(
                    padding: EdgeInsets.only(bottom: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: scope.application.settings.colors.separator,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 4, right: 4),
              child: Row(
                children: TextButton.createList(
                  context,
                  [
                    DialogButton(translate('anxeb.common.accept'), null, onTap: (context) async {
                      Navigator.of(context).pop(_value);
                    }),
                    DialogButton(translate('anxeb.common.cancel'), null, onTap: (context) async {
                      Navigator.of(context).pop();
                    })
                  ],
                  settings: scope.application.settings,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
