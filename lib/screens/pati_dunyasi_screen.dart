import 'package:flutter/material.dart';

import 'pati_keyfi_screen.dart';
import 'rehber_screen.dart';

class PatiDunyasiScreen extends StatelessWidget {
  const PatiDunyasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pati Dünyası'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin!',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patili dostunla ilgili hem faydalı hem keyifli içerikleri burada bulabilirsin.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _PatiDunyasiCard(
              title: 'Rehber',
              subtitle: 'Patili dostun için kısa ve faydalı bilgiler',
              icon: Icons.auto_stories_rounded,
              accentColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.55),
              illustrationIcon: Icons.pets_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RehberScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PatiDunyasiCard(
              title: 'Pati Keyfi',
              subtitle: 'Tatlı, eğlenceli ve keyifli içerikler',
              icon: Icons.celebration_rounded,
              accentColor: colorScheme.secondary,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.45),
              illustrationIcon: Icons.favorite_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatiKeyfiScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PatiDunyasiCard extends StatelessWidget {
  const _PatiDunyasiCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.illustrationIcon,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData illustrationIcon;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(28),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Icon(
                            illustrationIcon,
                            color: accentColor.withValues(alpha: 0.35),
                            size: 20,
                          ),
                        ),
                        Icon(
                          icon,
                          color: colorScheme.onSurface,
                          size: 34,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.74),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
