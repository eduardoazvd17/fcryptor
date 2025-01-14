import 'dart:io';

extension FileExtension on File {
  String get name =>
      path.replaceAll(parent.path, '').replaceAll('/', '').replaceAll('\\', '');
}
