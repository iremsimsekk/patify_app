import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/patify_theme.dart';
import 'ai_chat_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'pati_dunyasi_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({
    super.key,
    required this.currentUser,
    required this.apiKey,
  });

  final AppUser currentUser;
  final String apiKey;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late final List<Widget?> _loadedPages;
  late AppUser _currentUser;

  final List<_NavItem> _destinations = const [
    _NavItem(
      label: 'Ana Sayfa',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Hizmetler',
      icon: Icons.pets_outlined,
      selectedIcon: Icons.pets_rounded,
    ),
    _NavItem(
      label: 'AI',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
    ),
    _NavItem(
      label: 'Harita',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _NavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    _loadedPages = List<Widget?>.filled(_destinations.length, null);
    _loadedPages[0] = _buildPage(0);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          currentUser: _currentUser,
          apiKey: widget.apiKey,
        );
      case 1:
        return PatiDunyasiScreen(currentUser: _currentUser);
      case 2:
        return const AiChatScreen();
      case 3:
        return MapScreen(
          apiKey: widget.apiKey,
          currentUser: _currentUser,
        );
      case 4:
        return ProfileScreen(
          currentUser: _currentUser,
          onUserUpdated: _handleUserUpdated,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
      _loadedPages[index] ??= _buildPage(index);
    });
  }

  void _handleUserUpdated(AppUser user) {
    setState(() {
      _currentUser = user;
      _loadedPages[0] = _buildPage(0);
      _loadedPages[1] = _buildPage(1);
      _loadedPages[4] = _buildPage(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.22)
        : PatifyTheme.textPrimary.withValues(alpha: 0.10);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.015, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: _loadedPages
              .map((page) => page ?? const SizedBox.shrink())
              .toList(growable: false),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                color: shadowColor,
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              _destinations.length,
              (index) => Expanded(
                child: _BottomNavItem(
                  item: _destinations[index],
                  selected: _currentIndex == index,
                  onTap: () => _onDestinationSelected(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface =
        theme.textTheme.bodyMedium?.color ?? PatifyTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: selected ? 1 : 0, end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: PatifyTheme.space8,
                  vertical: PatifyTheme.space8,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.transparent,
                    primary.withValues(alpha: 0.14),
                    value,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected
                            ? primary.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        selected ? item.selectedIcon : item.icon,
                        size: selected ? 22 : 21,
                        color: selected ? primary : onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: selected ? primary : onSurface,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
