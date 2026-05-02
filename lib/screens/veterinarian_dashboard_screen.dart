import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/patify_theme.dart';

class VeterinarianDashboardScreen extends StatelessWidget {
  const VeterinarianDashboardScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  static const List<_VeterinarianMenuItem> _items = [
    _VeterinarianMenuItem(
      title: 'Klinik Durumum',
      subtitle: 'Klinik hesabının genel durumunu ve hazırlık adımlarını takip et.',
      icon: Icons.verified_user_outlined,
      accent: PatifyTheme.primary,
    ),
    _VeterinarianMenuItem(
      title: 'Kliniğimi Sahiplen',
      subtitle: 'Kliniğini hesabınla eşlemek için ayrılan başlangıç alanı.',
      icon: Icons.key_outlined,
      accent: PatifyTheme.accent,
    ),
    _VeterinarianMenuItem(
      title: 'Yeni Klinik Ekle',
      subtitle: 'Yeni klinik kaydı için hazırlanmış taslak yönetim kartı.',
      icon: Icons.add_business_outlined,
      accent: PatifyTheme.secondary,
    ),
    _VeterinarianMenuItem(
      title: 'Klinik Bilgilerim',
      subtitle: 'İletişim ve tanıtım bilgilerini yöneteceğin alan burada olacak.',
      icon: Icons.badge_outlined,
      accent: PatifyTheme.info,
    ),
    _VeterinarianMenuItem(
      title: 'Randevu Takvimi',
      subtitle: 'Takvim görünümü ve uygunluk yönetimi bu kart altında açılacak.',
      icon: Icons.calendar_month_outlined,
      accent: PatifyTheme.success,
    ),
    _VeterinarianMenuItem(
      title: 'Gelen Randevular',
      subtitle: 'Yeni randevu talepleri ve bekleyen işlemler burada listelenecek.',
      icon: Icons.notifications_active_outlined,
      accent: PatifyTheme.danger,
    ),
  ];

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final firstName = user.firstName?.trim();
    final displayName = firstName != null && firstName.isNotEmpty
        ? firstName
        : user.displayName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veteriner Paneli'),
        automaticallyImplyLeading: false,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PatifyTheme.background,
              PatifyTheme.backgroundSoft,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 1100
                  ? 3
                  : width >= 700
                      ? 2
                      : 1;

              return ListView(
                padding: const EdgeInsets.all(PatifyTheme.space24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(PatifyTheme.space24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius:
                          BorderRadius.circular(PatifyTheme.radius24),
                      border: Border.all(color: PatifyTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PatifyTheme.textPrimary.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: PatifyTheme.primarySoft,
                            borderRadius:
                                BorderRadius.circular(PatifyTheme.radius20),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: PatifyTheme.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space20),
                        Text(
                          'Veteriner Paneli',
                          style: textTheme.displayMedium,
                        ),
                        const SizedBox(height: PatifyTheme.space8),
                        Text(
                          'Klinik bilgilerinizi ve randevu süreçlerinizi buradan yöneteceksiniz.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: PatifyTheme.space16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PatifyTheme.space12,
                            vertical: PatifyTheme.space8,
                          ),
                          decoration: BoxDecoration(
                            color: PatifyTheme.secondarySoft,
                            borderRadius: BorderRadius.circular(
                              PatifyTheme.radius16,
                            ),
                          ),
                          child: Text(
                            '$displayName için hazırlanan çalışma alanı',
                            style: textTheme.labelLarge?.copyWith(
                              color: PatifyTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PatifyTheme.space24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: PatifyTheme.space16,
                      mainAxisSpacing: PatifyTheme.space16,
                      childAspectRatio: crossAxisCount == 1 ? 1.7 : 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _VeterinarianActionCard(
                        item: item,
                        onTap: () => _showComingSoon(context),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VeterinarianActionCard extends StatelessWidget {
  const _VeterinarianActionCard({
    required this.item,
    required this.onTap,
  });

  final _VeterinarianMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(PatifyTheme.radius20),
            border: Border.all(color: PatifyTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.14),
                    borderRadius:
                        BorderRadius.circular(PatifyTheme.radius16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.accent,
                  ),
                ),
                const SizedBox(height: PatifyTheme.space16),
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: PatifyTheme.space8),
                Expanded(
                  child: Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: PatifyTheme.space12),
                Row(
                  children: [
                    Text(
                      'Detaylar',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: item.accent,
                      ),
                    ),
                    const SizedBox(width: PatifyTheme.space8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: item.accent,
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

class _VeterinarianMenuItem {
  const _VeterinarianMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
