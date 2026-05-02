import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';
import 'veterinarian_claim_clinic_screen.dart';

class VeterinarianDashboardScreen extends StatefulWidget {
  const VeterinarianDashboardScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<VeterinarianDashboardScreen> createState() =>
      _VeterinarianDashboardScreenState();
}

class _VeterinarianDashboardScreenState
    extends State<VeterinarianDashboardScreen> {
  static const List<_VeterinarianMenuItem> _items = [
    _VeterinarianMenuItem(
      keyName: 'status',
      title: 'Klinik Durumum',
      subtitle: 'Mevcut sahiplenme ve onay durumunuzu gözden geçirin.',
      icon: Icons.verified_user_outlined,
      accent: PatifyTheme.primary,
    ),
    _VeterinarianMenuItem(
      keyName: 'claim',
      title: 'Kliniğimi Sahiplen',
      subtitle: 'Mevcut bir kliniği hesabınıza bağlamak için talep gönderin.',
      icon: Icons.key_outlined,
      accent: PatifyTheme.accent,
    ),
    _VeterinarianMenuItem(
      keyName: 'addClinic',
      title: 'Yeni Klinik Ekle',
      subtitle: 'Yeni klinik kaydı alanı daha sonra açılacak.',
      icon: Icons.add_business_outlined,
      accent: PatifyTheme.secondary,
    ),
    _VeterinarianMenuItem(
      keyName: 'clinicInfo',
      title: 'Klinik Bilgilerim',
      subtitle: 'Klinik detaylarınızı ve görünürlüğünüzü yöneteceğiniz alan.',
      icon: Icons.badge_outlined,
      accent: PatifyTheme.info,
    ),
    _VeterinarianMenuItem(
      keyName: 'calendar',
      title: 'Randevu Takvimi',
      subtitle: 'Takvim ve uygunluk yönetimi bu kart üzerinden açılacak.',
      icon: Icons.calendar_month_outlined,
      accent: PatifyTheme.success,
    ),
    _VeterinarianMenuItem(
      keyName: 'appointments',
      title: 'Gelen Randevular',
      subtitle: 'Onaylı klinik hesabınız için randevu talepleri burada görünecek.',
      icon: Icons.notifications_active_outlined,
      accent: PatifyTheme.danger,
    ),
  ];

  VeterinarianClaimStatusResponse? _claimStatus;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClaimStatus();
  }

  Future<void> _loadClaimStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final status = await VeterinarianClaimService.fetchClaimStatus();
      if (!mounted) return;
      setState(() => _claimStatus = status);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('AUTH_TOKEN_MISSING') ||
        message.contains('AUTHORIZATION_REQUIRED')) {
      return 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yap.';
    }
    if (message.contains('VETERINARIAN_ROLE_REQUIRED')) {
      return 'Bu panel sadece veteriner hesapları için kullanılabilir.';
    }
    if (message.contains('Connection refused') ||
        message.contains('SocketException')) {
      return 'Sunucuya bağlanılamadı. Lütfen daha sonra tekrar dene.';
    }
    return 'Klinik durumu alınamadı. Lütfen tekrar dene.';
  }

  Future<void> _handleAction(_VeterinarianMenuItem item) async {
    switch (item.keyName) {
      case 'claim':
        final refreshed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const VeterinarianClaimClinicScreen(),
          ),
        );
        if (refreshed == true) {
          await _loadClaimStatus();
        }
        return;
      case 'clinicInfo':
      case 'calendar':
      case 'appointments':
        if (_claimStatus?.isApproved != true) {
          _showSnackBar('Bu özellik için klinik onayı gerekiyor.');
          return;
        }
        _showSnackBar('Bu özellik yakında eklenecek.');
        return;
      default:
        _showSnackBar('Bu özellik yakında eklenecek.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final firstName = widget.user.firstName?.trim();
    final displayName = firstName != null && firstName.isNotEmpty
        ? firstName
        : widget.user.displayName;

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
          child: RefreshIndicator(
            onRefresh: _loadClaimStatus,
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
                    _HeroCard(
                      displayName: displayName,
                      textTheme: textTheme,
                      cardColor: theme.cardColor,
                    ),
                    const SizedBox(height: PatifyTheme.space20),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(PatifyTheme.space24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _StatusMessageCard(
                        title: 'Klinik durumu yüklenemedi',
                        subtitle: _error!,
                        accent: PatifyTheme.danger,
                        actionLabel: 'Tekrar Dene',
                        onTap: _loadClaimStatus,
                      )
                    else
                      _ClaimStatusCard(status: _claimStatus),
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
                          onTap: () => _handleAction(item),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.displayName,
    required this.textTheme,
    required this.cardColor,
  });

  final String displayName;
  final TextTheme textTheme;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius24),
        border: Border.all(color: PatifyTheme.border),
        boxShadow: [
          BoxShadow(
            color: PatifyTheme.textPrimary.withValues(alpha: 0.08),
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
              borderRadius: BorderRadius.circular(PatifyTheme.radius20),
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
              borderRadius: BorderRadius.circular(PatifyTheme.radius16),
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
    );
  }
}

class _ClaimStatusCard extends StatelessWidget {
  const _ClaimStatusCard({
    required this.status,
  });

  final VeterinarianClaimStatusResponse? status;

  @override
  Widget build(BuildContext context) {
    final claimStatus = status?.status ?? 'NONE';
    final institution = status?.institution;

    late final String title;
    late final String subtitle;
    late final Color accent;

    switch (claimStatus) {
      case 'PENDING':
        title = 'Sahiplenme talebiniz onay bekliyor';
        subtitle =
            'Talebiniz admin tarafından onaylandığında durumunuz güncellenecek.';
        accent = PatifyTheme.accent;
        break;
      case 'APPROVED':
        title = 'Klinik onaylandı';
        subtitle = 'Veteriner hesabınız seçili klinik ile eşleşti.';
        accent = PatifyTheme.success;
        break;
      case 'REJECTED':
        title = 'Sahiplenme talebiniz reddedildi';
        subtitle =
            'Tekrar talep gönderebilir veya farklı bir klinik seçebilirsiniz.';
        accent = PatifyTheme.danger;
        break;
      default:
        title = 'Henüz kliniğiniz bağlı değil';
        subtitle = 'Kliniğinizi sahiplenin veya yeni klinik ekleyin.';
        accent = PatifyTheme.info;
    }

    return _StatusMessageCard(
      title: title,
      subtitle: subtitle,
      accent: accent,
      detailTitle: institution?.name,
      detailSubtitle: institution?.address ?? institution?.email,
    );
  }
}

class _StatusMessageCard extends StatelessWidget {
  const _StatusMessageCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    this.detailTitle,
    this.detailSubtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final String? detailTitle;
  final String? detailSubtitle;
  final String? actionLabel;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PatifyTheme.textPrimary,
                ),
          ),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PatifyTheme.textPrimary,
                ),
          ),
          if (detailTitle != null) ...[
            const SizedBox(height: PatifyTheme.space16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PatifyTheme.space16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(PatifyTheme.radius16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detailTitle!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (detailSubtitle != null) ...[
                    const SizedBox(height: PatifyTheme.space8),
                    Text(
                      detailSubtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: PatifyTheme.space16),
            TextButton(
              onPressed: () => onTap!.call(),
              child: Text(actionLabel!),
            ),
          ],
        ],
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
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String keyName;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
