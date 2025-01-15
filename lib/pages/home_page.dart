import 'dart:io';

import 'package:fcryptor/services/file_encryption_service.dart';
import 'package:fcryptor/utils/constants.dart';
import 'package:fcryptor/utils/file_extension.dart';
import 'package:fcryptor/widgets/footer_widget.dart';
import 'package:fcryptor/widgets/header_widget.dart';
import 'package:fcryptor/widgets/rounded_icon_widget.dart';
import 'package:flutter/material.dart';

import '../services/file_picker_service.dart';
import '../widgets/content_container_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _passwordController;

  File? _file;
  String? _password;
  bool _isLoading = false;
  File? _resultFile;

  bool get _isDecrypting =>
      _file?.name.endsWith(kEncryptedFileExtension) == true;

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    setState(() => _isLoading = true);
    final file = await FilePickerService.pickFile();
    setState(() {
      if (file != null) _file = file;
      _isLoading = false;
    });
  }

  void _reset() {
    _passwordController.clear();
    setState(() {
      _file = null;
      _password = null;
      _isLoading = false;
      _resultFile = null;
    });
  }

  Future<void> _start() async {
    setState(() => _isLoading = true);
    final result = await FileEncryptionService.start(_file!, _password!);
    setState(() {
      _resultFile = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    switchInCurve: Curves.ease,
                    switchOutCurve: Curves.ease,
                    duration: const Duration(seconds: 1),
                    reverseDuration: const Duration(seconds: 1),
                    child: _file == null
                        ? _buildFileSelectorStep()
                        : _resultFile == null
                            ? _buildPasswordStep()
                            : _buildResultStep(),
                  ),
                ],
              ),
            ),
            FooterWidget(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectorStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: _isLoading ? null : _selectFile,
        borderRadius: BorderRadius.circular(16),
        child: ContentContainerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundedIconWidget(
                icon: Icons.upload_file_outlined,
                color:
                    _isLoading ? Colors.grey : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Select a file',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Select a file to encrypt or decrypt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isLoading
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ContentContainerWidget(
            child: Column(
              children: [
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedIconWidget(
                      icon: _isDecrypting
                          ? Icons.lock_open_outlined
                          : Icons.lock_outline,
                      color: _isLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    Flexible(
                      child: Text(
                        _file!.shortName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passwordController,
                  maxLength: 32,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText:
                        ' ${_isDecrypting ? 'Decryption' : 'Encryption'} password ',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    helperText: 'Minimum 6 characters',
                    helperStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onChanged: (value) => setState(() {
                    _password = value.length < 6 ? null : value;
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : _reset,
                      icon: Icon(Icons.keyboard_arrow_left),
                      label: Text('Change file'),
                    ),
                    TextButton.icon(
                      onPressed:
                          (_isLoading || _password == null) ? null : _start,
                      icon: Icon(
                        _isDecrypting
                            ? Icons.lock_open_outlined
                            : Icons.lock_outline,
                      ),
                      label: Text(
                        _isDecrypting ? 'Decrypt' : 'Encrypt',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ContentContainerWidget(
        child: Column(
          children: [
            RoundedIconWidget(
              icon: _resultFile != null ? Icons.check : Icons.error,
              color: _resultFile != null ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _resultFile != null
                  ? 'Successfully ${_isDecrypting ? 'decrypted' : 'encrypted'} file.'
                  : 'An error occurred on ${_isDecrypting ? 'decrypting' : 'encrypting'} file process, please try again.',
            ),
            if (_resultFile != null) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_present_outlined),
                      Flexible(
                        child: Text(
                          _resultFile!.shortName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _reset,
              icon: Icon(Icons.refresh),
              label: Text('Select another file'),
            ),
          ],
        ),
      ),
    );
  }
}
