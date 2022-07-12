import 'dart:async';
import 'dart:io';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/middleware/view.dart';
import 'package:anxeb_flutter/misc/action_menu.dart';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:anxeb_flutter/widgets/blocks/empty.dart';
import 'package:anxeb_flutter/widgets/components/dialog_progress.dart';
import 'package:anxeb_flutter/widgets/fields/file.dart';
import 'package:anxeb_flutter/widgets/fields/text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as Launcher;

class DocumentView extends ViewWidget {
  final FileInputValue file;
  final String launchUrl;
  final bool readonly;
  final Future Function(FileInputValue) updated;
  final String tag;
  final PhotoViewComputedScale initialScale;

  DocumentView({
    @required this.file,
    this.launchUrl,
    this.readonly = true,
    this.updated,
    this.tag,
    this.initialScale,
  })  : assert(file != null),
        super('anxeb_document_helper', title: file?.title ?? translate('anxeb.helpers.document.title')); //TR Vista Archivo

  @override
  _DocumentState createState() => new _DocumentState();
}

class _DocumentState extends View<DocumentView, Application> {
  PhotoViewControllerBase _controller;
  File _data;
  bool _refreshing;
  PDFView _pdfFileAlt;
  Completer<PDFViewController> _controllerAlt;
  int _pages = 1;
  int _currentPage = 1;

  @override
  Future init() async {
    _controller = PhotoViewController();
    _controllerAlt = Completer<PDFViewController>();
    _refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setup() {}

  @override
  void prebuild() {}

  @override
  ActionsHeader header() {
    return ActionsHeader(
      scope: scope,
      title: () {
        return widget.file?.title ?? translate('anxeb.helpers.document.title'); //TR Vista Archivo
      },
      actions: <ActionMenu>[
        ActionMenu(
          actions: [
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.reload_file'), //TR 'Recargar Archivo',
              icon: () => Icons.refresh,
              onPressed: () => _refresh(),
            ),
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.change_title'), //TR 'Cambiar Título',
              icon: () => Icons.text_fields,
              onPressed: () => _changeTitle(),
              isVisible: () => widget.readonly != true && widget.file?.id != null,
            ),
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.open_browser'), //TR 'Abrir en Navegador',
              icon: () => Icons.launch,
              isVisible: () => widget.launchUrl != null && widget.file?.url != null,
              onPressed: () => _launch(),
            ),
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.share'), //TR 'Compartir o Enviar',
              icon: () => Icons.share,
              isVisible: () => widget.file?.url != null,
              onPressed: () => _share(),
            ),
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.download_browser'), //TR 'Descargar en Navegador',
              icon: () => Icons.file_download,
              isVisible: () => widget.launchUrl != null && widget.file?.url != null,
              onPressed: () => _download(),
            ),
            ActionMenuItem(
              caption: () => translate('anxeb.helpers.document.menu.delete_file'),
              //TR Eliminar Archivo
              icon: () => Icons.close,
              divided: () => true,
              color: () => scope.application.settings.colors.danger,
              onPressed: () => _removeFile(),
              isVisible: () => widget.readonly != true && widget.file?.url != null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget content() {
    if (_refreshing == true && _data == null) {
      return _getLoading();
    } else if (_refreshing != true && _data == null) {
      return EmptyBlock(
        scope: scope,
        message: translate('anxeb.helpers.document.content.error_loading_file'),
        //TR 'Error cargando archivo',
        icon: Icons.cloud_off,
        actionText: translate('anxeb.helpers.document.content.refresh'),
        //TR 'Refrescar',
        actionCallback: () async => _refresh(),
      );
    }

    if (_isImage) {
      return Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(_data),
            gaplessPlayback: true,
            backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                Color(0xfff0f0f0),
                Color(0xffc3c3c3),
              ],
              stops: [0.0, 1.0],
            )),
            controller: _controller,
            initialScale: widget.initialScale ?? PhotoViewComputedScale.covered,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image,
                  size: 140,
                  color: application.settings.colors.primary.withOpacity(0.2),
                ),
              );
            },
            loadingBuilder: (context, event) {
              return _getLoading();
            },
          ),
          _getTag(),
        ],
      );
    } else if (_pdfFileAlt != null) {
      return Stack(
        children: [
          Container(
            child: _pdfFileAlt,
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                '$_currentPage / $_pages',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
              ),
            ),
          ),
          _getTag(),
        ],
      );
    } else {
      return EmptyBlock(
        scope: scope,
        message: translate('anxeb.helpers.document.content.error_previewing_file'),
        //TR 'Archivo no puede ser visualizado',
        icon: Icons.insert_drive_file_sharp,
        actionText: translate('anxeb.helpers.document.content.refresh'),
        //TR 'Refrescar'
        actionCallback: () async => _refresh(),
      );
    }
  }

  Widget _getTag() {
    if (widget.tag == null) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(scope.application.settings.dialogs.dialogRadius ?? 20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        margin: EdgeInsets.only(bottom: 10),
        child: Text(
          widget.tag,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 22),
        ),
      ),
    );
  }

  Widget _getLoading() {
    var length = window.horizontal(0.16);
    return Center(
      child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(scope.application.settings.colors.primary),
        ),
        height: length,
        width: length,
      ),
    );
  }

  void _share() {
    var $title = widget.file.title;
    var $msg = '${translate('anxeb.helpers.document.dialog.shared_file')}\n\n${$title}'; //TR Archivo Compartido
    var $mime = _isPdf ? 'application/pdf' : 'image/${widget.file.extension}';
    var $extension = _isPdf ? '.pdf' : '.${widget.file.extension}';
    var haveExt = Path.extension(_data.path)?.isNotEmpty == true;
    String newFileName = Path.join(Path.dirname(_data.path), $title + (haveExt ? '' : $extension));
    _data.copy(newFileName);

    final RenderBox box = scope.context.findRenderObject();
    if (_data != null) {
      Share.shareFiles([newFileName], mimeTypes: [$mime], text: $msg, subject: $title, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      _fetchFileData((data) {
        Share.shareFiles([newFileName], mimeTypes: [$mime], text: $msg, subject: $title, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      });
    }
  }

  void _launch({bool download}) async {
    var option = download == true ? 'download' : 'open';
    var url = '${widget.launchUrl}${widget.file.url}/$option';

    if (await Launcher.canLaunchUrl(Uri.parse(url))) {
      await Launcher.launchUrl(Uri.parse(url));
    } else {
      scope.alerts.error(translate('anxeb.helpers.document.dialog.error_launching_file')).show(); //TR Error abriendo archivo
    }
  }

  void _download() {
    _launch(download: true);
  }

  Future<File> _fetchFileData([Function(File data) callback]) async {
    try {
      var data = await _fetch(silent: true);
      if (data != null && callback != null) {
        callback(data);
      }
      return data;
    } catch (err) {
      scope.alerts.error(err).show();
    }
    return null;
  }

  Future<File> _fetch({bool silent}) async {
    var controller = DialogProcessController();
    scope.dialogs.progress(translate('anxeb.helpers.document.dialog.downloading_file'), icon: Icons.file_download, controller: controller, isDownload: true).show(); //TR 'Descargando Archivo'
    var cacheDirectory = await getTemporaryDirectory();

    var cancelToken = CancelToken();
    controller.onCanceled(() {
      cancelToken.cancel();
    });

    var $name = widget.title;
    var $filePath = '${cacheDirectory.path}/${$name}';
    var $url = widget.file.useFullUrl ? '${widget.file.url}' : '${widget.file.url}/open';

    try {
      await scope.api.download(
        $url,
        location: $filePath,
        progress: (count, total) {
          controller.update(total: total.toDouble(), value: count.toDouble());
        },
        cancelToken: cancelToken,
      );
      if (silent == true) {
        controller.success(silent: true);
      } else {
        await controller.success();
      }
      return File($filePath);
    } catch (err) {
      controller.failed(message: err.toString());
      scope.alerts.error(err).show();
    }
    return null;
  }

  Future _refresh() async {
    rasterize(() {
      _data = null;
      _pdfFileAlt = null;
      _controllerAlt = Completer<PDFViewController>();
      _refreshing = true;
    });
    await Future.delayed(Duration(milliseconds: 500));

    try {
      if (widget.file.path != null) {
        rasterize(() {
          _data = File(widget.file.path);
        });
      } else {
        _data = await _fetch(
          silent: true,
        );
      }

      if (_data == null) {
        return;
      }

      if (_isPdf) {
        rasterize(() async {
          _pdfFileAlt = PDFView(
            filePath: _data.path,
            fitEachPage: true,
            fitPolicy: FitPolicy.WIDTH,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: false,
            preventLinkNavigation: true,
            pageSnap: false,
            onRender: (_pages) {
              setState(() {
                _pages = _pages;
              });
            },
            onError: (error) {
              scope.alerts.error(error).show();
            },
            onPageError: (page, error) {
              scope.alerts.error(error).show();
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controllerAlt.complete(pdfViewController);
            },
            onPageChanged: (int page, int total) {
              setState(() {
                _currentPage = (page + 1);
                _pages = total;
              });
            },
          );
        });
      }
    } catch (err) {
      scope.alerts.error(err).show();
    }

    rasterize(() {
      _refreshing = false;
    });
  }

  Future _removeFile() async {
    var result = await scope.dialogs.confirm(translate('anxeb.helpers.document.dialog.delete_confirmation')).show(); //TR ¿Estás seguro que quieres eliminar este archivo?
    if (result) {
      try {
        await scope.busy();
        await scope.api.delete(widget.file.url);
        await widget.updated?.call(null);
        pop(null, force: true);
      } catch (err) {
        scope.alerts.error(err).show();
      } finally {
        await scope.idle();
      }
    }
  }

  Future _changeTitle() async {
    var title = await scope.dialogs
        .prompt(
          translate('anxeb.helpers.document.dialog.new_title'), //TR 'Título Nuevo'
          hint: translate('anxeb.helpers.document.dialog.title'), //TR 'Título'
          type: TextInputFieldType.text,
          value: widget.file.title,
          icon: Icons.text_fields,
        )
        .show();

    if (title != null && title != widget.file.title) {
      rasterize(() {
        widget.file.title = title;
      });
      try {
        await scope.busy();
        await scope.api.post(widget.file.url, {
          'file': {
            'id': widget.file.id,
            'title': widget.file.title,
          }
        });
        await widget.updated?.call(widget.file);
      } catch (err) {
        scope.alerts.error(err).show();
      } finally {
        await scope.idle();
      }
    }
  }

  bool get _isImage => widget.file.isImage;

  bool get _isPdf => widget.file.extension == 'pdf';
}
