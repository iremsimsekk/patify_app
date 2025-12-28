import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import '../config/api_keys.dart';
import 'main_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _loading = false;
        _error = "Ad, soyad, email ve şifre boş olamaz.";
      });
      return;
    }

    try {
      final auth = await AuthService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final user = AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        email: auth.email.isNotEmpty ? auth.email : email.toLowerCase(),
        password: '',
        firstName: auth.firstName ?? firstName,
        lastName: auth.lastName ?? lastName,
        name: "${auth.firstName ?? firstName} ${auth.lastName ?? lastName}".trim(),
        type: auth.role == "ADMIN" ? UserType.shelter : UserType.petOwner,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainWrapper(
            currentUser: user,
            apiKey: ApiKeys.googleMaps,
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = "Kayıt başarısız: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        );

    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: deco("Ad", Icons.person)),
            const SizedBox(height: 12),
            TextField(controller: _lastNameController, decoration: deco("Soyad", Icons.person_outline)),
            const SizedBox(height: 12),

            TextField(controller: _emailController, decoration: deco("Email", Icons.email)),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, decoration: deco("Şifre", Icons.lock)),
            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading ? const CircularProgressIndicator() : const Text("Kayıt Ol"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
