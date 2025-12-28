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
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _submitted = false;
  String? _error;

  bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }

  String _friendlyError(Object e) {
    final s = e.toString();

    if (s.contains('EMAIL_EXISTS')) return 'Bu email zaten kayıtlı.';
    if (s.contains('INVALID')) return 'Bilgiler hatalı. Lütfen tekrar dene.';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Backend çalışıyor mu ve baseUrl doğru mu kontrol et.';
    }
    if (s.contains('TimeoutException')) {
      return 'İstek zaman aşımına uğradı. İnternet bağlantını kontrol edip tekrar dene.';
    }
    return 'Kayıt başarısız. Lütfen tekrar dene.';
  }

  Future<void> _signup() async {
    setState(() {
      _submitted = true;
      _error = null;
    });

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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
        name: "${auth.firstName ?? firstName} ${auth.lastName ?? lastName}"
            .trim(),
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
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: deco("Ad", Icons.person),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Ad boş olamaz.";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: deco("Soyad", Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Soyad boş olamaz.";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: deco("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final email = (v ?? '').trim();
                  if (email.isEmpty) return "Email boş olamaz.";
                  if (!_isValidEmail(email))
                    return "Lütfen geçerli bir email gir.";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: deco("Şifre", Icons.lock),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _loading ? null : _signup(),
                validator: (v) {
                  final p = (v ?? '').trim();
                  if (p.isEmpty) return "Şifre boş olamaz.";
                  if (p.length < 6) return "Şifre en az 6 karakter olmalı.";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Kayıt Ol"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
