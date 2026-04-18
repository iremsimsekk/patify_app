import 'package:flutter/material.dart';

import '../data/guide_mock_data.dart';
import '../widgets/pati_module_ui.dart';

class RehberDetailScreen extends StatelessWidget {
  const RehberDetailScreen({
    super.key,
    required this.article,
  });

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PatiBadge(
                  label: 'Bakım Rehberi',
                  tintColor: colorScheme.secondary,
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiIconContainer(
                      icon: article.icon,
                      startColor: colorScheme.primary.withValues(alpha: 0.62),
                      endColor: colorScheme.secondary.withValues(alpha: 0.4),
                      size: 68,
                      radius: 24,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.intro,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.76,
                              ),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Kısa notlar',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
            child: Column(
              children: article.bullets
                  .map(
                    (bullet) => _BulletItem(
                      bullet: bullet,
                      isLast: identical(bullet, article.bullets.last),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _InfoBox(
            title: 'İpucu',
            icon: Icons.lightbulb_outline_rounded,
            backgroundColor: const Color(0xFFF8F7BA).withValues(alpha: 0.66),
            content: article.tip,
          ),
          const SizedBox(height: 14),
          _InfoBox(
            title: 'Veteriner notu',
            icon: Icons.local_hospital_outlined,
            backgroundColor: const Color(0xFFA3CCDA).withValues(alpha: 0.36),
            content: article.vetNote,
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({
    required this.bullet,
    required this.isLast,
  });

  final String bullet;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              bullet,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.content,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PatiSurfaceCard(
      padding: const EdgeInsets.all(18),
      radius: 24,
      color: backgroundColor,
      shadowOpacity: 0.035,
      borderOpacity: 0.55,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
