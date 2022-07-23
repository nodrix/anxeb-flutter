import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ML;

import '../parts/panels/menu.dart';

class Device {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getModelName() async {
    if (Platform.isAndroid) {
      var androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } else {
      var iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
  }

  Future<String> beginBarcodeScan({Scope scope, bool autoflash, String title, ScanFlags flag}) async {
    String value;

    if (flag == ScanFlags.ask || flag == ScanFlags.browse) {

      var option = 'browse';

      if (flag == ScanFlags.ask) {
        await scope.dialogs.panel(
          items: [
            PanelMenuItem(
              actions: [
                PanelMenuAction(
                  label: () => translate('anxeb.utils.device.scanner.browse'),
                  //TR 'Buscar\nImagen',
                  textScale: 0.9,
                  icon: () => FlutterIcons.file_mco,
                  fillColor: () => scope.application.settings.colors.secudary,
                  onPressed: () {
                    option = 'browse';
                  },
                ),
                PanelMenuAction(
                  label: () => translate('anxeb.utils.device.scanner.camera'),
                  //TR 'Usar\nCámara',
                  textScale: 0.9,
                  icon: () => FlutterIcons.md_camera_ion,
                  fillColor: () => scope.application.settings.colors.secudary,
                  onPressed: () {
                    option = 'camera';
                  },
                ),
              ],
              height: () => 120,
            ),
          ],
        ).show();
      }

      if (option == 'browse') {
        try {
          final picker = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
            allowedExtensions: ['jpeg', 'jpg', 'png'],
            onFileLoading: (state) async {
              await scope.busy();
            },
          );

          if (picker != null && picker.files.first != null) {
            final barcodeScanner = ML.BarcodeScanner(formats: [ML.BarcodeFormat.all]);
            final List<ML.Barcode> barcodes = await barcodeScanner.processImage(ML.InputImage.fromFilePath(picker.files.first.path));

            await scope.idle();
            await Future.delayed(Duration(milliseconds: 500));
            if (barcodes.length > 0) {
              return barcodes.first.rawValue;
            } else {
              scope.alerts.error(translate('anxeb.utils.device.scanner.barcode_not_found')).show(); //No se encontró ningún código de barras en la imagen
            }
          }
        } catch (err) {
          await scope.idle();
          await Future.delayed(Duration(milliseconds: 500));
          scope.alerts.asterisk(translate('anxeb.widgets.fields.file.access_request')).show(); //Debe permitir el acceso al sistema de archivos
        }

        return null;
      }
    }

    try {
      var scanResult = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': 'X',
            'flash_on': translate('anxeb.utils.device.flash_on_label'), //TR Encender Luz
            'flash_off': translate('anxeb.utils.device.flash_off_label'), //TR Apagar Luz
          },
          autoEnableFlash: autoflash != null ? autoflash : true,
          android: AndroidOptions(
            useAutoFocus: true,
          ),
        ),
      );
      value = scanResult.rawContent;
    } catch (e) {
      value = null;
    }
    return value?.isNotEmpty == true ? value : null;
  }
}

enum ScanFlags { browse, scan, ask }
