import 'package:flutter/material.dart';
import 'screens/web_shell.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoreX',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const WebShell(),
    );
  }
}
