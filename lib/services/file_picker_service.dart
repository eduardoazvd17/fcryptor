import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class FilePickerService {
  FilePickerService._();

  static Future<File?> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      return result != null ? File(result.files.single.path!) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String initialDirectory,
  }) async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrl(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return '${html.window.navigator.userAgent}/Downloads/$fileName';
      } else {
        return await FilePicker.platform.saveFile(
          fileName: fileName,
          bytes: bytes,
          initialDirectory: initialDirectory,
        );
      }
    } catch (_) {
      return null;
    }
  }
}
