import 'dart:async';
import 'dart:convert';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import 'dart:core' as Core;
import 'dart:core';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/buttons/text.dart';
import 'application.dart';
import 'device.dart';
import 'dialog.dart';
import 'scope.dart';
import 'utils.dart';

class Printer {
  final Application application;
  BluetoothPrint _manager;
  bool _connected = false;
  Future Function(dynamic) _persist;
  dynamic Function() _fetch;
  int _lastFoundLength;
  BluetoothDevice _device;
  int _autoDiesconnectDelay;

  Printer(this.application) {
    _manager = BluetoothPrint.instance;
  }

  Future init({Future Function(dynamic) persistDevice, dynamic Function() fetchDevice, int autoDiesconnectDelay}) async {
    _persist = persistDevice;
    _fetch = fetchDevice;
    if (autoDiesconnectDelay != null) {
      this._autoDiesconnectDelay = autoDiesconnectDelay;
    }
    _manager.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          if (_device != null) {
            _connected = true;
          }
          break;
        case BluetoothPrint.DISCONNECTED:
          _connected = false;
          break;
        default:
          break;
      }
    });
  }

  Future<bool> _needPermission() async {
    final isEnabled = await _handleFuture(_manager.isOn) == true;
    final isAvailable = await _handleFuture(_manager.isAvailable) == true;
    final isGranted = isAvailable == true ? true : await _handleFuture(Device.permission.bluetoothScan.isDenied) != true;
    final isAllowed = await _handleFuture(Device.permission.bluetooth.isPermanentlyDenied) != true;

    return !isEnabled || !isAvailable || !isGranted || !isAllowed;
  }

  Future<BluetoothDevice> _lookupDevice(String address, [timeout = 2000]) async {
    var a = DateTime.now().millisecondsSinceEpoch;
    var completer = Completer<BluetoothDevice>();
    _manager.startScan(timeout: Duration(milliseconds: timeout)).then((value) {
      _manager.scanResults.listen((event) async {
        _lastFoundLength = event.length;
        final foundDevice = event.firstWhere((element) => element.address == address, orElse: () => null);

        event.map((e) => print('ADDRESS FOUND: ${e.address} == $address : ${e.address == address}'));
        if (foundDevice != null) {
          if (!completer.isCompleted) {
            try {
              await _handleFuture(_manager.stopScan());
            } catch (err) {
              //ignore
            }
            print('-- FOUND DEVICE IN ${DateTime.now().millisecondsSinceEpoch - a} ms ---------------------------------------------');
            completer.complete(foundDevice);
          }
        }
      });
    }).onError((error, stackTrace) {
      completer.completeError(error);
    });

    Future.delayed(Duration(milliseconds: timeout)).then((value) {
      if (!completer.isCompleted) {
        print('-- LOOKUP TIMEOUT ---------------------------------------------------');
        completer.complete(null);
      }
    });
    return completer.future;
  }

  Future _handleFuture(Future future) {
    var completer = Completer();
    future.then((value) {
      completer.complete(value);
    }).onError((error, stackTrace) {
      completer.completeError(error);
    });
    return completer.future;
  }

  void set({int autoDiesconnectDelay}) {
    _autoDiesconnectDelay = autoDiesconnectDelay;
    if (_autoDiesconnectDelay != null && _autoDiesconnectDelay > 0) {
      _disconnect();
    }
  }

  Future send({@required Scope scope, dynamic data, String layout}) async {
    try {
      await _handleFuture(Permission.bluetooth.request());
      await _handleFuture(Permission.bluetoothConnect.request());
      await _handleFuture(Permission.bluetoothScan.request());
    } catch (err) {
      //ignore
    }

    try {
      if (await _needPermission() == true) {
        var result = await scope.dialogs.exception(
          translate('anxeb.middleware.printer.bt_disabled_title'), //Bluetooth Desactivado
          dismissible: true,
          message: translate('anxeb.middleware.printer.bt_desabled_message'),
          icon: Icons.bluetooth_disabled,
          buttons: [
            DialogButton(translate('anxeb.common.yes'), 'settings'),
            DialogButton(translate('anxeb.common.no'), false),
          ],
        ).show();

        if (result == 'settings') {
          Device.settings.bluetooth().then((value) async {
            if (await _needPermission() == false) {
              send(scope: scope, data: data, layout: layout);
            }
          });
        }
        return;
      }

      if (_connected == false) {
        await scope.busy(text: translate('anxeb.middleware.printer.connecting_busy_label')); //'Conectando\nImpresora'

        if (_device != null) {
          await _tryConnect(Anxeb.Device.isAndroid ? 800 : 3000);
        }

        var fetchedDevice = _fetch?.call();
        if (fetchedDevice != null) {
          try {
            _device = BluetoothDevice();
            _device.type = fetchedDevice['type'];
            _device.address = fetchedDevice['address'];
            _device.name = fetchedDevice['name'];

            final result = await _tryConnect();

            if (result == false) {
              await scope.idle();
              await _handleFuture(_manager.disconnect());
              _connected = false;
              var result = await scope.dialogs.exception(
                translate('anxeb.middleware.printer.bt_reset_dialog.title'), //Dispositivo No Responde
                dismissible: true,
                message: translate('anxeb.middleware.printer.bt_reset_dialog.message'),
                icon: Icons.print_disabled,
                buttons: [
                  DialogButton(translate('anxeb.common.retry'), 'retry'),
                  DialogButton(translate('anxeb.common.scan'), 'scan'),
                ],
              ).show();

              if (result == 'retry') {
                send(scope: scope, data: data, layout: layout);
                return;
              } else if (result == null) {
                return;
              }
              await scope.busy(text: translate('anxeb.middleware.printer.connecting_busy_label')); //'Conectando\nImpresora'
            }
          } catch (err) {
            _device = null;
          }
        }

        if (_device == null) {
          await scope.idle();

          _device = await _chooseDevice(scope);
          if (_device != null) {
            await scope.busy(text: translate('anxeb.middleware.printer.connecting_busy_label')); //'Conectando\nImpresora'
            await _persistDevice();
            await _tryConnect();
          } else {
            return null;
          }
        }

        if (await isConnected() == true) {
          await scope.idle();
        }
      }
    } catch (err) {
      print('-- ERROR ------------------------------------------------------------------------------------------------------------');
      scope.alerts.error(Anxeb.translate('anxeb.middleware.printer.error_connecting')).show();
      return;
    }

    if (_connected == true) {
      _notDisconnect();
      await scope.busy(text: translate('anxeb.middleware.printer.printing_busy_label')); //'Imprimiendo\nDocumento'
      await Future.delayed(Duration(milliseconds: 500));
      try {
        Map<String, dynamic> config = Map();
        List<LineText> list = [];
        const splitter = LineSplitter();
        final text = splitter.convert(layout);

        for (var item in text) {
          if (item.startsWith('//') || item.startsWith('#') || item.length < 1) {
            continue;
          }
          var $align = LineText.ALIGN_LEFT;
          final params = _parseParams(_parseData(item, data));
          var $type = params['T'];

          var $content = '';

          if ($type == 'X') {
            $type = LineText.TYPE_TEXT;
          } else if ($type == 'I') {
            $type = LineText.TYPE_IMAGE;
          } else if ($type == 'B') {
            $type = LineText.TYPE_BARCODE;
          } else if ($type == 'Q') {
            $type = LineText.TYPE_QRCODE;
          }

          if ($type == LineText.TYPE_IMAGE) {
            var url = scope.application.api.getUri(params['CL'] ?? params['CC'] ?? params['CR']);
            if (params['CL'] != null) {
              $align = LineText.ALIGN_LEFT;
            } else if (params['CC'] != null) {
              $align = LineText.ALIGN_CENTER;
            } else if (params['CR'] != null) {
              $align = LineText.ALIGN_RIGHT;
            }
            $align = null;

            final imgData = await NetworkAssetBundle(Uri.parse(url)).load(url);
            final imageBytes = imgData.buffer.asUint8List(imgData.offsetInBytes, imgData.lengthInBytes);
            $content = base64Encode(imageBytes);
          } else {
            if (params['CC'] != null) {
              $content = params['CC'];
              final pc = _getInt(params['PC']);
              if (pc != null && pc < $content.length) {
                $content = $content.substring(0, pc);
              }
              $align = LineText.ALIGN_CENTER;
            } else {
              if (params['CL'] != null) {
                $content = _padRight(params['CL'], _getInt(params['PL']));
              }
              if (params['CR'] != null) {
                $content = $content + _padLeft(params['CR'], _getInt(params['PR']));
                $align = LineText.ALIGN_RIGHT;
              }
            }
          }

          final line = LineText(
            type: $type,
            content: $content,
            weight: _getInt(params['G']),
            align: $align,
            height: _getInt(params['H']),
            width: _getInt(params['W']),
            linefeed: 1,
            size: _getInt(params['S']),
            underline: _getInt(params['U']),
            x: _getInt(params['X']),
            y: _getInt(params['Y']),
          );
          list.add(line);

          final lf = _getInt(params['L']);

          if (lf != null && lf > 1) {
            for (var i = 1; i < lf; i++) {
              list.add(LineText(linefeed: 1));
            }
          }
        }

        await _handleFuture(_manager.printReceipt(config, list));
        await Future.delayed(Duration(milliseconds: 1500));
        _attemptDisconnect();
        await scope.idle();
      } catch (err) {
        scope.alerts.error(err).show();
      } finally {
        await scope.idle();
      }
    } else {
      _connected = false;
      scope.alerts.error(Anxeb.translate('anxeb.middleware.printer.error_connecting')).show();
    }
  }

  int _tick;

  void _notDisconnect() {
    _tick = DateTime.now().millisecondsSinceEpoch;
  }

  void _attemptDisconnect() {
    if (_autoDiesconnectDelay != null && _autoDiesconnectDelay > 0) {
      _tick = DateTime.now().millisecondsSinceEpoch;

      final thisTick = _tick;
      Future.delayed(Duration(milliseconds: _autoDiesconnectDelay)).then((value) {
        if (thisTick == _tick) {
          _disconnect();
        }
      });
    }
  }

  void _disconnect() {
    _manager.disconnect();
    _manager.destroy();
    _manager = BluetoothPrint.instance;
    _connected = false;
    _tick = null;
  }

  Future _persistDevice() async {
    if (_device != null) {
      await _persist({
        'address': _device.address,
        'type': _device.type,
        'name': _device.name,
      });
    }
  }

  Future<bool> _tryConnect([lookupTimeout = 2000]) async {
    if (_device != null) {
      if (_connected == false) {
        await _lookupDevice(_device.address, lookupTimeout);
      }

      if (await _manager.isConnected == false || _connected == false) {
        await _manager.connect(_device);
        await Future.delayed(Duration(milliseconds: 3600));
        if (await isConnected() != true) {
          _device = null;
          return false;
        }
      }

      return true;
    }
    return false;
  }

  _formatValue(value, String format) {
    if (format == null || value == null || format.length == 0) {
      return value;
    }

    if (format == 'DEC') {
      return Utils.convert.fromAnyToNumber(value, comma: true, decimals: 2);
    } else if (format == 'INT') {
      return Utils.convert.fromAnyToNumber(value, comma: true, decimals: 0);
    } else if (format == 'DTF') {
      return Utils.convert.fromDateToHumanString(Utils.convert.fromTickToDate(value), withTime: true, complete: false);
    } else if (format == 'DTH') {
      return Utils.convert.fromDateToHumanString(Utils.convert.fromTickToDate(value), withTime: true, complete: true);
    } else if (format == 'TMF') {
      return Utils.convert.fromDateToHumanString(Utils.convert.fromTickToDate(value), withTime: false, complete: false);
    } else if (format == 'TMH') {
      return Utils.convert.fromDateToHumanString(Utils.convert.fromTickToDate(value), withTime: false, complete: true);
    } else if (format == 'TID') {
      return Utils.convert.fromDateToLocalizedTime(Utils.convert.fromTickToDate(value), duration: true);
    } else if (format == 'TIM') {
      return Utils.convert.fromDateToLocalizedTime(Utils.convert.fromTickToDate(value), duration: false);
    } else if (format == 'DAT') {
      return Utils.convert.fromDateToLocalizedDate(Utils.convert.fromTickToDate(value), withTime: false);
    } else if (format == 'DAW') {
      return Utils.convert.fromDateToLocalizedDate(Utils.convert.fromTickToDate(value), withTime: true);
    } else if (format == 'UPC') {
      return value.toString().toUpperCase();
    } else if (format == 'LWC') {
      return value.toString().toLowerCase();
    } else {
      return Anxeb.DateFormat(format, Anxeb.translate('anxeb.formats.date_locale')).format(Utils.convert.fromTickToDate(value).toLocal());
    }
  }

  int _getInt(String value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  String _padLeft(String text, int pad) {
    if (pad == null) {
      return text;
    }
    if (text.length >= pad) {
      return text.substring(0, pad);
    }
    return text.padLeft(pad, ' ');
  }

  String _padRight(String text, int pad) {
    if (pad == null) {
      return text;
    }
    if (text.length >= pad) {
      return text.substring(0, pad);
    }
    return text.padRight(pad, ' ');
  }

  dynamic _parseParams(String line) {
    var params = {};
    while (true) {
      var leftIndex = line.indexOf('"');
      var rightIndex = line.indexOf('"', leftIndex + 1);

      if (leftIndex < 0 || rightIndex < 0) {
        break;
      }
      var type = line.substring(leftIndex - 3, leftIndex - 1);
      var value = line.substring(leftIndex + 1, rightIndex);

      params[type] = value;
      line = '${line.substring(0, leftIndex - 4)}${line.substring(rightIndex + 1)}';
    }

    var items = line.split(' ').where((item) => item.trim().length > 0);
    for (var item in items) {
      var parts = item.trim().split(':');
      params[parts[0]] = parts[1];
    }

    return params;
  }

  String _parseData(String line, data) {
    var result = line;
    while (true) {
      var leftIndex = result.indexOf('{{');
      var rightIndex = result.indexOf('}}');

      if (leftIndex < 0 || rightIndex < 0) {
        break;
      }
      var param = result.substring(leftIndex + 2, rightIndex);
      var content = data;
      if (param.startsWith('data.')) {
        var kcontent = param.substring(5);

        final findex = kcontent.indexOf('|');
        var format;
        if (findex > -1) {
          format = kcontent.substring(findex + 1);
          kcontent = kcontent.substring(0, findex);
        }
        var props = kcontent.split('.');

        for (var key in props) {
          if (content == null) {
            break;
          }
          content = content[key];
        }

        content = _formatValue(content, format);
      }

      result = '${result.substring(0, leftIndex)}${content != null ? content.toString() : ''}${result.substring(rightIndex + 2)}';
    }

    return result;
  }

  Future<bool> isConnected() {
    var completer = Completer<bool>();
    Future.delayed(Duration(seconds: 5)).then((value) {
      if (!completer.isCompleted) {
        completer.complete(_connected);
      }
    });
    if (_connected == true) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    } else {
      _manager.state.listen((state) async {
        _connected = false;
        if (state == BluetoothPrint.CONNECTED) {
          print ('BT IS CONNECTED');
          _connected = true;
          if (!completer.isCompleted) {
            completer.complete(_connected);
          }
        }
      });
    }
    return completer.future;
  }

  bool _isScanning;

  Future<BluetoothDevice> _chooseDevice(Scope scope) async {
    if (_isScanning != true) {
      _handleFuture(_manager.startScan(timeout: Duration(seconds: 4)));

      _manager.isScanning.listen((event) {
        _isScanning = event;
      });
    }

    return await scope.dialogs.custom(
      body: (context) {
        return Column(
          children: [
            StreamBuilder<bool>(
              stream: _manager.isScanning,
              initialData: true,
              builder: (c, snapshot) => Container(
                child: snapshot.data == false
                    ? Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 7),
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
                              ),
                            ),
                            child: Icon(
                              _lastFoundLength != null && _lastFoundLength > 0 ? Icons.print : Icons.print_disabled,
                              size: 48,
                              color: _lastFoundLength != null && _lastFoundLength > 0 ? scope.application.settings.colors.primary : scope.application.settings.colors.danger,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _lastFoundLength != null && _lastFoundLength > 0 ? translate('anxeb.middleware.printer.select_dialog_title') : translate('anxeb.middleware.printer.not_found'), //SELECCIONA UNA IMPRESORA\nDE LA LISTA
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 16.2, color: scope.application.settings.colors.primary, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 7),
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
                              ),
                            ),
                            child: SizedBox(
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                valueColor: AlwaysStoppedAnimation<Color>(scope.application.settings.colors.primary),
                              ),
                              height: 48,
                              width: 48,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              translate('anxeb.middleware.printer.scan_dialog_title'),
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 16.2, color: scope.application.settings.colors.primary, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            StreamBuilder<List<BluetoothDevice>>(
              stream: _manager.scanResults,
              initialData: [],
              builder: (c, snapshot) {
                _lastFoundLength = snapshot.data.length;
                return Column(
                  children: snapshot.data
                      .map((device) => ListTile(
                            title: Text(device.name),
                            subtitle: Text(device.address),
                            dense: true,
                            onTap: () async {
                              if (_isScanning == true) {
                                _handleFuture(_manager.stopScan());
                              }
                              Navigator.of(context).pop(device);
                            },
                            trailing: Icon(
                              Icons.bluetooth,
                              color: device.connected == true ? scope.application.settings.colors.success : scope.application.settings.colors.primary,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            StreamBuilder<bool>(
              stream: _manager.isScanning,
              initialData: true,
              builder: (c, snapshot) => Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Anxeb.TextButton(
                        caption: translate('anxeb.common.scan'),
                        radius: scope.application.settings.dialogs.buttonRadius,
                        color: scope.application.settings.colors.primary,
                        enabled: snapshot.data == false,
                        textColor: Colors.white,
                        margin: EdgeInsets.only(top: 10, right: 5),
                        onPressed: () async {
                          _handleFuture(_manager.startScan(timeout: Duration(seconds: 4))).onError((error, stackTrace) {
                            Navigator.of(context).pop(null);
                            scope.alerts.error(Anxeb.translate('anxeb.middleware.printer.error_scanning')).show();
                          });
                        },
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                    Expanded(
                      child: Anxeb.TextButton(
                        caption: snapshot.data == true ? translate('anxeb.common.cancel') : translate('anxeb.common.close'),
                        radius: scope.application.settings.dialogs.buttonRadius,
                        color: scope.application.settings.colors.primary,
                        textColor: Colors.white,
                        margin: EdgeInsets.only(top: 10, left: 5),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                          if (snapshot.data == true) {
                            try {
                              _handleFuture(_manager.stopScan());
                            } catch (err) {}
                          }
                        },
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    ).show();
  }
}
