import 'dart:io';

import 'package:fcryptor/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class FilePickerService {
  FilePickerService._();

  static Future<Result<File, String>> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        return Success(File(result.files.single.path!));
      }
      return Error('File not selected');
    } catch (_) {
      return Error('Error selecting file');
    }
  }

  static Future<Result<String, String>> saveFile({
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
        return Success(
          '${html.window.navigator.userAgent}/Downloads/$fileName',
        );
      } else {
        final result = await FilePicker.platform.saveFile(
          fileName: fileName,
          bytes: bytes,
          initialDirectory: initialDirectory,
        );
        return Success(result!);
      }
    } catch (_) {
      return Error('Error saving file');
    }
  }
}
