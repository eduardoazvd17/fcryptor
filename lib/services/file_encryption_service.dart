import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:fcryptor/models/file_model.dart';
import 'package:fcryptor/services/file_picker_service.dart';
import 'package:fcryptor/utils/constants.dart';
import 'package:fcryptor/utils/result.dart';
import 'package:flutter/foundation.dart' hide Key;

class FileEncryptionService {
  FileEncryptionService._();

  static Future<Result<FileModel, String>> start(
    FileModel file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    final encrypter = Encrypter(
      AES(Key.fromUtf8(_normalizeKey(key, paddingChar)), mode: AESMode.cbc),
    );

    if (file.name.endsWith(kEncryptedFileExtension)) {
      return await _decrypt(encrypter, file, key, paddingChar: paddingChar);
    } else {
      return await _encrypt(encrypter, file, key, paddingChar: paddingChar);
    }
  }

  static Future<Result<FileModel, String>> _encrypt(
    Encrypter encrypter,
    FileModel file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    try {
      if (file.bytes.isEmpty) {
        return Error('File is empty');
      }

      final iv = IV.fromLength(16);
      final encryptedFile = encrypter.encryptBytes(file.bytes, iv: iv);

      return await _saveAndReturnNewFile(
        file,
        Uint8List.fromList(iv.bytes + encryptedFile.bytes),
      );
    } catch (_) {
      return Error('Error encrypting file');
    }
  }

  static Future<Result<FileModel, String>> _decrypt(
    Encrypter encrypter,
    FileModel file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    try {
      if (file.bytes.isEmpty) {
        return Error('File is empty');
      }

      final iv = IV(file.bytes.sublist(0, 16));
      final decryptedFileBytes = encrypter.decryptBytes(
        Encrypted(file.bytes.sublist(16)),
        iv: iv,
      );

      return await _saveAndReturnNewFile(
        file,
        Uint8List.fromList(decryptedFileBytes),
      );
    } on ArgumentError {
      return Error('Incorrect password or corrupted file');
    } catch (_) {
      return Error('Error decrypting file');
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

  static Future<Result<FileModel, String>> _saveAndReturnNewFile(
    FileModel file,
    Uint8List bytes,
  ) async {
    final saveResult = await FilePickerService.saveFile(
      fileName: file.name.endsWith(kEncryptedFileExtension)
          ? file.name.replaceAll(kEncryptedFileExtension, '')
          : file.name + kEncryptedFileExtension,
      bytes: bytes,
      initialDirectory: file.directory,
    );

    return saveResult.fold(
      onSuccess: (success) async {
        if (!kIsWeb) {
          final file = File(success.path);
          if (!file.existsSync()) {
            await file.writeAsBytes(success.bytes);
          }
        }
        return Success(success);
      },
      onError: (error) => Error(error),
    );
  }
}
