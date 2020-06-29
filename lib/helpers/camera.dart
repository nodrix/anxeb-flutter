import 'dart:io';
import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/header.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:anxeb_flutter/widgets/blocks/empty.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'preview.dart';

class CameraHelper extends ViewWidget {
  final String title;
  final bool rear;
  final Image frameImage;

  CameraHelper({this.title, this.rear, this.frameImage}) : super('anxeb_camera_helper', title: title);

  @override
  _CameraHelperState createState() => new _CameraHelperState();
}

class _CameraHelperState extends View<CameraHelper, Application> {
  CameraController _camera;
  CameraDescription _frontCameraDesc;
  CameraDescription _rearCameraDesc;
  Future<void> _initializeControllerFuture;
  bool _diabled = false;
  bool _initilized = false;

  @override
  Future init() async {
    availableCameras().then((cameras) {
      _frontCameraDesc = cameras.length > 0 ? cameras.first : null;
      _rearCameraDesc = cameras.length > 1 ? cameras[1] : null;

      _initCamera(_frontCameraDesc);
    });
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  void setup() {}

  void _submit(File result) {
    pop(result);
  }

  void _takePicture({bool preview}) async {
    if (_noCamera || _diabled == true) {
      return;
    }

    setState(() {
      _diabled = true;
    });
    try {
      final _topOffset = 0.14577;
      final _reduceSize = 1000;

      await _initializeControllerFuture;
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.jpg');

      //print('TAKING PICTURE...');
      await _camera.takePicture(path);

      //print('NORMALIZING...');
      File normalized = File(path);
      var properties = await ImageCrop.getImageOptions(file: normalized);

      //print('NORMALIZED');
      //print(' WIDTH  ${properties.width}');
      //print(' HEIGHT ${properties.height}');

      final reduced = await ImageCrop.sampleImage(file: normalized, preferredSize: _reduceSize);
      properties = await ImageCrop.getImageOptions(file: reduced);

      //print('REDUCED');
      //print(' WIDTH  ${properties.width} vs $_reduceSize');
      //print(' HEIGHT ${properties.height} vs $_reduceSize');

      bool $horizontal = properties.width > properties.height;
      int $width = properties.width;
      int $height = properties.height;
      double $t;
      double $l;
      double $size;

      if ($horizontal) {
        //print('HORIZONTAL CALC');
        $size = $height * 0.9;
        $l = (properties.height / properties.width) * _topOffset;
        $t = ((properties.height - $size) / 2) / properties.height;
      } else {
        //print('VERTICAL CALC');
        $size = $width * 0.9;
        $l = ((properties.width - $size) / 2) / properties.width;
        $t = (properties.width / properties.height) * _topOffset;
      }

      double $w = $size / properties.width;
      double $h = $size / properties.height;

      //print('CROPPING RATIOS');
      //print(' T ${$t}');
      //print(' L ${$l}');
      //print(' S ${$w} x ${$h}');

      final cropped = await ImageCrop.cropImage(
        file: reduced,
        area: Rect.fromLTWH($l, $t, $w, $h),
      );

      properties = await ImageCrop.getImageOptions(file: cropped);

      //print('CROPPED');
      //print(' WIDTH  ${properties.width}');
      //print(' HEIGHT ${properties.height}');
      //print(' SIZE   ${(cropped.readAsBytesSync().length / 1024).round()}KB');

      if (preview == true) {
        var previewImage = Image.file(cropped).image;
        setState(() {
          _diabled = false;
        });

        var result = await push(ImagePreviewHelper(
          title: title,
          image: previewImage,
        ));

        if (result == true) {
          _submit(cropped);
        }
      } else {
        await scope.idle();
        setState(() {
          _diabled = false;
        });
        _submit(cropped);
      }
    } catch (err) {
      await scope.dialogs.error(err).show();
      setState(() {
        _diabled = false;
      });
    }
  }

  void _swapCameras() {
    if (_rearCameraDesc != null) {
      if (_camera.description == _frontCameraDesc) {
        _initCamera(_rearCameraDesc);
      } else {
        _initCamera(_frontCameraDesc);
      }
    }
  }

  void _initCamera(CameraDescription camera) {
    if (camera != null) {
      _camera = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _camera.initialize();
    }
    setState(() {});
  }

  @override
  Future<bool> beforePop() async => true;

  @override
  void prebuild() {}

  @override
  ViewHeader header() {
    return ActionsHeader(
      scope: scope,
      leading: ActionBack(),
      actions: [
        ActionIcon(
          icon: () => _frontCameraActive ? Icons.camera_rear : Icons.camera_front,
          onPressed: _swapCameras,
          isVisible: () => _frontCameraAvailable == true,
        ),
        ActionIcon(
          icon: () => Icons.image,
          onPressed: () => _takePicture(preview: true),
          isDisabled: () => _noCamera || _diabled == true,
        ),
      ],
    );
  }

  @override
  Widget content() {
    if (_initializeControllerFuture == null) {
      return EmptyBlock(
        'Sin Cámara',
        Icons.error_outline,
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_camera.value.isInitialized) {
            return EmptyBlock(
              'Sin Cámara',
              Icons.error_outline,
            );
          }

          if (_initilized == false) {
            _initilized = true;
            Future.delayed(new Duration(milliseconds: 50), () {
              setState(() {});
            });
          }

          return Stack(
            children: <Widget>[
              Container(
                width: window.size.width,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fitWidth,
                      child: Container(
                        width: window.size.width,
                        height: window.size.width / _camera.value.aspectRatio,
                        child: CameraPreview(
                          _camera,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: window.size.width,
                padding: EdgeInsets.only(top: 0),
                child: widget.frameImage ??
                    Image.asset(
                      'assets/images/common/camera-frame.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  ViewAction action() {
    return ViewAction(
      scope: scope,
      icon: () => Icons.camera_alt,
      onPressed: _takePicture,
      isDisabled: () => _noCamera,
    );
  }

  bool get _noCamera => _camera == null || _camera.value == null || _camera.value.isInitialized != true;

  bool get _frontCameraAvailable => _frontCameraDesc != null && widget.rear == true;

  bool get _frontCameraActive => _camera.description == _frontCameraDesc;
}
