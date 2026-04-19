import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/patify_theme.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'my_pets_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.onUserUpdated,
  });

  final AppUser currentUser;
  final ValueChanged<AppUser> onUserUpdated;

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = currentUser.displayName;
    final email = currentUser.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space12,
          PatifyTheme.space20,
          120,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(PatifyTheme.space20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(PatifyTheme.radius24),
              border: Border.all(color: PatifyTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: PatifyTheme.primarySoft,
                      width: 5,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 34,
                    backgroundColor: PatifyTheme.backgroundSoft,
                    backgroundImage: AssetImage('assets/user_placeholder.png'),
                    child: Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: PatifyTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: PatifyTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hesap', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: PatifyTheme.space4),
                      Text(fullName, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: PatifyTheme.space4),
                      Text(email, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PatifyTheme.space24),
          Text(
            'Yönetim',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: PatifyTheme.space12),
          _buildProfileItem(
            context,
            icon: Icons.pets_rounded,
            title: 'Evcil Dostlarım',
            subtitle: 'Kayıtlı dostlarını ve temel bilgilerini görüntüle.',
            color: PatifyTheme.info,
            onTap: () => _navigateToScreen(context, const MyPetsScreen()),
          ),
          _buildProfileItem(
            context,
            icon: Icons.history_rounded,
            title: 'Sahiplenme Geçmişi',
            subtitle: 'Geçmiş işlemlerini düzenli bir görünüm içinde incele.',
            color: PatifyTheme.accent,
            onTap: () => _navigateToScreen(context, const HistoryScreen()),
          ),
          _buildProfileItem(
            context,
            icon: Icons.settings_rounded,
            title: 'Ayarlar',
            subtitle: 'Profil, güvenlik ve tema tercihlerini yönet.',
            color: PatifyTheme.textSecondary,
            onTap: () {
              _navigateToScreen(
                context,
                SettingsScreen(
                  currentUser: currentUser,
                  onUserUpdated: onUserUpdated,
                ),
              );
            },
          ),
          const SizedBox(height: PatifyTheme.space12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(PatifyTheme.space16),
              leading: Container(
                padding: const EdgeInsets.all(PatifyTheme.space8),
                decoration: BoxDecoration(
                  color: PatifyTheme.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(PatifyTheme.radius12),
                ),
                child:
                    const Icon(Icons.logout_rounded, color: PatifyTheme.danger),
              ),
              title: Text(
                'Çıkış Yap',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: PatifyTheme.danger,
                ),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: PatifyTheme.space4),
                child: Text('Hesabından güvenli şekilde çıkış yap.'),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: PatifyTheme.textSecondary,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content: const Text(
                      'Hesabından çıkmak istediğine emin misin?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Çıkış Yap',
                          style: TextStyle(color: PatifyTheme.danger),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(PatifyTheme.space16),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(PatifyTheme.radius16),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: PatifyTheme.space4),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: PatifyTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
