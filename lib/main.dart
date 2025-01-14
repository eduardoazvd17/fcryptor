import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setDesktopAppSettings();
  runApp(const MyApp());
}

Future<void> _setDesktopAppSettings() async {
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    const size = Size(400, 550);
    await windowManager.ensureInitialized();
    WindowManager.instance.setTitle('FCryptor');
    WindowManager.instance.setSize(size);
    WindowManager.instance.setMinimumSize(size);
    WindowManager.instance.setMaximumSize(size);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCryptor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
