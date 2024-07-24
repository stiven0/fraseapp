import 'package:flutter/material.dart';

import 'package:fraseapp/config/config.dart';

void main() async {
  await Environments.initEnvironment();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
