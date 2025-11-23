// Dosya: lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Yeni çerçeve rengi
  final Color _borderColor = const Color(0xFFB9375D);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Açık pembe rengi mevcut temadan alıyoruz (Pastel Pembe)
    final lightPinkColor = theme.colorScheme.primary; 
    // İkon ve Yazı rengi için temanın onPrimary rengini (Koyu Bordo) kullanıyoruz
    final iconAndTextColor = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Pastel Yeşil Arka Plan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // LOGO ALANI (GÜNCELLENDİ)
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  // İç dolgu rengi (Açık Pembe)
                  color: lightPinkColor,
                  shape: BoxShape.circle,
                  // YENİ EKLENDİ: Çerçeve (Border)
                  border: Border.all(
                    color: iconAndTextColor, // İstenilen renk: #B9375D
                    width: 3.0, // Çerçeve kalınlığı
                  ),
                  // Hafif bir gölge ekleyerek daha da öne çıkaralım
                  boxShadow: [
                    BoxShadow(
                      color: _borderColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets_rounded,
                  size: 100,
                  color: iconAndTextColor, // İkon rengi (Koyu Bordo)
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Patify",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: iconAndTextColor, // Yazı rengi (Koyu Bordo)
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "All-in-one Pet Care Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: iconAndTextColor.withValues(alpha: 0.7), // Biraz daha soft yazı rengi
                ),
              ),
              const Spacer(),
              // GET STARTED BUTONU (GÜNCELLENDİ)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightPinkColor, // Buton iç rengi (Açık Pembe)
                    foregroundColor: iconAndTextColor, // Buton yazı rengi (Koyu Bordo)
                    elevation: 4, // Biraz gölge
                    shadowColor: _borderColor.withValues(alpha: 0.5), // Gölge rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // YENİ EKLENDİ: Çerçeve (BorderSide)
                    side: BorderSide(
                      color: iconAndTextColor, // İstenilen renk: #B9375D
                      width: 2.5, // Çerçeve kalınlığı
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Alt boşluk artırıldı
            ],
          ),
        ),
      ),
    );
  }
}