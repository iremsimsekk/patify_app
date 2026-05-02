import 'package:flutter/material.dart';

import '../config/api_keys.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import '../services/app_preferences.dart';
import '../theme/patify_theme.dart';
import 'main_wrapper.dart';
import 'shelter_dashboard_screen.dart';
import 'signup_screen.dart';
import 'veterinarian_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  String? _infoMessage;
  bool _loading = false;
  bool _resendLoading = false;
  bool _submitted = false;

  bool _isValidEmail(String email) {
    final normalized = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(normalized);
  }

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

  AppUser _buildUserFromAuth(AuthResponse auth, String fallbackEmail) {
    final resolvedEmail = auth.email.isNotEmpty
        ? auth.email.toLowerCase()
        : fallbackEmail.toLowerCase();
    final firstName = auth.firstName?.trim();
    final lastName = auth.lastName?.trim();
    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();

    return AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      email: resolvedEmail,
      password: '',
      firstName: firstName?.isEmpty == true ? null : firstName,
      lastName: lastName?.isEmpty == true ? null : lastName,
      name: fullName.isNotEmpty ? fullName : resolvedEmail.split('@').first,
      type: _mapUserType(auth.role),
    );
  }

  UserType _mapUserType(String role) {
    switch (role) {
      case 'ADMIN':
        return UserType.shelter;
      case 'VETERINARIAN':
        return UserType.veterinarian;
      default:
        return UserType.petOwner;
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('EMAIL_EXISTS')) {
      return 'Bu e-posta adresi zaten kayıtlı.';
    }
    if (message.contains('EMAIL_NOT_VERIFIED')) {
      return 'Giriş yapmadan önce e-posta adresini doğrulaman gerekiyor. Lütfen gelen kutunu kontrol et.';
    }
    if (message.contains('INVALID')) return 'E-posta adresi veya şifre hatalı.';
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    if (message.contains('TimeoutException')) {
      return 'İstek zaman aşımına uğradı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    return 'Giriş yapılamadı. Lütfen tekrar dene.';
  }

  String _friendlyResendError(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    if (message.contains('TimeoutException')) {
      return 'İstek zaman aşımına uğradı. Lütfen bağlantını kontrol edip tekrar dene.';
    }
    return 'Doğrulama e-postası isteği gönderilemedi. Lütfen tekrar dene.';
  }

  Future<void> _resendVerificationEmail() async {
    final email = _emailController.text.trim();
    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });

    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _errorMessage =
            'Doğrulama e-postası gönderebilmemiz için geçerli bir e-posta adresi gir.';
      });
      return;
    }

    setState(() => _resendLoading = true);

    try {
      await AuthService.resendVerificationEmail(email: email);
      if (!mounted) return;
      setState(() {
        _infoMessage =
            'Eğer bu e-posta adresine ait doğrulanmamış bir hesap varsa, yeni doğrulama bağlantısı gönderildi.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyResendError(error));
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() {
      _submitted = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final auth = await AuthService.login(email: email, password: password);
      await AppPreferences.saveAuthRole(auth.role);
      await AppPreferences.saveAuthToken(auth.token);
      final user = _buildUserFromAuth(auth, email);

      if (!mounted) return;

      if (user.type == UserType.shelter) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShelterDashboardScreen(shelterUser: user),
          ),
        );
      } else if (user.type == UserType.veterinarian) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VeterinarianDashboardScreen(user: user),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainWrapper(
              currentUser: user,
              apiKey: ApiKeys.googleMaps,
            ),
          ),
        );
      }
    } catch (error) {
      setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;

    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PatifyTheme.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: PatifyTheme.primarySoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child:
                              Icon(Icons.pets, size: 42, color: primaryColor),
                        ),
                        const SizedBox(height: PatifyTheme.space20),
                        Text('Patify', style: textTheme.displayMedium),
                        const SizedBox(height: PatifyTheme.space8),
                        Text(
                          'Evcil dostların için sakin, güvenli ve modern bir deneyim.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: PatifyTheme.space24),
                        TextFormField(
                          controller: _emailController,
                          decoration:
                              inputDecoration('E-posta', Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final email = (value ?? '').trim();
                            if (email.isEmpty) return 'E-posta boş olamaz.';
                            if (!_isValidEmail(email)) {
                              return 'Lütfen geçerli bir e-posta adresi gir.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: PatifyTheme.space16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              inputDecoration('Şifre', Icons.lock_outline),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _loading ? null : _login(),
                          validator: (value) {
                            final password = (value ?? '').trim();
                            if (password.isEmpty) return 'Şifre boş olamaz.';
                            return null;
                          },
                        ),
                        const SizedBox(height: PatifyTheme.space20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (_loading || _resendLoading) ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Giriş Yap'),
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: (_loading || _resendLoading)
                                ? null
                                : _guestLogin,
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Misafir Girişi'),
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space8),
                        TextButton(
                          onPressed: (_loading || _resendLoading)
                              ? null
                              : _resendVerificationEmail,
                          child: _resendLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Doğrulama e-postasını yeniden gönder',
                                ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: PatifyTheme.space16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(PatifyTheme.space12),
                            decoration: BoxDecoration(
                              color: PatifyTheme.danger.withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(PatifyTheme.radius12),
                              border: Border.all(
                                color:
                                    PatifyTheme.danger.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: PatifyTheme.danger,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        if (_infoMessage != null) ...[
                          const SizedBox(height: PatifyTheme.space16),
                          Container(
                            width: double.infinity,
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
                              _infoMessage!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: PatifyTheme.success,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const SizedBox(height: PatifyTheme.space8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Hesabın yok mu? Kayıt Ol'),
                        ),
                      ],
                    ),
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
