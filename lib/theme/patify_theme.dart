// Dosya: lib/theme/patify_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  static void setTheme(ThemeMode mode) {
    themeNotifier.value = mode;
  }
}

// YENİ: Resimleri Dark Modda Bozmamak İçin Düzeltici Widget
class DarkImageFixer extends StatelessWidget {
  final Widget child;
  const DarkImageFixer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentMode, _) {
        if (currentMode == ThemeMode.dark) {
          // Global filtre zaten tersine çevirdi.
          // Resmi tekrar tersine çevirerek (Negatifin negatifi = Pozitif) orijinalini gösteriyoruz.
          return ColorFiltered(
            colorFilter: const ColorFilter.matrix(PatifyTheme.inversionMatrix),
            child: child,
          );
        }
        return child;
      },
    );
  }
}

class PatifyTheme {
  // --- RENK TERSİNE ÇEVİRME MATRİSİ (Negatif Efekti) ---
  static const List<double> inversionMatrix = [
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1,   0,
  ];

  // --- ORTAK RENKLER ---
  static const Color lightBackground = Color(0xFFBDE3C3);
  static const Color lightTextPrimary = Color(0xFF1B4242);
  static const Color lightTextSecondary = Color(0xFF3A0519);
  static const Color pastelPink = Color(0xFFF5D2D2);
  static const Color pastelBlue = Color(0xFFA3CCDA);
  static const Color pastelYellow = Color(0xFFF8F7BA);

  // --- LIGHT TEMA AYARLARI ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: pastelPink,
        onPrimary: lightTextSecondary,
        secondary: pastelBlue,
        onSecondary: lightTextPrimary,
        surface: lightBackground,
        onSurface: lightTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
      ),

      cardTheme: CardThemeData(
        color: pastelPink,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelBlue,
          foregroundColor: lightTextPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextSecondary,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightBackground,
        indicatorColor: pastelYellow,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.all(const IconThemeData(color: lightTextSecondary)),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        hintStyle: TextStyle(color: lightTextPrimary.withValues(alpha: 0.6)),
        prefixIconColor: lightTextPrimary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  // Dark tema için de Light temayı kullanıyoruz, main.dart içinde filtre ile çevireceğiz.
  static ThemeData get darkTheme => lightTheme;
}