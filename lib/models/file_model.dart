import 'dart:typed_data';

class FileModel {
  final String name;
  final String path;
  final Uint8List bytes;

  String get directory =>
      path.split('/').take(path.split('/').length - 1).join('/');

  String get shortName {
    final splittedName = this.name.split('.');
    final extension = splittedName.last;
    final name = splittedName.join('.').replaceAll('.$extension', '');

    if (name.length > 15) {
      return '${name.substring(0, 8)}...${name.substring(name.length - 7)}.$extension';
    }
    return this.name;
  }

  FileModel({
    required this.name,
    required this.path,
    required this.bytes,
  });
}
