import 'dart:io';

import 'package:fcryptor/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import '../models/file_model.dart';

class FilePickerService {
  FilePickerService._();

  static Future<Result<FileModel, String>> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.single;
        final bytes = kIsWeb
            ? (file.bytes ?? Uint8List(0))
            : File(file.path!).readAsBytesSync();

        return Success(
          FileModel(
            name: file.name,
            path: kIsWeb ? '' : file.path!,
            bytes: bytes,
          ),
        );
      }
      return Error('File not selected');
    } catch (_) {
      return Error('Error selecting file');
    }
  }

  static Future<Result<FileModel, String>> saveFile({
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
          FileModel(
            name: fileName,
            path: '${html.window.navigator.userAgent}/Downloads/$fileName',
            bytes: bytes,
          ),
        );
      } else {
        final result = await FilePicker.platform.saveFile(
          fileName: fileName,
          bytes: bytes,
          initialDirectory: initialDirectory,
        );
        return Success(
          FileModel(name: fileName, path: result!, bytes: bytes),
        );
      }
    } catch (_) {
      return Error('Error saving file');
    }
  }
}
