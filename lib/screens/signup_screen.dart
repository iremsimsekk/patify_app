import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/patify_theme.dart';

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
  String? _success;

  bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }

  String _friendlyError(Object e) {
    final s = e.toString();

    if (s.contains('EMAIL_EXISTS')) return 'Bu email zaten kayitli.';
    if (s.contains('INVALID')) return 'Bilgiler hatali. Lutfen tekrar dene.';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Sunucuya baglanilamadi. Backend ve baseUrl ayarlarini kontrol et.';
    }
    if (s.contains('TimeoutException')) {
      return 'Istek zaman asimina ugradi. Baglantini kontrol edip tekrar dene.';
    }
    return 'Kayit basarisiz. Lutfen tekrar dene.';
  }

  Future<void> _signup() async {
    setState(() {
      _submitted = true;
      _error = null;
      _success = null;
    });

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await AuthService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (!mounted) return;
      setState(() {
        _success =
            '${result.email.isNotEmpty ? result.email : email} adresine dogrulama maili gonderildi. Giris yapmadan once maildeki linke tikla.';
      });
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
    final textTheme = Theme.of(context).textTheme;

    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        );

    return Scaffold(
      appBar: AppBar(title: const Text("Kayit Ol")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PatifyTheme.space24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Yeni bir hesap olustur",
                        style: textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PatifyTheme.space8),
                      Text(
                        "Temel bilgilerini ekleyip Patify deneyimine katil.",
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PatifyTheme.space24),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: deco("Ad", Icons.person_outline),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Ad bos olamaz.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: deco("Soyad", Icons.badge_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Soyad bos olamaz.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _emailController,
                        decoration: deco("Email", Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final email = (v ?? '').trim();
                          if (email.isEmpty) return "Email bos olamaz.";
                          if (!_isValidEmail(email)) {
                            return "Lutfen gecerli bir email gir.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: deco("Sifre", Icons.lock_outline),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _loading ? null : _signup(),
                        validator: (v) {
                          final p = (v ?? '').trim();
                          if (p.isEmpty) return "Sifre bos olamaz.";
                          if (p.length < 6) {
                            return "Sifre en az 6 karakter olmali.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space16),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(PatifyTheme.space12),
                          decoration: BoxDecoration(
                            color: PatifyTheme.danger.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(PatifyTheme.radius12),
                            border: Border.all(
                              color: PatifyTheme.danger.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: PatifyTheme.danger,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space16),
                      ],
                      if (_success != null) ...[
                        Container(
                          padding: const EdgeInsets.all(PatifyTheme.space12),
                          decoration: BoxDecoration(
                            color:
                                PatifyTheme.success.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(PatifyTheme.radius12),
                            border: Border.all(
                              color:
                                  PatifyTheme.success.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            _success!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: PatifyTheme.success,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Kayit Ol"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
