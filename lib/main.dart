import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/onboarding_screen.dart';
import 'services/app_preferences.dart';
import 'services/stitch_api_service.dart';
import 'theme/patify_design_theme.dart';
import 'theme/patify_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const PatifyApp());
}

class PatifyApp extends StatefulWidget {
  const PatifyApp({super.key});

  static PatifyAppThemeAccess of(BuildContext context) {
    final state = context.findAncestorStateOfType<_PatifyAppState>();
    assert(state != null, 'PatifyApp state not found in widget tree.');
    return state!;
  }

  @override
  State<PatifyApp> createState() => _PatifyAppState();
}

abstract class PatifyAppThemeAccess {
  ThemeMode get themeMode;
  Future<void> updateThemeMode(ThemeMode mode);
}

class _PatifyAppState extends State<PatifyApp> implements PatifyAppThemeAccess {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _lightTheme = PatifyTheme.lightTheme;
  ThemeData _darkTheme = PatifyTheme.darkTheme;
  bool _appReady = false;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final storedMode = await AppPreferences.loadThemeMode();
    final dna = await StitchApiService.fromEnv().fetchDesignDna();

    if (!mounted) return;
    setState(() {
      _themeMode = storedMode;
      _lightTheme = PatifyDesignTheme.light(dna);
      _darkTheme = PatifyDesignTheme.dark(dna);
      _appReady = true;
    });
  }

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    setState(() => _themeMode = mode);
    await AppPreferences.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patify',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final content = _appReady
            ? child ?? const SizedBox.shrink()
            : const ColoredBox(
                color: PatifyTheme.background,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: content,
        );
      },
      home: const OnboardingScreen(),
    );
  }
}
