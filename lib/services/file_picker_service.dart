import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  FilePickerService._();

  static Future<File?> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) return File(result.files.single.path!);
    return null;
  }
}
