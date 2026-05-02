import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../main.dart';
import '../services/app_preferences.dart';
import '../services/auth_service.dart';
import '../theme/patify_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentUser,
    required this.onUserUpdated,
  });

  final AppUser currentUser;
  final ValueChanged<AppUser> onUserUpdated;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppUser _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  void _showFeedback(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? PatifyTheme.danger : null,
      ),
    );
  }

  Future<void> _openProfileEditor() async {
    final updated = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ProfileEditSheet(user: _currentUser),
    );

    if (updated != null) {
      setState(() => _currentUser = updated);
      await AppPreferences.saveCurrentUser(updated);
      widget.onUserUpdated(updated);
      _showFeedback('Profil bilgileri güncellendi.');
    }
  }

  Future<void> _openPasswordEditor() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PasswordChangeSheet(email: _currentUser.email),
    );

    if (changed == true) {
      _showFeedback('Şifren başarıyla güncellendi.');
    }
  }

  Future<void> _changeTheme(ThemeMode? mode) async {
    if (mode == null) return;
    await PatifyApp.of(context).updateThemeMode(mode);
    if (!mounted) return;
    _showFeedback('Tema tercihi güncellendi.');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentThemeMode = PatifyApp.of(context).themeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space12,
          PatifyTheme.space20,
          PatifyTheme.space28,
        ),
        children: [
          _buildSettingsHeader(theme, "Hesap"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text("Profili Düzenle"),
                  subtitle: Text(_currentUser.displayName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openProfileEditor,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Şifreyi Değiştir"),
                  subtitle: const Text("Mevcut şifreni doğrulayarak değiştir."),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openPasswordEditor,
                ),
              ],
            ),
          ),
          const SizedBox(height: PatifyTheme.space16),
          _buildSettingsHeader(theme, "Görünüm"),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tema seçimi",
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: PatifyTheme.space8),
                  Text(
                    "Açık, koyu veya sistem temasını kullanabilirsin.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: PatifyTheme.space16),
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: currentThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text("Sistem"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text("Açık"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text("Koyu"),
                      ),
                    ],
                    onChanged: _changeTheme,
                    decoration: const InputDecoration(
                      labelText: "Tema",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PatifyTheme.space8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: PatifyTheme.textSecondary,
        ),
      ),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({required this.user});

  final AppUser user;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('NAME_REQUIRED')) {
      return 'Ad ve soyad boş bırakılamaz.';
    }
    if (message.contains('EMAIL_NOT_FOUND')) {
      return 'Kullanıcı bulunamadı.';
    }
    return 'Profil bilgileri güncellenemedi. Lütfen tekrar dene.';
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final auth = await AuthService.updateProfile(
        email: widget.user.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      final firstName = auth.firstName?.trim();
      final lastName = auth.lastName?.trim();
      final displayName = [firstName, lastName]
          .whereType<String>()
          .where((entry) => entry.isNotEmpty)
          .join(' ')
          .trim();

      Navigator.pop(
        context,
        widget.user.copyWith(
          firstName: firstName,
          lastName: lastName,
          name: displayName.isNotEmpty ? displayName : widget.user.name,
        ),
      );
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PatifyTheme.space20,
            PatifyTheme.space8,
            PatifyTheme.space20,
            PatifyTheme.space20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Profili Düzenle",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: PatifyTheme.space8),
                Text(
                  "Ad ve soyad bilgilerini güncelleyebilirsin.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: PatifyTheme.space20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: "Ad",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ad boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: PatifyTheme.space12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: "Soyad",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Soyad boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: PatifyTheme.space16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PatifyTheme.danger,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                const SizedBox(height: PatifyTheme.space20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text("Vazgeç"),
                      ),
                    ),
                    const SizedBox(width: PatifyTheme.space12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Kaydet"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordChangeSheet extends StatefulWidget {
  const _PasswordChangeSheet({required this.email});

  final String email;

  @override
  State<_PasswordChangeSheet> createState() => _PasswordChangeSheetState();
}

class _PasswordChangeSheetState extends State<_PasswordChangeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('404')) {
      return 'Şifre değiştirme servisi bulunamadı. Backend uygulamasını yeniden başlat.';
    }
    if (message.contains('500')) {
      return 'Sunucu işlemi tamamlayamadı. Backend loglarını kontrol edip tekrar dene.';
    }
    if (message.contains('INVALID_PASSWORD')) {
      return 'Mevcut şifre doğrulanamadı.';
    }
    if (message.contains('PASSWORD_TOO_SHORT')) {
      return 'Yeni şifre en az 6 karakter olmalı.';
    }
    if (message.contains('EMAIL_NOT_FOUND')) {
      return 'Kullanıcı bulunamadı.';
    }
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Backend bağlantısını kontrol et.';
    }
    return 'Şifre güncellenemedi. Lütfen tekrar dene.';
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await AuthService.changePassword(
        email: widget.email,
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PatifyTheme.space20,
            PatifyTheme.space8,
            PatifyTheme.space20,
            PatifyTheme.space20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Şifreyi Değiştir",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: PatifyTheme.space8),
                Text(
                  "Güvenliğin için mevcut şifreni doğrulaman gerekiyor.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: PatifyTheme.space20),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mevcut şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mevcut şifre boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: PatifyTheme.space12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Yeni şifre",
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                  validator: (value) {
                    final password = (value ?? '').trim();
                    if (password.isEmpty) {
                      return 'Yeni şifre boş bırakılamaz.';
                    }
                    if (password.length < 6) {
                      return 'Yeni şifre en az 6 karakter olmalı.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: PatifyTheme.space12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Yeni şifre tekrar",
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Şifre tekrarı boş bırakılamaz.';
                    }
                    if (value!.trim() != _newPasswordController.text.trim()) {
                      return 'Yeni şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: PatifyTheme.space16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PatifyTheme.danger,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                const SizedBox(height: PatifyTheme.space20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text("Vazgeç"),
                      ),
                    ),
                    const SizedBox(width: PatifyTheme.space12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Şifreyi Güncelle"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
