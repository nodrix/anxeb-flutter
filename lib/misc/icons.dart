import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class GlobalIcons {
  IconData getFileColor(String extension) {
    final obj = _mimeTypes[extension];
    if (obj != null) {
      return obj['color'];
    }
    return FontAwesome5.file_alt;
  }

  IconFileMeta getFileMeta(String extension) {
    final obj = _mimeTypes[extension];
    if (obj != null) {
      return IconFileMeta(
        icon: obj['icon'],
        caption: obj['caption'],
        color: obj['color'],
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
    },
    'xls': {
      'icon': FontAwesome5.file_excel,
      'caption': 'XLS',
      'color': const Color(0xff207245),
    },
    'ppt': {
      'icon': FontAwesome5.file_powerpoint,
      'caption': 'PPT',
      'color': const Color(0xffD4522F),
    },
    'abw': {
      'icon': FontAwesome5.file_alt,
      'caption': 'ABW',
      'color': const Color(0xff6f6f6f),
    },
    'avi': {
      'icon': FontAwesome5.file_video,
      'caption': 'AVI',
      'color': const Color(0xffff0909),
    },
    'bin': {
      'icon': FontAwesome5.file_code,
      'caption': 'BIN',
      'color': const Color(0xff313131),
    },
    'xml': {
      'icon': FontAwesome5.file_code,
      'caption': 'XML',
      'color': const Color(0xff364355),
    },
    'bz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'BZ',
      'color': const Color(0xff8e7f5b),
    },
    'gz': {
      'icon': FontAwesome5.file_archive,
      'caption': 'GZ',
      'color': const Color(0xff8e7f5b),
    },
    'ico': {
      'icon': FontAwesome5.file_image,
      'caption': 'ICO',
      'color': const Color(0xffb35e00),
    },
    'jar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'JAR',
      'color': const Color(0xff8e7f5b),
    },
    'jpg': {
      'icon': FontAwesome5.file_image,
      'caption': 'JPEG',
      'color': const Color(0xffe08c32),
    },
    'js': {
      'icon': FontAwesome5.file_code,
      'caption': 'JS',
      'color': const Color(0xffd71e8d),
    },
    'json': {
      'icon': FontAwesome5.file_code,
      'caption': 'JSON',
      'color': const Color(0xff2f2f2f),
    },
    'mp3': {
      'icon': FontAwesome5.file_audio,
      'caption': 'MP3',
      'color': const Color(0xff2a1da0),
    },
    'mpeg': {
      'icon': FontAwesome5.file_video,
      'caption': 'MPEG',
      'color': const Color(0xffff3636),
    },
    'rar': {
      'icon': FontAwesome5.file_archive,
      'caption': 'RAR',
      'color': const Color(0xff158a9c),
    },
    'svg': {
      'icon': FontAwesome5.file_image,
      'caption': 'SVG',
      'color': const Color(0xff158a9c),
    },
    'csv': {
      'icon': FontAwesome5.file_csv,
      'caption': 'CSV',
      'color': const Color(0xff347179),
    },
    'txt': {
      'icon': FontAwesome5.file_alt,
      'caption': 'TXT',
      'color': const Color(0xffee718b),
    },
    'pdf': {
      'icon': FontAwesome5.file_pdf,
      'caption': 'PDF',
      'color': const Color(0xffB20D02),
    },
    'gif': {
      'icon': FontAwesome5.file_image,
      'caption': 'GIF',
      'color': const Color(0xffe08c32),
    },
    'bmp': {
      'icon': FontAwesome5.file_image,
      'caption': 'BMP',
      'color': const Color(0xffe08c32),
    },
    'png': {
      'icon': FontAwesome5.file_image,
      'caption': 'PNG',
      'color': const Color(0xffe08c32),
    },
    'zip': {
      'icon': FontAwesome5.file_archive,
      'caption': 'ZIP',
      'color': const Color(0xff8e7f5b),
    },
  };
}

class IconFileMeta {
  final IconData icon;
  final String caption;
  final Color color;

  IconFileMeta({this.icon, this.caption, this.color});
}
