import 'package:flutter/material.dart';
import 'package:patify_app/screens/onboarding_screen.dart';
import 'theme/patify_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PatifyApp());
}

class PatifyApp extends StatelessWidget {
  const PatifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patify',
      debugShowCheckedModeBanner: false,
      theme: PatifyTheme.lightTheme,
      darkTheme: PatifyTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingScreen(),
    );
  }
}
