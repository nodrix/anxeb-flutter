import 'package:flutter/material.dart';
import '../middleware/scope.dart';
import '../parts/panels/menu.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:ionicons/ionicons.dart';

class Dialogs {
  Future<bool> shouldUseCamera(Scope scope, {bool useDocumentLabel}) async {
    var option;
    await scope.dialogs.panel(
      items: [
        PanelMenuItem(
          actions: [
            PanelMenuAction(
              label: () => useDocumentLabel == true ? translate('anxeb.utils.dialogs.browse_document') : translate('anxeb.utils.dialogs.browse_image'),
              //TR 'Buscar\nImagen',
              textScale: 0.9,
              icon: () => useDocumentLabel == true ? CommunityMaterialIcons.file : Icons.image,
              fillColor: () => scope.application.settings.colors.secudary,
              onPressed: () {
                option = 'browse';
              },
            ),
            PanelMenuAction(
              label: () => translate('anxeb.utils.dialogs.use_camera'),
              //TR 'Usar\nCámara',
              textScale: 0.9,
              icon: () => Ionicons.camera,
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
    if (option != null) {
      return option == 'camera';
    }
    return null;
  }
}
