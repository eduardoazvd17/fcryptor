import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:fcryptor/services/file_picker_service.dart';
import 'package:fcryptor/utils/constants.dart';
import 'package:fcryptor/utils/file_extension.dart';

class FileEncryptionService {
  FileEncryptionService._();

  static Future<File?> start(
    File file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    if (file.path.endsWith(kEncryptedFileExtension)) {
      return await _decrypt(file, key, paddingChar: paddingChar);
    } else {
      return await _encrypt(file, key, paddingChar: paddingChar);
    }
  }

  static Future<File?> _encrypt(
    File file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    try {
      final normalizedKey = _normalizeKey(key, paddingChar);
      final fileBytes = await file.readAsBytes();
      final aesKey = Key.fromUtf8(normalizedKey);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

      final encryptedFilePath = await FilePickerService.saveFile(
        fileName: file.name + kEncryptedFileExtension,
        bytes: Uint8List.fromList(iv.bytes + encrypted.bytes),
        initialDirectory: file.parent.path,
      );
      return await File(encryptedFilePath!)
          .writeAsBytes(iv.bytes + encrypted.bytes);
    } catch (_) {
      return null;
    }
  }

  static Future<File?> _decrypt(
    File file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    try {
      final normalizedKey = _normalizeKey(key, paddingChar);
      final fileBytes = await file.readAsBytes();
      final iv = IV(fileBytes.sublist(0, 16));
      final encryptedData = fileBytes.sublist(16);
      final aesKey = Key.fromUtf8(normalizedKey);
      final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
      final decrypted = encrypter.decryptBytes(
        Encrypted(encryptedData),
        iv: iv,
      );

      final originalFilePath = await FilePickerService.saveFile(
        fileName: file.name.replaceAll(kEncryptedFileExtension, ''),
        bytes: Uint8List.fromList(decrypted),
        initialDirectory: file.parent.path,
      );
      return File(originalFilePath!).writeAsBytes(decrypted);
    } catch (_) {
      return null;
    }
  }

  static String _normalizeKey(String key, String paddingChar) {
    if (key.length > 32) {
      return key.substring(0, 32);
    } else if (key.length < 32) {
      return key.padRight(32, paddingChar);
    }
    return key;
  }
}
