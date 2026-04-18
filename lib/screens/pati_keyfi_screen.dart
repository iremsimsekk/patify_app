import 'package:flutter/material.dart';

import '../data/pati_keyfi_mock_data.dart';
import '../widgets/pati_module_ui.dart';
import 'pati_keyfi_detail_screen.dart';

class PatiKeyfiScreen extends StatelessWidget {
  const PatiKeyfiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pati Keyfi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PatiIconContainer(
                  icon: Icons.celebration_rounded,
                  startColor: colorScheme.primary.withValues(alpha: 0.62),
                  endColor: colorScheme.secondary.withValues(alpha: 0.42),
                  showOverlayDot: true,
                  size: 72,
                  radius: 24,
                  iconSize: 34,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PatiBadge(
                        label: 'İçerik Seçkisi',
                        tintColor: colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Daha hafif, daha keyifli',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Burada gülümseten, hafif ve keyifli içerikleri bir arada bulabilirsin. Her başlık, uygulamanın sıcak diline uyumlu kısa bir keşif alanı sunar.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.74),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...mockFunArticles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PatiKeyfiCard(article: article),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatiKeyfiCard extends StatelessWidget {
  const _PatiKeyfiCard({required this.article});

  final FunArticle article;

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
              builder: (_) => PatiKeyfiDetailScreen(article: article),
            ),
          );
        },
        child: PatiSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          radius: 28,
          color: Colors.white.withValues(alpha: 0.64),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatiIconContainer(
                icon: article.icon,
                startColor: colorScheme.primary.withValues(alpha: 0.58),
                endColor: colorScheme.secondary.withValues(alpha: 0.38),
                overlayIcon: article.moodIcon,
                size: 68,
                radius: 22,
                iconSize: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiBadge(
                      label: 'Keyifli İçerik',
                      tintColor: colorScheme.primary,
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
