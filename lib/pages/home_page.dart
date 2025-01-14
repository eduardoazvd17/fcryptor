import 'dart:io';

import 'package:fcryptor/services/file_encryption_service.dart';
import 'package:fcryptor/services/file_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _keyController;
  String? _result;
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    _keyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    setState(() {
      _result = null;
      _isLoading = true;
    });
    final file = await FilePickerService.pickFile();
    setState(() {
      if (file != null) _selectedFile = file;
      _isLoading = false;
    });
  }

  Future<void> _openMyWebsite() async {
    final uri = Uri.parse('https://eduardoazevedo.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _start() async {
    setState(() {
      _result = null;
      _isLoading = true;
    });
    final String? result = await FileEncryptionService.start(
      _selectedFile!,
      _keyController.text,
    );
    setState(() {
      if (result != null) {
        _result = 'Success! File saved as: ${result.split('/').last}';
      } else {
        _result = 'An error occurred in the process, please try again.';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'FCryptor',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'A open source file encryption tool',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: _isLoading ? null : _selectFile,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Icon(
                                        Icons.file_upload_outlined,
                                        color: _isLoading
                                            ? Colors.grey
                                            : Theme.of(context).primaryColor,
                                        size: 120,
                                      ),
                                      Text(
                                        _selectedFile?.path.split('/').last ??
                                            'No file selected',
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          _selectedFile == null
                                              ? 'Choose file'
                                              : 'Change file',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _isLoading
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Password'),
                                const Text(
                                  'Set your password to encrypt or decrypt files',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: TextField(
                                    maxLength: 32,
                                    enabled: !_isLoading,
                                    controller: _keyController,
                                    obscureText: true,
                                    obscuringCharacter: '•',
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: _isLoading
                                        ? null
                                        : (_) {
                                            setState(() => _result = null);
                                          },
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _isLoading || _selectedFile == null
                                  ? null
                                  : _start,
                              icon: Icon(
                                _selectedFile?.path.endsWith('.fcrypto') == true
                                    ? Icons.lock_open_outlined
                                    : Icons.lock,
                              ),
                              label: Text(
                                _selectedFile?.path.endsWith('.fcrypto') == true
                                    ? 'Decrypt file'
                                    : 'Encrypt file',
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 25, bottom: 5),
                              child: LinearProgressIndicator(
                                value: _isLoading ? null : 0,
                              ),
                            ),
                            Text(
                              _isLoading
                                  ? 'Loading...'
                                  : _result ?? 'Waiting...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _openMyWebsite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Made with Flutter by Eduardo Azevedo',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'eduardoazevedo.com',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.primary,
                              decorationColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
