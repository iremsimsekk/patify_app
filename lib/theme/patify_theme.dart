// Dosya: lib/theme/patify_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatifyTheme {
  // --- RENK PALETİ ---
  // İstenen Pastel Renkler
  static const Color pastelGreen = Color(0xFFBDE3C3); // Ana Arka Plan
  static const Color pastelPink = Color(0xFFF5D2D2);  // Kartlar / Widgetlar
  static const Color pastelYellow = Color(0xFFF8F7BA); // İkincil Vurgular
  static const Color pastelBlue = Color(0xFFA3CCDA);   // İkincil Vurgular / Butonlar
  
  // Yazı Renkleri (Okunabilirlik için koyu tonlar)
  static const Color darkTextPrimary = Color(0xFF1B4242); // Ana metin rengi (Koyu Yeşilimsi)
  static const Color darkTextSecondary = Color(0xFF3A0519); // İkincil metin rengi (Koyu Bordo)

  // Ortak Tema Ayarları (Hem Light hem Dark modda aynı görünsün diye)
  static ThemeData get _baseTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Renk Şeması
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: pastelPink,          // Ana vurgu rengi (Widgetlar)
        onPrimary: darkTextSecondary, // Pembe üzerindeki yazı rengi
        secondary: pastelBlue,        // İkincil vurgu
        onSecondary: darkTextPrimary, // Mavi üzerindeki yazı rengi
        error: Colors.redAccent,
        onError: Colors.white,
        surface: pastelGreen,         // ARKA PLAN RENGİ (Scaffold)
        onSurface: darkTextPrimary,   // Arka plan üzerindeki yazı rengi
      ),

      // Arka Plan Rengi (Kesinlikle Yeşil olsun)
      scaffoldBackgroundColor: pastelGreen,

      // AppBar Teması
      appBarTheme: const AppBarTheme(
        backgroundColor: pastelGreen, // AppBar da yeşil olsun, bütünlük sağlasın
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Kart Teması (Widgetlar Pastel Pembe)
      cardTheme: CardThemeData(
        color: pastelPink, // Kartların arka planı pembe
        elevation: 4, // Biraz gölge
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // Buton Teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelBlue, // Butonlar Mavi
          foregroundColor: darkTextPrimary, // Yazısı Koyu
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Yazı Tipi ve Renkleri
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: darkTextPrimary,      // Genel yazılar
        displayColor: darkTextSecondary, // Başlıklar
      ),
      
      // Bottom Navigation Bar Teması
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: pastelGreen, // Alt bar da yeşil zeminli olsun
        indicatorColor: pastelYellow, // Seçili öğe arkası sarı olsun
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: darkTextSecondary),
        ),
      ),
      
      // Input (Arama Çubuğu vb.) Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7), // Hafif transparan beyaz
        hintStyle: TextStyle(color: darkTextPrimary.withOpacity(0.6)),
        prefixIconColor: darkTextPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Telefonun ayarı ne olursa olsun aynı temayı döndürüyoruz
  static ThemeData get lightTheme => _baseTheme;
  static ThemeData get darkTheme => _baseTheme;
}