import 'dart:io';

import 'package:fcryptor/services/file_encryption_service.dart';
import 'package:fcryptor/services/file_picker_service.dart';
import 'package:fcryptor/utils/constants.dart';
import 'package:fcryptor/utils/file_extension.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _keyController;
  bool _isLoading = false;
  bool _hasKey = false;
  String? _result;
  File? _selectedFile;

  bool get _isStartButtonEnabled =>
      !_isLoading && _selectedFile != null && _hasKey;

  String get _status {
    if (_isLoading) return 'Loading...';
    if (_selectedFile == null) return 'Choose file to encrypt/decrypt...';
    if (!_hasKey) return 'Enter the encryption password...';
    return _result ?? '';
  }

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    _resetState();
    final file = await FilePickerService.pickFile();
    setState(() {
      _selectedFile = file;
      _isLoading = false;
    });
  }

  Future<void> _openMyWebsite() async {
    const url = 'https://eduardoazevedo.com';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _start() async {
    _resetState();
    final result = await FileEncryptionService.start(
      _selectedFile!,
      _keyController.text,
    );
    setState(() {
      _result = result != null
          ? 'Success! File saved as: ${result.name}'
          : 'An error occurred in the process, please try again.';
      _isLoading = false;
    });
  }

  void _resetState() {
    setState(() {
      _result = null;
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildHeader(context),
                        _buildFileSelector(context),
                        _buildPasswordInput(),
                        _buildActionButton(),
                        _buildStatus(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 0),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFileSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: _isLoading ? null : _selectFile,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload_outlined,
                color:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
                size: 120,
              ),
              Text(
                _selectedFile?.path.split('/').last ?? 'No file selected',
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _selectedFile == null ? 'Choose file' : 'Change file',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isLoading
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
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
            onChanged: (text) {
              setState(() {
                _result = null;
                _hasKey = text.isNotEmpty;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return TextButton.icon(
      onPressed: _isStartButtonEnabled ? _start : null,
      icon: Icon(
        _selectedFile?.path.endsWith(kEncryptedFileExtension) == true
            ? Icons.lock_open_outlined
            : Icons.lock,
      ),
      label: Text(
        _selectedFile?.path.endsWith(kEncryptedFileExtension) == true
            ? 'Decrypt file'
            : 'Encrypt file',
      ),
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _isLoading ? null : 0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
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
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
