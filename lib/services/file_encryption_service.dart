import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fcryptor/models/file_model.dart';
import 'package:fcryptor/services/file_picker_service.dart';
import 'package:fcryptor/utils/constants.dart';
import 'package:fcryptor/utils/result.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:pointycastle/export.dart';

class FileEncryptionService {
  FileEncryptionService._();

  static Future<Result<FileModel, String>> start(
    FileModel file,
    String key, {
    String paddingChar = kDefaultPaddingChar,
  }) async {
    final normalizedKey = _normalizeKey(key, paddingChar);

    if (file.name.endsWith(kEncryptedFileExtension)) {
      return await _decrypt(file, normalizedKey);
    } else {
      return await _encrypt(file, normalizedKey);
    }
  }

  static Future<Result<FileModel, String>> _encrypt(
    FileModel file,
    String normalizedKey,
  ) async {
    try {
      if (file.bytes.isEmpty) {
        return Error('File is empty');
      }

      final salt = _generateRandomBytes(8);
      final (key, iv) = _deriveKeyAndIV(normalizedKey, salt);
      final cipher = CBCBlockCipher(AESEngine())
        ..init(
          true,
          ParametersWithIV(
            KeyParameter(Uint8List.fromList(key)),
            Uint8List.fromList(iv),
          ),
        );

      final paddedData = _addPKCS7Padding(file.bytes);
      final encrypted = _processBlocks(cipher, paddedData);
      final output = Uint8List(8 + salt.length + encrypted.length);
      output.setAll(0, utf8.encode('Salted__'));
      output.setAll(8, salt);
      output.setAll(16, encrypted);

      return await _saveAndReturnNewFile(file, output);
    } catch (e) {
      return Error('Error encrypting file');
    }
  }

  static Future<Result<FileModel, String>> _decrypt(
    FileModel file,
    String normalizedKey,
  ) async {
    try {
      if (file.bytes.isEmpty) {
        return Error('File is empty');
      }

      if (file.bytes.length < 16 ||
          String.fromCharCodes(file.bytes.sublist(0, 8)) != 'Salted__') {
        return Error('Invalid file format');
      }

      final salt = file.bytes.sublist(8, 16);
      final encrypted = file.bytes.sublist(16);
      final (key, iv) = _deriveKeyAndIV(normalizedKey, salt);
      final cipher = CBCBlockCipher(AESEngine())
        ..init(
          false,
          ParametersWithIV(
            KeyParameter(Uint8List.fromList(key)),
            Uint8List.fromList(iv),
          ),
        );

      final decrypted = _processBlocks(cipher, encrypted);
      final unpadded = _removePKCS7Padding(decrypted);

      return await _saveAndReturnNewFile(file, Uint8List.fromList(unpadded));
    } on FormatException catch (_) {
      return Error('Incorrect password or file corrupted');
    } catch (e) {
      return Error('Error decrypting file');
    }
  }

  static (List<int>, List<int>) _deriveKeyAndIV(
    String password,
    List<int> salt,
  ) {
    final generator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    generator.init(Pbkdf2Parameters(Uint8List.fromList(salt), 10000, 48));
    final keyIvBytes = generator.process(
      Uint8List.fromList(utf8.encode(password)),
    );

    return (keyIvBytes.sublist(0, 32), keyIvBytes.sublist(32, 48));
  }

  static List<int> _processBlocks(BlockCipher cipher, List<int> input) {
    final output = Uint8List(input.length);
    for (var offset = 0; offset < input.length; offset += 16) {
      cipher.processBlock(
        Uint8List.fromList(input.sublist(offset, offset + 16)),
        0,
        output,
        offset,
      );
    }
    return output;
  }

  static List<int> _addPKCS7Padding(List<int> data) {
    final padLength = 16 - (data.length % 16);
    return [...data, ...List.filled(padLength, padLength)];
  }

  static List<int> _removePKCS7Padding(List<int> data) {
    final padLength = data.last;
    if (padLength < 1 || padLength > 16) {
      throw FormatException('Invalid padding');
    }
    return data.sublist(0, data.length - padLength);
  }

  static List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
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
