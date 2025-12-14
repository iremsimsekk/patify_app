// Dosya: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'main_wrapper.dart'; // Kullanıcı ana sayfası
import 'shelter_dashboard_screen.dart'; // Barınak ana sayfası
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    debugPrint("LOGIN pressed");
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Email ve şifre boş olamaz!");
      return;
    }

    try {
      final dio = Dio(BaseOptions(
        baseUrl: "http://localhost:8080", // Flutter Web için
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ));

      final res = await dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });

      final token = res.data["token"] as String;
      final role = res.data["role"] as String; // "USER" veya "ADMIN"

      debugPrint("TOKEN: $token");
      debugPrint("ROLE: $role");

      // UI tarafında mevcut detayları kaybetmemek için mockUsers'tan bul:
      AppUser? user = getMockUserByEmail(email);

      // Eğer mock'ta yoksa, minimal kullanıcı üret:
      user ??= AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim().toLowerCase(),
        password: '', // backend doğruladı, burada tutmuyoruz
        name: email.split('@').first,
        type: role == "USER" ? UserType.petOwner : UserType.shelter,
      );

      // Role'a göre yönlendirme (şimdilik ADMIN -> shelter paneli gibi)
      if (role == "USER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainWrapper(currentUser: user!)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ShelterDashboardScreen(shelterUser: user!)),
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ?? e.message ?? "Bilinmeyen hata";
      setState(() => _errorMessage = "Giriş başarısız: $msg");
    } catch (e) {
      setState(() => _errorMessage = "Beklenmeyen hata: $e");
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
                Text("Patify",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
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
                  Text(_errorMessage!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ],

                const SizedBox(height: 24),

                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.primary, // Pastel Pembe
                      foregroundColor: theme.colorScheme.onPrimary, // Koyu Yazı
                    ),
                    child: const Text("Giriş Yap",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                      Text("Test Hesapları:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(height: 8),
                      const Text("Kullanıcı: user@patify.com / 123456"),
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

  InputDecoration _inputDecoration(
      String label, IconData icon, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: theme.colorScheme.onSecondary.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: theme.colorScheme.onSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: theme.colorScheme.onSecondary, width: 1.5),
      ),
    );
  }
}
