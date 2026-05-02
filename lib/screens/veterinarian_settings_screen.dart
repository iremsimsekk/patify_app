import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../main.dart';
import '../services/app_preferences.dart';
import '../theme/patify_theme.dart';
import 'login_screen.dart';

class VeterinarianSettingsScreen extends StatelessWidget {
  const VeterinarianSettingsScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  Future<void> _logout(BuildContext context) async {
    await AppPreferences.clearAuth();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentThemeMode = PatifyApp.of(context).themeMode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PatifyTheme.space20,
        PatifyTheme.space16,
        PatifyTheme.space20,
        PatifyTheme.space28,
      ),
      children: [
        Text('Ayarlar', style: theme.textTheme.headlineSmall),
        const SizedBox(height: PatifyTheme.space8),
        Text(
          'Veteriner hesabın ve görünüm tercihlerini buradan yönetebilirsin.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: PatifyTheme.space20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hesap', style: theme.textTheme.titleMedium),
                const SizedBox(height: PatifyTheme.space16),
                const _InfoTile(
                  icon: Icons.badge_outlined,
                  title: 'Hesap türü',
                  subtitle: 'Veteriner',
                ),
                const SizedBox(height: PatifyTheme.space12),
                _InfoTile(
                  icon: Icons.email_outlined,
                  title: 'E-posta',
                  subtitle: user.email,
                ),
                const SizedBox(height: PatifyTheme.space12),
                _InfoTile(
                  icon: Icons.person_outline,
                  title: 'Görünen isim',
                  subtitle: user.displayName,
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Görünüm', style: theme.textTheme.titleMedium),
                const SizedBox(height: PatifyTheme.space8),
                Text(
                  'Patify temasına uygun açık, koyu veya sistem görünümünü seçebilirsin.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: PatifyTheme.space16),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: currentThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Sistem'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Açık'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Koyu'),
                    ),
                  ],
                  onChanged: (mode) async {
                    if (mode == null) return;
                    await PatifyApp.of(context).updateThemeMode(mode);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tema tercihi güncellendi.')),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tema',
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oturum', style: theme.textTheme.titleMedium),
                const SizedBox(height: PatifyTheme.space8),
                Text(
                  'Güvenli şekilde çıkış yaparak hesabını sonlandırabilirsin.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: PatifyTheme.space16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Çıkış yap'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PatifyTheme.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: PatifyTheme.primarySoft,
            borderRadius: BorderRadius.circular(PatifyTheme.radius16),
          ),
          child: Icon(icon, color: PatifyTheme.primary),
        ),
        const SizedBox(width: PatifyTheme.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: PatifyTheme.space4),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
