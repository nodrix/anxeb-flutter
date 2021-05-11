import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class GlobalIcons {
  IconData getFileColor(String extension) {
    final obj = _mimeTypes[extension];
    if (obj != null) {
      return obj['color'];
    }
    return FlutterIcons.file_alt_faw5;
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
      icon: FlutterIcons.file_alt_faw5s,
      caption: extension.toUpperCase(),
      color: Colors.black,
    );
  }

  final _mimeTypes = {
    'doc': {
      'icon': FlutterIcons.file_word_faw5s,
      'caption': 'DOC',
      'color': const Color(0xff2A5399),
    },
    'xls': {
      'icon': FlutterIcons.file_excel_faw5s,
      'caption': 'XLS',
      'color': const Color(0xff207245),
    },
    'ppt': {
      'icon': FlutterIcons.file_powerpoint_faw5s,
      'caption': 'PPT',
      'color': const Color(0xffD4522F),
    },
    'abw': {
      'icon': FlutterIcons.file_alt_faw5s,
      'caption': 'ABW',
      'color': const Color(0xff6f6f6f),
    },
    'avi': {
      'icon': FlutterIcons.file_video_faw5s,
      'caption': 'AVI',
      'color': const Color(0xffff0909),
    },
    'bin': {
      'icon': FlutterIcons.file_code_faw5s,
      'caption': 'BIN',
      'color': const Color(0xff313131),
    },
    'xml': {
      'icon': FlutterIcons.file_code_faw5s,
      'caption': 'XML',
      'color': const Color(0xff364355),
    },
    'bz': {
      'icon': FlutterIcons.file_archive_faw5s,
      'caption': 'BZ',
      'color': const Color(0xff8e7f5b),
    },
    'gz': {
      'icon': FlutterIcons.file_archive_faw5s,
      'caption': 'GZ',
      'color': const Color(0xff8e7f5b),
    },
    'ico': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'ICO',
      'color': const Color(0xffb35e00),
    },
    'jar': {
      'icon': FlutterIcons.file_archive_faw5s,
      'caption': 'JAR',
      'color': const Color(0xff8e7f5b),
    },
    'jpg': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'JPEG',
      'color': const Color(0xffe08c32),
    },
    'js': {
      'icon': FlutterIcons.file_code_faw5s,
      'caption': 'JS',
      'color': const Color(0xffd71e8d),
    },
    'json': {
      'icon': FlutterIcons.file_code_faw5s,
      'caption': 'JSON',
      'color': const Color(0xff2f2f2f),
    },
    'mp3': {
      'icon': FlutterIcons.file_audio_faw5s,
      'caption': 'MP3',
      'color': const Color(0xff2a1da0),
    },
    'mpeg': {
      'icon': FlutterIcons.file_video_faw5s,
      'caption': 'MPEG',
      'color': const Color(0xffff3636),
    },
    'rar': {
      'icon': FlutterIcons.file_archive_faw5s,
      'caption': 'RAR',
      'color': const Color(0xff158a9c),
    },
    'svg': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'SVG',
      'color': const Color(0xff158a9c),
    },
    'csv': {
      'icon': FlutterIcons.file_csv_faw5s,
      'caption': 'CSV',
      'color': const Color(0xff347179),
    },
    'txt': {
      'icon': FlutterIcons.file_alt_faw5s,
      'caption': 'TXT',
      'color': const Color(0xffee718b),
    },
    'pdf': {
      'icon': FlutterIcons.file_pdf_faw5s,
      'caption': 'PDF',
      'color': const Color(0xffB20D02),
    },
    'gif': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'GIF',
      'color': const Color(0xffe08c32),
    },
    'bmp': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'BMP',
      'color': const Color(0xffe08c32),
    },
    'png': {
      'icon': FlutterIcons.file_image_faw5s,
      'caption': 'PNG',
      'color': const Color(0xffe08c32),
    },
    'zip': {
      'icon': FlutterIcons.file_archive_faw5s,
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
