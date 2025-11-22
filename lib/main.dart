// Dosya: lib/main.dart
import 'package:flutter/material.dart';
import 'theme/patify_theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const PatifyApp());
}

class PatifyApp extends StatelessWidget {
  const PatifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patify',
      debugShowCheckedModeBanner: false,
      // Temalar artık tamamen güncel ve uyumlu
      theme: PatifyTheme.lightTheme,
      darkTheme: PatifyTheme.darkTheme,
      themeMode: ThemeMode.system, 
      home: const OnboardingScreen(), 
    );
  }
}