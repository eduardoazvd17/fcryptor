// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;

const _kDefaultPaddingChar = 'x';

class FileEncryptionService {
  FileEncryptionService._();

  static Future<String?> start(
    File file,
    String key, {
    String paddingChar = _kDefaultPaddingChar,
  }) async {
    if (file.path.endsWith('.fcrypto')) {
      return await _decrypt(file, key, paddingChar: paddingChar);
    } else {
      return await _encrypt(file, key, paddingChar: paddingChar);
    }
  }

  static Future<String?> _encrypt(
    File file,
    String key, {
    String paddingChar = _kDefaultPaddingChar,
  }) async {
    try {
      final normalizedKey = _normalizeKey(key, paddingChar);
      final fileBytes = await file.readAsBytes();
      final aesKey = Key.fromUtf8(normalizedKey);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      final encryptedFilePath = path.setExtension(file.path, '.fcrypto');
      await File(encryptedFilePath).writeAsBytes(iv.bytes + encrypted.bytes);
      return encryptedFilePath;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _decrypt(
    File file,
    String key, {
    String paddingChar = _kDefaultPaddingChar,
  }) async {
    try {
      final normalizedKey = _normalizeKey(key, paddingChar);
      final fileBytes = await file.readAsBytes();
      final iv = IV(fileBytes.sublist(0, 16));
      final encryptedData = fileBytes.sublist(16);
      final aesKey = Key.fromUtf8(normalizedKey);
      final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
      final decrypted =
          encrypter.decryptBytes(Encrypted(encryptedData), iv: iv);
      final originalFilePath = path.withoutExtension(file.path);
      await File(originalFilePath).writeAsBytes(decrypted);
      return originalFilePath;
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
