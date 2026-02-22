// Dosya: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'main_wrapper.dart'; // Kullanıcı ana sayfası
import 'shelter_dashboard_screen.dart'; // Barınak ana sayfası

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() {
    final email = _emailController.text.trim(); // Boşlukları temizle
    final password = _passwordController.text.trim();

    final user = authenticateUser(email, password);

    if (user != null) {
      // Giriş Başarılı
      if (user.type == UserType.petOwner) {
        // Normal Kullanıcı -> Ana Sayfaya
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainWrapper(currentUser: user)),
        );
      } else {
        // Barınak Hesabı -> Barınak Paneline
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShelterDashboardScreen(shelterUser: user)),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Email veya şifre hatalı!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onSecondary; // Koyu Mavi/Yeşil tonu

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Pastel Yeşil Zemin
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 80, color: primaryColor),
                const SizedBox(height: 20),
                Text(
                  "Patify", 
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)
                ),
                const SizedBox(height: 40),
                
                // Email
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email", Icons.email, theme),
                ),
                const SizedBox(height: 16),
                
                // Şifre
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Şifre", Icons.lock, theme),
                ),
                
                // Hata Mesajı
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
                
                const SizedBox(height: 24),
                
                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Pastel Pembe
                      foregroundColor: theme.colorScheme.onPrimary, // Koyu Yazı
                    ),
                    child: const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // İpucu Kutusu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    children: [
                      Text("Test Hesapları:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 8),
                      const Text("Kullanıcı: user@patify.com / 123"),
                      const Divider(),
                      // BURASI GÜNCELLENDİ:
                      const Text("Barınak: cankaya@patify.com / 123"),
                      const Text("(veya golbasi@patify.com)"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSecondary.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: theme.colorScheme.onSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: theme.colorScheme.onSecondary, width: 1.5),
      ),
    );
  }
}