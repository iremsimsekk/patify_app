// Dosya: lib/main.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'theme/patify_theme.dart';
import 'screens/onboarding_screen.dart';

Future<void> testLogin() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080', // Flutter Web için
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  try {
    final res = await dio.post(
      '/auth/login',
      data: {
        'email': 'user@patify.com',
        'password': '123456',
      },
    );
    debugPrint('TOKEN: ${res.data['token']}');
    debugPrint('ROLE: ${res.data['role']}');
  } catch (e) {
    debugPrint('Login test failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await testLogin();
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
