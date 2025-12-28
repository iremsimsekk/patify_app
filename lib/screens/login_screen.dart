// Dosya: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

import '../config/api_keys.dart';
import '../services/auth_service.dart';

import 'main_wrapper.dart';
import 'shelter_dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _loading = false;

  void _guestLogin() {
    final guestUser = AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@patify.com',
      password: '',
      name: 'Misafir',
      type: UserType.petOwner,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainWrapper(
          currentUser: guestUser,
          apiKey: ApiKeys.googleMaps,
        ),
      ),
    );
  }

  String _friendlyError(Object e) {
    final s = e.toString();

    // Backend RuntimeException mesajları burada yakalanabilir (EMAIL_EXISTS / INVALID)
    if (s.contains('EMAIL_EXISTS')) return 'Bu email zaten kayıtlı.';
    if (s.contains('INVALID')) return 'Email veya şifre hatalı.';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Backend’e bağlanılamadı. API baseUrl/port ve backend çalışıyor mu kontrol et.';
    }
    return 'Giriş başarısız: $s';
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = "Email ve şifre boş olamaz!";
      });
      return;
    }

    try {
      final auth = await AuthService.login(email: email, password: password);

      final user = AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        email: email.toLowerCase(),
        password: '',
        name: email.split('@').first,
        type: auth.role == "ADMIN" ? UserType.shelter : UserType.petOwner,
      );

      if (!mounted) return;

      if (auth.role == "USER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainWrapper(
              currentUser: user,
              apiKey: ApiKeys.googleMaps,
            ),
          ),
        );
      } else {
        // ADMIN'i barınak paneline yönlendiriyoruz (senin eski mantığın)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShelterDashboardScreen(shelterUser: user)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email", Icons.email, theme),
                  keyboardType: TextInputType.emailAddress,
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
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // ✅ Giriş Yap
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Giriş Yap",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Misafir Girişi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _guestLogin,
                    icon: const Icon(Icons.person_outline),
                    label: const Text(
                      "Misafir Girişi",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSecondary,
                      side: BorderSide(color: theme.colorScheme.onSecondary.withValues(alpha: 0.6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                // ✅ Kayıt Ol linki
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                  child: Text(
                    "Hesabın yok mu? Kayıt Ol",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
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
