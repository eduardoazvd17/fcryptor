import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

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
        //TODO: saveFile don't work for web.
        //TODO: Need to create download feature for web.
        return null;
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
