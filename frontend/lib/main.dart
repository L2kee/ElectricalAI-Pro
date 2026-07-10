import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ElectricalAIProApp());
}

class ElectricalAIProApp extends StatelessWidget {
  const ElectricalAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectricalAI Pro',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const HomeScreen(),
    );
  }
}