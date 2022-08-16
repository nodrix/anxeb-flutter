import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ML;
import 'package:file_picker/file_picker.dart' as Picker;
import '../helpers/camera.dart';
import 'dialog.dart';
import 'utils.dart';
import 'package:package_info/package_info.dart';

class Device {
  static final Device _singleton = Device._internal();

  factory Device() {
    return _singleton;
  }

  Device._internal();

  static DeviceInfo info = DeviceInfo();

  static Future<File> photo({Scope scope, FileSourceOption option, String title, bool initFaceCamera, bool allowMainCamera, bool fullImage, bool flash, ResolutionPreset resolution, String fileName}) async {
    File result;
    bool useCameraHelper;

    if (option == FileSourceOption.prompt) {
      useCameraHelper = await Utils.dialogs.shouldUseCamera(scope);
      if (useCameraHelper == null) {
        return null;
      }
    } else {
      useCameraHelper = option == null || option == FileSourceOption.camera;
    }

    if (useCameraHelper) {
      result = await scope.view.push(CameraHelper(
        title: title,
        fullImage: fullImage,
        initFaceCamera: initFaceCamera,
        allowMainCamera: allowMainCamera,
        flash: flash,
        resolution: resolution,
        fileName: fileName,
      ));
    } else {
      result = await browse<File>(
        scope: scope,
        type: Picker.FileType.image,
        allowMultiple: false,
        callback: (files) async {
          return File(files.single.path);
        },
      );
    }

    return result;
  }

  static Future<String> scan({Scope scope, FileSourceOption option, String title, bool autoflash}) async {
    String value;
    bool useCameraHelper;

    if (option == FileSourceOption.prompt) {
      useCameraHelper = await Utils.dialogs.shouldUseCamera(scope);
      if (useCameraHelper == null) {
        return null;
      }
    } else {
      useCameraHelper = option == null || option == FileSourceOption.camera;
    }

    if (useCameraHelper) {
      try {
        var scanResult = await BarcodeScanner.scan(
          options: ScanOptions(
            strings: {
              'cancel': 'X',
              'flash_on': translate('anxeb.device.camera.flash_on_label'), //TR Encender Luz
              'flash_off': translate('anxeb.device.camera.flash_off_label'), //TR Apagar Luz
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
    } else {
      value = await browse<String>(
        scope: scope,
        allowedExtensions: ['jpeg', 'jpg', 'png'],
        type: FileType.custom,
        allowMultiple: false,
        callback: (files) async {
          final barcodeScanner = ML.BarcodeScanner(formats: [ML.BarcodeFormat.all]);
          try {
            final List<ML.Barcode> barcodes = await barcodeScanner.processImage(ML.InputImage.fromFilePath(files.first.path));
            if (barcodes.length > 0) {
              return barcodes.first.rawValue;
            } else {
              scope.alerts.error(translate('anxeb.device.scan.barcode_not_found')).show(); //No se encontró ningún código de barras en la imagen
            }
          } catch (err) {
            scope.alerts.error(translate('anxeb.device.scan.barcode_scan_error')).show(); //Error procesando o descargando imagen
          }
          return null;
        },
      );
    }

    return value?.isNotEmpty == true ? value : null;
  }

  static Future<T> browse<T>({Scope scope, Future<T> Function(List<PlatformFile>) callback, FileType type, List<String> allowedExtensions, bool allowMultiple}) async {
    FilePickerResult picker;
    T result;

    bool _isBusy = false;
    try {
      picker = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        type: type,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        onFileLoading: (state) async {
          if (state == FilePickerStatus.picking) {
            await scope?.busy?.call(
              timeout: 0,
              text: translate('anxeb.device.browse.loading_busy_label'), //Cargando Archivo
            );
            _isBusy = true;
          }
        },
      );
      await Future.delayed(Duration(milliseconds: 500));
    } on PlatformException catch (err) {
      await Future.delayed(Duration(milliseconds: 500));

      if (_isBusy) {
        await scope?.idle?.call();
        _isBusy = false;
      }
      if (err.code == 'read_external_storage_denied') {
        var result = await scope.dialogs.exception(
          translate('anxeb.device.browse.access_denied_title'), //Acceso al Disco Desactivado
          dismissible: true,
          message: translate('anxeb.device.browse.access_denied_message'),
          //¿Quieres habilitar el acceso al disco?
          icon: Icons.sd_storage,
          buttons: [
            DialogButton(translate('anxeb.common.yes'), 'settings'),
            DialogButton(translate('anxeb.common.no'), false),
          ],
        ).show();

        if (result == 'settings') {
          openAppSettings();
        }
      } else if (err.code == 'already_active') {
        //THIS IS A LIBRARY ISSUE
        await scope?.alerts?.error?.call(err)?.show?.call();
      } else {
        print('Not registered file browser code: ${err.code}');
        await scope?.alerts?.error?.call(err)?.show?.call();
      }
    } catch (err) {
      await Future.delayed(Duration(milliseconds: 500));

      if (_isBusy) {
        await scope?.idle?.call();
        _isBusy = false;
      }
      await scope?.alerts?.error?.call(err)?.show?.call();
    }

    if (picker?.files?.isNotEmpty == true) {
      result = callback != null ? (await callback(picker.files)) : picker.files;
    }

    if (_isBusy) {
      await scope?.idle?.call();
    }
    return result;
  }
}

class DeviceInfo {
  IosDeviceInfo _ios;
  AndroidDeviceInfo _android;
  PackageInfo _package;

  DeviceInfo() {
    init();
  }

  Future<DeviceInfo> init() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _android = await info.androidInfo;
    } else {
      _ios = await info.iosInfo;
    }
    _package = await PackageInfo.fromPlatform();
    return this;
  }

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;

  PackageInfo get package => _package;

  String get id => _ios.identifierForVendor ?? _android?.androidId;

  String get model => _ios?.utsname?.machine ?? _android?.model;

  String get version => _ios?.systemVersion ?? _android?.version?.baseOS;
}

enum FileSourceOption { browse, camera, prompt }
