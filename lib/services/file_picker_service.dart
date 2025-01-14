import 'dart:io';

import 'package:file_picker/file_picker.dart';

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
}
