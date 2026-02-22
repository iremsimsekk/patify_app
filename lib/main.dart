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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Patify',
          debugShowCheckedModeBanner: false,
          theme: PatifyTheme.lightTheme,
          darkTheme: PatifyTheme.lightTheme, // Dark mod kontrolünü biz yapıyoruz
          themeMode: currentMode,
          builder: (context, child) {
            // Eğer Dark Mode ise tüm uygulamayı tersine çevir
            if (currentMode == ThemeMode.dark) {
              return ColorFiltered(
                // PatifyTheme içinde tanımladığımız matrisi kullanıyoruz
                colorFilter: const ColorFilter.matrix(PatifyTheme.inversionMatrix),
                child: child!,
              );
            }
            return child!;
          },
          home: const OnboardingScreen(), 
        );
      },
    );
  }
}