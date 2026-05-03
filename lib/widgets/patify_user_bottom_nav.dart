import 'package:flutter/material.dart';

import '../config/api_keys.dart';
import '../services/app_preferences.dart';
import '../theme/patify_theme.dart';
import '../screens/appointments_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_wrapper.dart';

enum PatifyUserNavItem { home, services, map, appointments, profile }

class PatifyUserBottomNav extends StatelessWidget {
  const PatifyUserBottomNav({
    super.key,
    required this.current,
  });

  final PatifyUserNavItem current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        PatifyTheme.space16,
        0,
        PatifyTheme.space16,
        PatifyTheme.space12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PatifyTheme.space8,
          vertical: PatifyTheme.space8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: PatifyTheme.border),
          boxShadow: [
            BoxShadow(
              color: PatifyTheme.textPrimary.withValues(alpha: 0.10),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavButton(
              label: 'Ana Sayfa',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              selected: current == PatifyUserNavItem.home,
              onTap: () => _openRoot(context, 0),
            ),
            _NavButton(
              label: 'Hizmetler',
              icon: Icons.pets_outlined,
              selectedIcon: Icons.pets_rounded,
              selected: current == PatifyUserNavItem.services,
              onTap: () => _openRoot(context, 1),
            ),
            _NavButton(
              label: 'Harita',
              icon: Icons.map_outlined,
              selectedIcon: Icons.map_rounded,
              selected: current == PatifyUserNavItem.map,
              onTap: () => _openRoot(context, 3),
            ),
            _NavButton(
              label: 'Randevular',
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              selected: current == PatifyUserNavItem.appointments,
              onTap: () => _openAppointments(context),
            ),
            _NavButton(
              label: 'Profil',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              selected: current == PatifyUserNavItem.profile,
              onTap: () => _openRoot(context, 4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRoot(BuildContext context, int index) async {
    if ((index == 4 || index == 1 || index == 3 || index == 0) &&
        current.index ==
            PatifyUserNavItem.values.indexWhere((item) {
              switch (index) {
                case 0:
                  return item == PatifyUserNavItem.home;
                case 1:
                  return item == PatifyUserNavItem.services;
                case 3:
                  return item == PatifyUserNavItem.map;
                case 4:
                  return item == PatifyUserNavItem.profile;
                default:
                  return false;
              }
            })) {
      return;
    }

    final user = await AppPreferences.loadCurrentUser();
    if (!context.mounted) return;
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainWrapper(
          currentUser: user,
          apiKey: ApiKeys.googleMaps,
          initialIndex: index,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _openAppointments(BuildContext context) async {
    if (current == PatifyUserNavItem.appointments) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
      (route) => false,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface =
        theme.textTheme.bodyMedium?.color ?? PatifyTheme.textSecondary;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: PatifyTheme.space8,
              vertical: PatifyTheme.space8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: selected ? 22 : 20,
                  color: selected ? primary : onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? primary : onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
