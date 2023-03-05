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
import 'package:file_picker/file_picker.dart' as Picker;
import 'package:url_launcher/url_launcher.dart' as UL;
import '../helpers/camera.dart';
import '../screen/scope.dart';
import 'dialog.dart';
import 'utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_store/open_store.dart';
import 'package:app_settings/app_settings.dart';
import 'package:scan/scan.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Device {
  static final Device _singleton = Device._internal();

  factory Device() {
    return _singleton;
  }

  Device._internal();

  static DeviceInfo info = DeviceInfo();

  static DeviceSettings settings = DeviceSettings();

  static DevicePermissions permission = DevicePermissions();

  static bool isAndroid = kIsWeb != true && Platform.isAndroid == true;

  static bool isIOS = kIsWeb != true && Platform.isIOS == true;

  static bool isWeb = kIsWeb == true;

  static Future launchStore({String appStoreId, String androidAppBundleId}) async {
    OpenStore.instance.open(
      appStoreId: appStoreId,
      androidAppBundleId: androidAppBundleId,
    );
  }

  static Future launchUrl({@required Scope scope, @required String url}) async {
    if (await UL.canLaunchUrl(Uri.parse(url))) {
      await scope.busy();
      await UL.launchUrl(Uri.parse(url));
      await scope.idle();
    } else {
      scope.dialogs.exception(translate('anxeb.exceptions.navigator_init')).show(); //Error iniciando navegador web
    }
  }

  static Future<File> photo({@required ScreenScope scope, FileSourceOption option, String title, bool initFaceCamera, bool allowMainCamera, bool fullImage, bool flash, ResolutionPreset resolution, String fileName}) async {
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
      result = await scope.push(CameraHelper(
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

  static Future<String> scan({@required Scope scope, FileSourceOption option, String title, bool autoflash}) async {
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
          try {
            final barcodeValue = await Scan.parse(files.first.path);
            if (barcodeValue?.isNotEmpty == true) {
              return barcodeValue;
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

  static Future<T> browse<T>({@required Scope scope, Future<T> Function(List<PlatformFile>) callback, FileType type, List<String> allowedExtensions, bool allowMultiple, bool withData = false, bool withReadStream = false, String dialogTitle, bool showBusyOnPicking}) async {
    FilePickerResult picker;
    T result;

    bool _isBusy = false;
    try {
      picker = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        type: type,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        withData: withData,
        withReadStream: withReadStream,
        dialogTitle: dialogTitle,
        onFileLoading: (state) async {
          if (showBusyOnPicking != false && state == FilePickerStatus.picking) {
            await scope?.busy?.call(
              timeout: 0,
              text: translate('anxeb.device.browse.loading_busy_label'), //Cargando Archivo
            );
            _isBusy = true;
          }
        },
      );
      if (showBusyOnPicking != false) {
        await Future.delayed(Duration(milliseconds: 500));
      }
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
          settings.storage();
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

class DevicePermissions {
  Permission get calendar => Permission.calendar;

  Permission get camera => Permission.camera;

  Permission get contacts => Permission.contacts;

  Permission get location => Permission.location;

  Permission get locationAlways => Permission.locationAlways;

  Permission get locationWhenInUse => Permission.locationWhenInUse;

  Permission get mediaLibrary => Permission.mediaLibrary;

  Permission get microphone => Permission.microphone;

  Permission get phone => Permission.phone;

  Permission get photos => Permission.photos;

  Permission get photosAddOnly => Permission.photosAddOnly;

  Permission get reminders => Permission.reminders;

  Permission get sensors => Permission.sensors;

  Permission get sms => Permission.sms;

  Permission get speech => Permission.speech;

  Permission get storage => Permission.storage;

  Permission get ignoreBatteryOptimizations => Permission.ignoreBatteryOptimizations;

  Permission get notification => Permission.notification;

  Permission get accessMediaLocation => Permission.accessMediaLocation;

  Permission get activityRecognition => Permission.activityRecognition;

  Permission get unknown => Permission.unknown;

  Permission get bluetooth => Permission.bluetooth;

  Permission get manageExternalStorage => Permission.manageExternalStorage;

  Permission get systemAlertWindow => Permission.systemAlertWindow;

  Permission get requestInstallPackages => Permission.requestInstallPackages;

  Permission get appTrackingTransparency => Permission.appTrackingTransparency;

  Permission get criticalAlerts => Permission.criticalAlerts;

  Permission get accessNotificationPolicy => Permission.accessNotificationPolicy;

  Permission get bluetoothScan => Permission.bluetoothScan;

  Permission get bluetoothAdvertise => Permission.bluetoothAdvertise;

  Permission get bluetoothConnect => Permission.bluetoothConnect;
}

class DeviceSettings {
  Future wifi() => AppSettings.openWIFISettings();

  Future wireless() => AppSettings.openWirelessSettings();

  Future location() => AppSettings.openLocationSettings();

  Future security() => AppSettings.openSecuritySettings();

  Future lock() => AppSettings.openLockAndPasswordSettings();

  Future bluetooth() => AppSettings.openBluetoothSettings();

  Future roaming() => AppSettings.openDataRoamingSettings();

  Future date() => AppSettings.openDateSettings();

  Future display() => AppSettings.openDisplaySettings();

  Future notification() => AppSettings.openNotificationSettings();

  Future sound() => AppSettings.openSoundSettings();

  Future storage() => AppSettings.openInternalStorageSettings();

  Future battery() => AppSettings.openBatteryOptimizationSettings();

  Future app() => AppSettings.openAppSettings();

  Future nfc() => AppSettings.openNFCSettings();

  Future device() => AppSettings.openDeviceSettings();

  Future vpn() => AppSettings.openVPNSettings();

  Future accessibility() => AppSettings.openAccessibilitySettings();

  Future development() => AppSettings.openDevelopmentSettings();

  Future hotspot() => AppSettings.openHotspotSettings();
}

class DeviceInfo {
  IosDeviceInfo _ios;
  AndroidDeviceInfo _android;
  PackageInfo _package;

  DeviceInfo() {
    init();
  }

  Future<DeviceInfo> init() async {
    if (isWeb == false) {
      final info = DeviceInfoPlugin();
      if (isAndroid) {
        _android = await info.androidInfo;
      } else if (isIOS) {
        _ios = await info.iosInfo;
      }
    }
    _package = await PackageInfo.fromPlatform();
    return this;
  }

  bool get isAndroid => kIsWeb != true && Platform.isAndroid;

  bool get isIOS => kIsWeb != true && Platform.isIOS;

  bool get isWeb => kIsWeb == true;

  PackageInfo get package => _package;

  String get id => _ios.identifierForVendor ?? _android?.androidId;

  String get model => _ios?.utsname?.machine ?? _android?.model;

  String get version => _ios?.systemVersion ?? _android?.version?.baseOS;
}

enum FileSourceOption { browse, camera, prompt }
