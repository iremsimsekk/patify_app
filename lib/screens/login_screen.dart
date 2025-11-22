// Dosya: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'main_wrapper.dart'; // Kullanıcı ana sayfası
import 'shelter_dashboard_screen.dart'; // Barınak ana sayfası (aşağıda oluşturacağız)

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
    final email = _emailController.text;
    final password = _passwordController.text;

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
        _errorMessage = "Email veya şifre hatalı! (Test: user@patify.com / 123)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text("Patify", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Giriş Yap"),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Test Hesapları:", style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("User: user@patify.com / 123"),
              const Text("Shelter: shelter@patify.com / 123"),
            ],
          ),
        ),
      ),
    );
  }
}