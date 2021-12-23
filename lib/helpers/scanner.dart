import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode/ai_barcode.dart';

class ScannerHelper extends ViewWidget {
  final String title;
  final bool autoflash;

  ScannerHelper({
    this.title,
    this.autoflash,
  }) : super('anxeb_scanner_helper', title: title);

  @override
  _ScannerHelperState createState() => new _ScannerHelperState();
}

class _ScannerHelperState extends View<ScannerHelper, Application> {
  ScannerController _scannerController;
  bool _flashOn;

  @override
  Future init() async {
    _flashOn = widget.autoflash == true;

    _scannerController = ScannerController(scannerResult: (result) {
      pop(result, force: true);
    }, scannerViewCreated: () async {
      TargetPlatform platform = Theme.of(context).platform;

      if (TargetPlatform.iOS == platform) {
        await Future.delayed(Duration(milliseconds: 700), () {
          _scannerController.startCamera();
          _scannerController.startCameraPreview();
        });
      } else {
        await Future.delayed(Duration(milliseconds: 0), () {
          _scannerController.startCamera();
          _scannerController.startCameraPreview();
        });
      }

      if (_flashOn == true) {
        _onFlash();
      } else {
        _offFlash();
      }
    });
  }

  void _offFlash() {
    _scannerController.stopCameraPreview();
    _scannerController.closeFlash();
    _scannerController.startCameraPreview();
  }

  void _onFlash() {
    _scannerController.stopCameraPreview();
    _scannerController.openFlash();
    _scannerController.startCameraPreview();
  }

  void _flush() {
    try {
      _scannerController.stopCameraPreview();
    } catch (x) {}
    try {
      _scannerController.stopCamera();
    } catch (x) {}

    _offFlash();
  }

  @override
  void dispose() {
    _flush();
    super.dispose();
  }

  @override
  void setup() {
    window.overlay.brightness = Brightness.dark;
    window.overlay.extendBodyFullScreen = false;
  }

  @override
  void prebuild() {}

  @override
  ActionsHeader header() {
    return ActionsHeader(
      title: () => widget.title ?? 'Enfoque el Código',
      scope: scope,
    );
  }

  @override
  Widget content() {
    return Container(
      color: scope.application.settings.colors.navigation,
      child: Center(
        child: PlatformAiBarcodeScannerWidget(
          platformScannerController: _scannerController,
        ),
      ),
    );
  }

  @override
  ViewAction action() {
    return ViewAction(
      scope: scope,
      icon: () => _flashOn == true ? Icons.lightbulb : Icons.lightbulb_outline,
      color: () => scope.application.settings.colors.secudary,
      onPressed: () {
        rasterize(() {
          _flashOn = _flashOn != true;
        });
        if (_flashOn == true) {
          _onFlash();
        } else {
          _offFlash();
        }
      },
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => Icons.clear,
          onPressed: () => dismiss(),
        ),
      ],
    );
  }
}
