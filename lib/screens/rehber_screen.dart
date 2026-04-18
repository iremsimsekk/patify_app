import 'package:flutter/material.dart';

import '../data/guide_mock_data.dart';
import '../widgets/pati_module_ui.dart';
import 'rehber_detail_screen.dart';

class RehberScreen extends StatelessWidget {
  const RehberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehber'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            padding: const EdgeInsets.all(20),
            radius: 24,
            color: Colors.white.withValues(alpha: 0.45),
            borderOpacity: 0,
            shadowOpacity: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kısa ve faydalı bilgiler',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patili dostunun bakımı, günlük rutini ve dikkat etmen gereken temel konulara dair içerikleri burada bulabilirsin.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...mockGuideArticles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _GuideListCard(article: article),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideListCard extends StatelessWidget {
  const _GuideListCard({required this.article});

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RehberDetailScreen(article: article),
            ),
          );
        },
        child: PatiSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          radius: 28,
          color: Colors.white.withValues(alpha: 0.66),
          shadowOpacity: 0.05,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatiIconContainer(
                icon: article.icon,
                startColor: colorScheme.primary.withValues(alpha: 0.62),
                endColor: colorScheme.secondary.withValues(alpha: 0.42),
                showOverlayDot: true,
                size: 68,
                radius: 22,
                iconSize: 31,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiBadge(
                      label: 'Bakım Rehberi',
                      tintColor: colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: PatiArrowChip(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
