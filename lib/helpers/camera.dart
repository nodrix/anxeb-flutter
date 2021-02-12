import 'dart:io';
import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:anxeb_flutter/widgets/blocks/empty.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'preview.dart';
import 'package:file_picker/file_picker.dart' as Picker;

class CameraHelper extends ViewWidget {
  final String title;
  final bool allowMainCamera;
  final Image frameImage;
  final bool initFaceCamera;
  final bool fullImage;
  final bool flash;
  final ResolutionPreset resolution;

  static Future<File> takePicture({
    Scope scope,
    bool askPickMethod,
    String title,
    bool initFaceCamera,
    bool allowMainCamera,
    bool fullImage,
    bool flash,
    ResolutionPreset resolution,
  }) async {
    File result;

    var option;
    if (askPickMethod == true) {
      await scope.dialogs.panel(
        items: [
          PanelMenuItem(
            actions: [
              PanelMenuAction(
                label: () => 'Buscar\nImagen',
                textScale: 0.9,
                icon: () => FlutterIcons.file_image_mco,
                fillColor: () => scope.application.settings.colors.secudary,
                onPressed: () {
                  option = 'image';
                },
              ),
              PanelMenuAction(
                label: () => 'Tomar\nFoto',
                textScale: 0.9,
                icon: () => FlutterIcons.md_camera_ion,
                fillColor: () => scope.application.settings.colors.secudary,
                onPressed: () {
                  option = 'photo';
                },
              ),
            ],
            height: () => 120,
          ),
        ],
      ).show();
    } else {
      option = 'photo';
    }

    if (option == 'photo') {
      result = await scope.view.push(CameraHelper(
        title: title,
        fullImage: fullImage,
        initFaceCamera: initFaceCamera,
        allowMainCamera: allowMainCamera,
        flash: flash,
        resolution: resolution,
      ));
    } else if (option == 'image') {
      try {
        var picker = await Picker.FilePicker.platform.pickFiles(
          type: Picker.FileType.image,
          allowMultiple: false,
          onFileLoading: (state) async {
            await scope.busy();
          },
        );
        await Future.delayed(Duration(milliseconds: 350));
        await scope.idle();
        if (picker != null) {
          result = File(picker.files.single.path);
        }
      } catch (err) {
        await scope.idle();
        scope.alerts.asterisk('Debe permitir el acceso al sistema de archivos').show();
      }
    }

    return result;
  }

  CameraHelper({
    this.title,
    this.allowMainCamera,
    this.initFaceCamera,
    this.frameImage,
    this.fullImage,
    this.flash,
    this.resolution,
  }) : super('anxeb_camera_helper', title: title);

  @override
  _CameraHelperState createState() => new _CameraHelperState();
}

class _CameraHelperState extends View<CameraHelper, Application> {
  CameraController _camera;
  CameraDescription _mainCamera;
  CameraDescription _faceCamera;
  Future<void> _initializeControllerFuture;
  bool _diabled = false;
  bool _initilized = false;

  @override
  Future init() async {
    availableCameras().then((cameras) {
      _mainCamera = cameras.length > 0 ? cameras.first : null;
      _faceCamera = cameras.length > 1 ? cameras[1] : null;

      if (widget.initFaceCamera == true) {
        _initCamera(_faceCamera);
      } else {
        _initCamera(_mainCamera);
      }
    });
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  void setup() {
    window.overlay.brightness = Brightness.dark;
    window.overlay.extendBodyFullScreen = true;
  }

  void _submit(File result) {
    pop(result);
  }

  void _debug(String text) {
    //print(text);
  }
  
  void _takePicture({bool preview, bool canRemove}) async {
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

      _debug('TAKING PICTURE...');
      var xfile = await _camera.takePicture();
      xfile.saveTo(path);

      _debug('NORMALIZING...');
      File original = File(xfile.path);

      var properties = await ImageCrop.getImageOptions(file: original);

      _debug('NORMALIZED');
      _debug(' WIDTH  ${properties.width}');
      _debug(' HEIGHT ${properties.height}');

      File reduced;
      if (widget.fullImage != true) {
        reduced = await ImageCrop.sampleImage(file: original, preferredSize: _reduceSize);
      } else {
        reduced = await ImageCrop.sampleImage(file: original, preferredSize: properties.width ?? _reduceSize);
      }
      
      _debug('REFRESHING IMAGE PROPERTIES');
      properties = await ImageCrop.getImageOptions(file: reduced);

      _debug('REDUCED');
      _debug(' WIDTH  ${properties.width} vs $_reduceSize');
      _debug(' HEIGHT ${properties.height} vs $_reduceSize');

      var cropped;
      if (widget.fullImage != true) {
        bool $horizontal = properties.width > properties.height;
        int $width = properties.width;
        int $height = properties.height;
        double $t;
        double $l;
        double $size;

        if ($horizontal) {
          _debug('HORIZONTAL CALC');
          $size = $height * 0.9;
          $l = (properties.height / properties.width) * _topOffset;
          $t = ((properties.height - $size) / 2) / properties.height;
        } else {
          _debug('VERTICAL CALC');
          $size = $width * 0.9;
          $l = ((properties.width - $size) / 2) / properties.width;
          $t = (properties.width / properties.height) * _topOffset;
        }

        double $w = $size / properties.width;
        double $h = $size / properties.height;

        _debug('CROPPING RATIOS');
        _debug(' T ${$t}');
        _debug(' L ${$l}');
        _debug(' S ${$w} x ${$h}');

        cropped = await ImageCrop.cropImage(
          file: reduced,
          area: Rect.fromLTWH($l, $t, $w, $h),
        );

        properties = await ImageCrop.getImageOptions(file: cropped);

        _debug('CROPPED');
        _debug(' WIDTH  ${properties.width}');
        _debug(' HEIGHT ${properties.height}');
        _debug(' SIZE   ${(cropped.readAsBytesSync().length / 1024).round()}KB');
      }

      File $finalFile = cropped ?? reduced ?? original;

      if (preview == true) {
        var previewImage = Image.file($finalFile).image;
        setState(() {
          _diabled = false;
        });

        var result = await push(ImagePreviewHelper(
          title: title,
          image: previewImage,
          fullImage: widget.fullImage,
          canRemove: canRemove,
          fromCamera: true,
        ));

        if (result == true) {
          _submit($finalFile);
        }
      } else {
        await scope.idle();
        setState(() {
          _diabled = false;
        });
        _submit($finalFile);
      }
    } catch (err) {
      await scope.dialogs.error(err).show();
      setState(() {
        _diabled = false;
      });
    }
  }

  void _swapCameras() {
    if (_faceCamera != null && !_noCamera) {
      if (_camera.description == _mainCamera) {
        _initCamera(_faceCamera);
      } else {
        _initCamera(_mainCamera);
      }
    }
  }

  void _initCamera(CameraDescription camera) {
    if (camera != null) {
      _camera = CameraController(
        camera,
        widget.resolution ?? ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _camera.initialize();
      _initializeControllerFuture.then((value) {
        setState(() {});
      });
    }
  }

  @override
  void prebuild() {}

  @override
  Widget content() {
    if (_initializeControllerFuture == null) {
      return EmptyBlock(
        scope: scope,
        message: 'Sin Cámara',
        icon: Icons.error_outline,
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_camera.value.isInitialized) {
            return EmptyBlock(
              scope: scope,
              message: 'Sin Cámara',
              icon: Icons.error_outline,
            );
          }

          if (_initilized == false) {
            _initilized = true;
            Future.delayed(new Duration(milliseconds: 50), () {
              setState(() {});
            });
          }

          if (widget.fullImage == true) {
            return Container(
              color: scope.application.settings.colors.navigation,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1/_camera.value.aspectRatio,
                  child: CameraPreview(_camera),
                ),
              ),
            );
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
                        height: window.size.width * _camera.value.aspectRatio,
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
      color: () => scope.application.settings.colors.secudary,
      onPressed: () => {
        _takePicture(
          preview: widget.fullImage == true,
          canRemove: widget.fullImage == true,
        )
      },
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => (Platform.isAndroid ? Icons.arrow_back : Icons.chevron_left),
          onPressed: () => dismiss(),
        ),
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => _mainCameraActive ? Icons.camera_rear : Icons.camera_front,
          onPressed: _swapCameras,
          isDisabled: () => _noCamera,
          isVisible: () => _mainCameraAvailable == true,
        ),
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => Icons.image,
          onPressed: () => _takePicture(preview: true),
          isVisible: () => widget.fullImage != true,
          isDisabled: () => _noCamera || _diabled == true,
        ),
      ],
      isDisabled: () => _noCamera,
    );
  }

  bool get _noCamera => _camera == null || _camera.value == null || _camera.value.isInitialized != true;

  bool get _mainCameraAvailable => _mainCamera != null && widget.allowMainCamera == true;

  bool get _mainCameraActive => _camera?.description == _mainCamera;
}
