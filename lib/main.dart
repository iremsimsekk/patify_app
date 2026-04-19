import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'services/app_preferences.dart';
import 'theme/patify_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool _themeReady = false;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final storedMode = await AppPreferences.loadThemeMode();
    if (!mounted) return;
    setState(() {
      _themeMode = storedMode;
      _themeReady = true;
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
      theme: PatifyTheme.lightTheme,
      darkTheme: PatifyTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final content = _themeReady
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
