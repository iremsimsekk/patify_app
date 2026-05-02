import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/patify_theme.dart';

enum _SignupAccountType { petOwner, veterinarian }

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
  _SignupAccountType _selectedAccountType = _SignupAccountType.petOwner;

  bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }

  String _friendlyError(Object e) {
    final s = e.toString();

    if (s.contains('EMAIL_EXISTS')) return 'Bu e-posta adresi zaten kayıtlı.';
    if (s.contains('INVALID')) return 'Bilgilerde bir hata var. Lütfen tekrar dene.';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    if (s.contains('TimeoutException')) {
      return 'İstek zaman aşımına uğradı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    return 'Kayıt tamamlanamadı. Lütfen tekrar dene.';
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
    final role = _selectedAccountType == _SignupAccountType.veterinarian
        ? 'VETERINARIAN'
        : 'USER';

    try {
      final result = await AuthService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );

      if (!mounted) return;
      setState(() {
        _success =
            '${result.email.isNotEmpty ? result.email : email} adresine doğrulama e-postası gönderdik. Giriş yapmadan önce e-postadaki bağlantıya tıkla.';
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
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
                        'Yeni bir hesap oluştur',
                        style: textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PatifyTheme.space8),
                      Text(
                        'Temel bilgilerini ekleyip Patify deneyimine katıl.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PatifyTheme.space24),
                      Text(
                        'Hesap tipi',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      _AccountTypeCard(
                        title: 'Hayvansever Girişi',
                        subtitle:
                            'Patify\'ı günlük kullanım, keşif ve bakım takibi için kullan.',
                        icon: Icons.pets_outlined,
                        selected:
                            _selectedAccountType == _SignupAccountType.petOwner,
                        onTap: () {
                          setState(() {
                            _selectedAccountType =
                                _SignupAccountType.petOwner;
                          });
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      _AccountTypeCard(
                        title: 'Veteriner / Klinik Yetkilisi',
                        subtitle:
                            'Bu adımda yalnızca hesap rolün kaydedilir, ek panel açılmaz.',
                        icon: Icons.local_hospital_outlined,
                        selected: _selectedAccountType ==
                            _SignupAccountType.veterinarian,
                        onTap: () {
                          setState(() {
                            _selectedAccountType =
                                _SignupAccountType.veterinarian;
                          });
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space20),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: deco('Ad', Icons.person_outline),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ad boş olamaz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: deco('Soyad', Icons.badge_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Soyad boş olamaz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _emailController,
                        decoration: deco('E-posta', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final email = (v ?? '').trim();
                          if (email.isEmpty) return 'E-posta boş olamaz.';
                          if (!_isValidEmail(email)) {
                            return 'Lütfen geçerli bir e-posta adresi gir.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: deco('Şifre', Icons.lock_outline),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _loading ? null : _signup(),
                        validator: (v) {
                          final p = (v ?? '').trim();
                          if (p.isEmpty) return 'Şifre boş olamaz.';
                          if (p.length < 6) {
                            return 'Şifre en az 6 karakter olmalı.';
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
                            color: PatifyTheme.success.withValues(alpha: 0.08),
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
                              : const Text('Kayıt Ol'),
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

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PatifyTheme.radius16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(PatifyTheme.space16),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(PatifyTheme.radius16),
          border: Border.all(
            color: selected ? colorScheme.primary : PatifyTheme.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : PatifyTheme.primarySoft,
                borderRadius: BorderRadius.circular(PatifyTheme.radius12),
              ),
              child: Icon(
                icon,
                color: selected ? colorScheme.primary : PatifyTheme.textPrimary,
              ),
            ),
            const SizedBox(width: PatifyTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: selected ? colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: PatifyTheme.space4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: PatifyTheme.space12),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colorScheme.primary : PatifyTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
