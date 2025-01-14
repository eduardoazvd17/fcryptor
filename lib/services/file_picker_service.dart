import 'dart:io';

import 'package:fcryptor/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

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

  static Future<String?> selectDirectoryFrom(
    String initialDirectory,
    String suggestedName,
  ) async {
    try {
      final result = await getSaveLocation(
        initialDirectory: initialDirectory,
        suggestedName: suggestedName,
      );
      return result?.path;
    } catch (_) {
      return null;
    }
  }
}
