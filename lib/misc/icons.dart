import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

export 'package:fluttericon/brandico_icons.dart';
export 'package:fluttericon/elusive_icons.dart';
export 'package:fluttericon/entypo_icons.dart';
export 'package:fluttericon/font_awesome5_icons.dart';
export 'package:fluttericon/font_awesome_icons.dart';
export 'package:fluttericon/fontelico_icons.dart';
export 'package:fluttericon/iconic_icons.dart';
export 'package:fluttericon/linearicons_free_icons.dart';
export 'package:fluttericon/linecons_icons.dart';
export 'package:fluttericon/maki_icons.dart';
export 'package:fluttericon/meteocons_icons.dart';
export 'package:fluttericon/mfg_labs_icons.dart';
export 'package:fluttericon/modern_pictograms_icons.dart';
export 'package:fluttericon/octicons_icons.dart';
export 'package:fluttericon/rpg_awesome_icons.dart';
export 'package:fluttericon/typicons_icons.dart';
export 'package:fluttericon/web_symbols_icons.dart';
export 'package:fluttericon/zocial_icons.dart';
export 'package:community_material_icon/community_material_icon.dart';
export 'package:ionicons/ionicons.dart';

class GlobalIcons {
  IconData getFileColor(String extension) {
    final obj = _mimeTypes[extension];
    if (obj != null) {
      return obj['color'];
    }
    return FontAwesome5.file_alt;
  }

  IconFileMeta getFileMeta(String extension) {
    if (extension == null){
      return null;
    }
    final obj = _mimeTypes[extension];
    if (obj != null) {
      return IconFileMeta(
        icon: obj['icon'],
        caption: obj['caption'],
        color: obj['color'],
        image: obj['image'],
      );
    }
    return IconFileMeta(
      icon: FontAwesome5.file_alt,
      caption: extension.toUpperCase(),
      color: Colors.black,
    );
  }

  final _mimeTypes = {
    'doc': {
      'icon': FontAwesome5.file_word,
      'caption': 'DOC',
      'color': const Color(0xff2A5399),
      'image': false,
    },
    'xls': {
      'icon': FontAwesome5.file_excel,
      'caption': 'XLS',
      'color': const Color(0xff207245),
      'image': false,
    },
    'ppt': {
      'icon': FontAwesome5.file_powerpoint,
      'caption': 'PPT',
      'color': const Color(0xffD4522F),
      'image': false,
    },
    'abw': {
      'icon': FontAwesome5.file_alt,
      'caption': 'ABW',
      'color': const Color(0xff6f6f6f),
      'image': false,
    },
    'avi': {
      'icon': FontAwesome5.file_video,
      'caption': 'AVI',
      'color': const Color(0xffff0909),
      'image': false,
    },
    'bin': {
      'icon': FontAwesome5.file_code,
      'caption': 'BIN',
      'color': const Color(0xff313131),
      'image': false,
    },
    'xml': {
      'icon': FontAwesome5.file_code,
      'caption': 'XML',
      'color': const Color(0xff364355),
      'image': false,
    },
    'bz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'BZ',
      'color': const Color(0xff8e7f5b),
      'image': false,
    },
    'gz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'GZ',
      'color': const Color(0xff8e7f5b),
      'image': false,
    },
    'ico': {
      'icon': FontAwesome5.file_image,
      'caption': 'ICO',
      'color': const Color(0xffb35e00),
      'image': false,
    },
    'jar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'JAR',
      'color': const Color(0xff8e7f5b),
      'image': false,
    },
    'jpg': {
      'icon': FontAwesome5.file_image,
      'caption': 'JPEG',
      'color': const Color(0xffe08c32),
      'image': true,
    },
    'js': {
      'icon': FontAwesome5.file_code,
      'caption': 'JS',
      'color': const Color(0xffd71e8d),
      'image': false,
    },
    'json': {
      'icon': FontAwesome5.file_code,
      'caption': 'JSON',
      'color': const Color(0xff2f2f2f),
      'image': false,
    },
    'mp3': {
      'icon': FontAwesome5.file_audio,
      'caption': 'MP3',
      'color': const Color(0xff2a1da0),
      'image': false,
    },
    'mpeg': {
      'icon': FontAwesome5.file_video,
      'caption': 'MPEG',
      'color': const Color(0xffff3636),
      'image': false,
    },
    'rar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'RAR',
      'color': const Color(0xff158a9c),
      'image': false,
    },
    'svg': {
      'icon': FontAwesome5.file_image,
      'caption': 'SVG',
      'color': const Color(0xff158a9c),
      'image': false,
    },
    'csv': {
      'icon': FontAwesome5.file_csv,
      'caption': 'CSV',
      'color': const Color(0xff347179),
      'image': false,
    },
    'txt': {
      'icon': FontAwesome5.file_alt,
      'caption': 'TXT',
      'color': const Color(0xffee718b),
      'image': false,
    },
    'pdf': {
      'icon': FontAwesome5.file_pdf,
      'caption': 'PDF',
      'color': const Color(0xffB20D02),
      'image': false,
    },
    'gif': {
      'icon': FontAwesome5.file_image,
      'caption': 'GIF',
      'color': const Color(0xffe08c32),
      'image': true,
    },
    'bmp': {
      'icon': FontAwesome5.file_image,
      'caption': 'BMP',
      'color': const Color(0xffe08c32),
      'image': true,
    },
    'png': {
      'icon': FontAwesome5.file_image,
      'caption': 'PNG',
      'color': const Color(0xffe08c32),
      'image': true,
    },
    'zip': {
      'icon': FontAwesome5.file_archive,
      'caption': 'ZIP',
      'color': const Color(0xff8e7f5b),
      'image': false,
    },
  };
}

class IconFileMeta {
  final IconData icon;
  final String caption;
  final Color color;
  final bool image;

  IconFileMeta({this.icon, this.caption, this.color, this.image = false});
}
