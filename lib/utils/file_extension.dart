import 'dart:io';

extension FileExtension on File {
  String get name =>
      path.replaceAll(parent.path, '').replaceAll('/', '').replaceAll('\\', '');

  String get shortName {
    final splittedName = this.name.split('.');
    final extension = splittedName.last;
    final name = splittedName.join('.').replaceAll('.$extension', '');

    if (name.length > 15) {
      return '${name.substring(0, 8)}...${name.substring(name.length - 7)}.$extension';
    }
    return this.name;
  }
}
