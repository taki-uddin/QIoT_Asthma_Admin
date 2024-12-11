import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class PDFSaver {
  static Future<File?> savePDF(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      return _saveFileWeb(bytes, fileName);
    }

    return null;
  }

  static Future<File?> _saveFileWeb(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    return null;
  }
}
