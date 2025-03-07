import 'package:fcryptor/models/file_model.dart';
import 'package:fcryptor/services/file_encryption_service.dart';
import 'package:fcryptor/utils/constants.dart';
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

  FileModel? _file;
  String? _password;
  bool _isLoading = false;
  FileModel? _resultFile;
  String? _errorMessage;

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
      if (file.value != null) _file = file.value;
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
      _errorMessage = null;
    });
  }

  void _tryAgain() {
    setState(() {
      _errorMessage = null;
      _resultFile = null;
    });
  }

  Future<void> _start() async {
    setState(() => _isLoading = true);
    final result = await FileEncryptionService.start(_file!, _password!);
    result.fold(
      onSuccess: (success) => setState(() => _resultFile = success),
      onError: (error) => setState(() => _errorMessage = error),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const HeaderWidget(),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 550),
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
                                    : (_resultFile == null &&
                                            _errorMessage == null)
                                        ? _buildPasswordStep()
                                        : _buildResultStep(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FooterWidget(isLoading: _isLoading),
            ],
          ),
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
                RoundedIconWidget(
                  icon: _isDecrypting
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                  color:
                      _isLoading ? Colors.grey : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _isLoading
                      ? null
                      : () {
                          _reset();
                          _selectFile();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        spacing: 5,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_present_outlined),
                              Flexible(
                                child: Text(
                                  _file!.shortName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Change file',
                            style: TextStyle(
                              color: _isLoading
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  enabled: !_isLoading,
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed:
                            (_isLoading || _password == null) ? null : _start,
                        icon: Icon(
                          _isDecrypting
                              ? Icons.lock_open_outlined
                              : Icons.lock_outline,
                        ),
                        label: Text(_isDecrypting ? 'Decrypt' : 'Encrypt'),
                      ),
                    ),
                  ],
                ),
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
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _errorMessage == null
                        ? () {
                            _reset();
                            _selectFile();
                          }
                        : _tryAgain,
                    icon: Icon(Icons.refresh),
                    label: Text(
                      _errorMessage != null
                          ? 'Try again'
                          : 'Select another file',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
