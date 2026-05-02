import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/appointment_slot.dart';
import '../services/appointment_service.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';
import 'veterinarian_calendar_screen.dart';
import 'veterinarian_claim_clinic_screen.dart';
import 'veterinarian_create_slots_screen.dart';
import 'veterinarian_profile_screen.dart';
import 'veterinarian_settings_screen.dart';

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
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  VeterinarianClaimStatusResponse? _claimStatus;
  VeterinarianAppointmentSummary? _todaySummary;

  @override
  void initState() {
    super.initState();
    _reloadDashboard();
  }

  Future<void> _reloadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final claimStatus = await VeterinarianClaimService.fetchClaimStatus();
      VeterinarianAppointmentSummary? summary;
      if (claimStatus.isApproved) {
        summary = await AppointmentService.fetchVeterinarianSummary(
          date: DateUtils.dateOnly(DateTime.now()),
        );
      }

      if (!mounted) return;
      setState(() {
        _claimStatus = claimStatus;
        _todaySummary = summary;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openClaimFlow() async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const VeterinarianClaimClinicScreen(),
      ),
    );

    if (refreshed == true) {
      await _reloadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _VeterinarianHomeTab(
        user: widget.user,
        loading: _loading,
        error: _error,
        claimStatus: _claimStatus,
        summary: _todaySummary,
        onRefresh: _reloadDashboard,
        onClaimTap: _openClaimFlow,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      VeterinarianCalendarScreen(
        claimStatus: _claimStatus,
        onSlotsChanged: _reloadDashboard,
      ),
      VeterinarianCreateSlotsScreen(
        claimStatus: _claimStatus,
        onSlotsCreated: _reloadDashboard,
      ),
      VeterinarianProfileScreen(
        user: widget.user,
        claimStatus: _claimStatus,
        onClaimRequested: _openClaimFlow,
      ),
      VeterinarianSettingsScreen(user: widget.user),
    ];

    return Scaffold(
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
          child: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded),
            label: 'Slot Aç',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
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
    return 'Veteriner paneli yüklenemedi. Lütfen tekrar dene.';
  }
}

class _VeterinarianHomeTab extends StatelessWidget {
  const _VeterinarianHomeTab({
    required this.user,
    required this.loading,
    required this.error,
    required this.claimStatus,
    required this.summary,
    required this.onRefresh,
    required this.onClaimTap,
    required this.onNavigate,
  });

  final AppUser user;
  final bool loading;
  final String? error;
  final VeterinarianClaimStatusResponse? claimStatus;
  final VeterinarianAppointmentSummary? summary;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onClaimTap;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final institution = claimStatus?.institution;
    final approved = claimStatus?.isApproved == true;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space16,
          PatifyTheme.space20,
          PatifyTheme.space28,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(PatifyTheme.space24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PatifyTheme.radius24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFCE9E2),
                  Color(0xFFF7F3EC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: PatifyTheme.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius:
                            BorderRadius.circular(PatifyTheme.radius20),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: PatifyTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    _StatusPill(
                      label: _statusLabel(claimStatus?.status),
                      color: _statusColor(claimStatus?.status),
                    ),
                  ],
                ),
                const SizedBox(height: PatifyTheme.space20),
                Text(
                  institution?.name ?? user.displayName,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: PatifyTheme.space8),
                Text(
                  approved
                      ? 'Bugünkü randevu akışını, takvimi ve kliniğinin görünürlüğünü tek yerden yönet.'
                      : 'Klinik onayı tamamlandığında takvim, slot oluşturma ve randevu yönetimi otomatik açılacak.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: PatifyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: PatifyTheme.space16),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMeta(
                        label: 'Veteriner',
                        value: user.displayName,
                      ),
                    ),
                    const SizedBox(width: PatifyTheme.space12),
                    Expanded(
                      child: _HeroMeta(
                        label: 'Bugün',
                        value: summary?.bookedSlots.toString() ?? '--',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PatifyTheme.space20),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(PatifyTheme.space24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Text(error!, style: theme.textTheme.bodyMedium),
              ),
            )
          else ...[
            if (!approved)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Klinik onayı gerekiyor',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: PatifyTheme.space8),
                      Text(
                        claimStatus?.status == 'PENDING'
                            ? 'Talebin incelemede. Onay geldikten sonra tüm veteriner özellikleri otomatik açılacak.'
                            : 'Önce bir klinik ile eşleşme talebi gönder. Onay sonrasında gerçek randevu sistemi aktif olacak.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: PatifyTheme.space16),
                      ElevatedButton.icon(
                        onPressed: onClaimTap,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: Text(
                          claimStatus?.status == 'PENDING'
                              ? 'Talep durumunu gör'
                              : 'Klinik sahiplen',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: PatifyTheme.space12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 720 ? 2 : 1,
              crossAxisSpacing: PatifyTheme.space12,
              mainAxisSpacing: PatifyTheme.space12,
              childAspectRatio:
                  MediaQuery.of(context).size.width > 720 ? 1.5 : 2.25,
              children: [
                _StatCard(
                  title: 'Bugünkü Randevular',
                  value: approved ? '${summary?.bookedSlots ?? 0}' : '--',
                  subtitle: 'Alınmış randevular',
                  icon: Icons.event_available_outlined,
                  accent: PatifyTheme.primary,
                ),
                _StatCard(
                  title: 'Açık Randevu Slotları',
                  value: approved ? '${summary?.availableSlots ?? 0}' : '--',
                  subtitle: 'Müsait saatler',
                  icon: Icons.grid_view_rounded,
                  accent: PatifyTheme.success,
                ),
                _StatCard(
                  title: 'Bekleyen / Alınmış',
                  value: approved
                      ? '${summary?.availableSlots ?? 0} / ${summary?.bookedSlots ?? 0}'
                      : '--',
                  subtitle: 'Müsait ve dolu denge',
                  icon: Icons.pie_chart_outline_rounded,
                  accent: PatifyTheme.accent,
                ),
                _StatCard(
                  title: 'Profil Bilgilerim',
                  value: institution?.name ?? 'Hazırlanıyor',
                  subtitle:
                      approved ? 'Klinik profili bağlı' : 'Onay bekleniyor',
                  icon: Icons.badge_outlined,
                  accent: PatifyTheme.info,
                ),
              ],
            ),
            const SizedBox(height: PatifyTheme.space20),
            Text('Hızlı geçişler', style: theme.textTheme.titleMedium),
            const SizedBox(height: PatifyTheme.space12),
            _QuickActionCard(
              title: 'Takvimi yönet',
              subtitle: approved
                  ? 'Gün seç, slotları gör ve boş saatleri iptal et.'
                  : 'Klinik onayı sonrası aktif olacak.',
              icon: Icons.calendar_month_outlined,
              onTap: approved ? () => onNavigate(1) : null,
            ),
            _QuickActionCard(
              title: 'Yeni slot aç',
              subtitle: approved
                  ? 'Saat aralığı gir, sistem slotları otomatik oluştursun.'
                  : 'Klinik onayı gerekiyor.',
              icon: Icons.add_box_outlined,
              onTap: approved ? () => onNavigate(2) : null,
            ),
            _QuickActionCard(
              title: 'Profili gözden geçir',
              subtitle: 'Klinik bilgileri ve görünür profil alanlarını incele.',
              icon: Icons.account_box_outlined,
              onTap: () => onNavigate(3),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'APPROVED':
        return 'Onaylı';
      case 'PENDING':
        return 'İnceleniyor';
      case 'REJECTED':
        return 'Reddedildi';
      default:
        return 'Onay bekliyor';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'APPROVED':
        return PatifyTheme.success;
      case 'PENDING':
        return PatifyTheme.accent;
      case 'REJECTED':
        return PatifyTheme.danger;
      default:
        return PatifyTheme.info;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PatifyTheme.radius16),
            ),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accent,
                ),
          ),
          const SizedBox(height: PatifyTheme.space4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(PatifyTheme.space16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                (onTap == null ? PatifyTheme.border : PatifyTheme.primarySoft),
            borderRadius: BorderRadius.circular(PatifyTheme.radius16),
          ),
          child: Icon(
            icon,
            color:
                onTap == null ? PatifyTheme.textSecondary : PatifyTheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: PatifyTheme.space4),
          child: Text(subtitle),
        ),
        trailing: Icon(
          onTap == null
              ? Icons.lock_outline_rounded
              : Icons.arrow_forward_rounded,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PatifyTheme.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PatifyTheme.textSecondary,
                ),
          ),
          const SizedBox(height: PatifyTheme.space4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PatifyTheme.space12,
        vertical: PatifyTheme.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
            ),
      ),
    );
  }
}
