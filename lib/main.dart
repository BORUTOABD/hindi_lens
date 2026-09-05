import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const HindiLensApp());
}

class HindiLensApp extends StatelessWidget {
  const HindiLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HindiLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}