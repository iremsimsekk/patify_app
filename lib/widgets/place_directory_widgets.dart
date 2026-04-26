import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/google_places_service.dart';
import '../theme/patify_theme.dart';

class DirectoryHero extends StatelessWidget {
  const DirectoryHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.resultCount,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    this.isRefreshing = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int resultCount;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PatifyTheme.radius24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PatifyTheme.backgroundSoft,
            PatifyTheme.surfaceRaised,
          ],
        ),
        border: Border.all(
          color: isRefreshing ? PatifyTheme.primarySoft : PatifyTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: PatifyTheme.textPrimary.withValues(
              alpha: isRefreshing ? 0.09 : 0.06,
            ),
            blurRadius: isRefreshing ? 34 : 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedScale(
                scale: isRefreshing ? 1.04 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: PatifyTheme.primarySoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: PatifyTheme.primary),
                ),
              ),
              const Spacer(),
              _InfoBadge(
                icon: Icons.place_outlined,
                label: '$resultCount sonuç',
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space20),
          Text(title, style: theme.textTheme.displayMedium),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PatifyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: PatifyTheme.space16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, -0.08),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: isRefreshing
                ? const _InlineStatusPill(
                    key: ValueKey('refreshing'),
                    icon: Icons.refresh_rounded,
                    text: 'Liste yenileniyor',
                  )
                : const SizedBox.shrink(key: ValueKey('idle')),
          ),
          SizedBox(
              height: isRefreshing ? PatifyTheme.space20 : PatifyTheme.space12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPrimaryAction,
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(primaryActionLabel),
                ),
              ),
              const SizedBox(width: PatifyTheme.space12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSecondaryAction,
                  icon: AnimatedRotation(
                    turns: isRefreshing ? 0.15 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.refresh_rounded),
                  ),
                  label: Text(secondaryActionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DirectoryFilterRow extends StatelessWidget {
  const DirectoryFilterRow({
    super.key,
    required this.districtLabel,
    required this.ratingLabel,
  });

  final String districtLabel;
  final String ratingLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: Wrap(
        key: ValueKey('$districtLabel|$ratingLabel'),
        spacing: PatifyTheme.space8,
        runSpacing: PatifyTheme.space8,
        children: [
          _FilterChip(
            icon: Icons.location_on_outlined,
            label: districtLabel,
          ),
          _FilterChip(
            icon: Icons.star_outline_rounded,
            label: ratingLabel,
          ),
        ],
      ),
    );
  }
}

class DirectoryStateSwitcher extends StatelessWidget {
  const DirectoryStateSwitcher({
    super.key,
    required this.child,
    required this.stateKey,
  });

  final Widget child;
  final String stateKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(stateKey),
        child: child,
      ),
    );
  }
}

class DirectoryStateCard extends StatelessWidget {
  const DirectoryStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PatifyTheme.space20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: PatifyTheme.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: PatifyTheme.primary),
                  ),
                  const SizedBox(height: PatifyTheme.space16),
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: PatifyTheme.space8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: PatifyTheme.space20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DirectoryLoadingView extends StatelessWidget {
  const DirectoryLoadingView({
    super.key,
    required this.label,
    this.itemCount = 4,
  });

  final String label;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PatifyTheme.space20,
        PatifyTheme.space12,
        PatifyTheme.space20,
        PatifyTheme.space28,
      ),
      children: [
        DirectoryStateCard(
          icon: Icons.sync_rounded,
          title: 'İçerik yükleniyor',
          message: label,
        ),
        const SizedBox(height: PatifyTheme.space12),
        ...List.generate(
          itemCount,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: PatifyTheme.space12),
            child: DirectorySkeletonCard(),
          ),
        ),
      ],
    );
  }
}

class DirectorySkeletonCard extends StatefulWidget {
  const DirectorySkeletonCard({super.key});

  @override
  State<DirectorySkeletonCard> createState() => _DirectorySkeletonCardState();
}

class _DirectorySkeletonCardState extends State<DirectorySkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final alpha = 0.32 + (_controller.value * 0.26);
        final color = PatifyTheme.divider.withValues(alpha: alpha);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 48,
                      height: 48,
                      color: color,
                      radius: 16,
                    ),
                    const SizedBox(width: PatifyTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            width: double.infinity,
                            height: 16,
                            color: color,
                            radius: 8,
                          ),
                          const SizedBox(height: PatifyTheme.space8),
                          _SkeletonBox(
                            width: 120,
                            height: 12,
                            color: color,
                            radius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PatifyTheme.space16),
                Wrap(
                  spacing: PatifyTheme.space8,
                  runSpacing: PatifyTheme.space8,
                  children: [
                    _SkeletonBox(
                      width: 126,
                      height: 32,
                      color: color,
                      radius: 999,
                    ),
                    _SkeletonBox(
                      width: 88,
                      height: 32,
                      color: color,
                      radius: 999,
                    ),
                  ],
                ),
                const SizedBox(height: PatifyTheme.space16),
                _SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  color: color,
                  radius: 8,
                ),
                const SizedBox(height: PatifyTheme.space8),
                _SkeletonBox(
                  width: math.max(MediaQuery.sizeOf(context).width * 0.35, 180),
                  height: 12,
                  color: color,
                  radius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PlaceResultCard extends StatefulWidget {
  const PlaceResultCard({
    super.key,
    required this.place,
    required this.categoryLabel,
    required this.locationLabel,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.index,
  });

  final PlaceSummary place;
  final String categoryLabel;
  final String locationLabel;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final int index;

  @override
  State<PlaceResultCard> createState() => _PlaceResultCardState();
}

class _PlaceResultCardState extends State<PlaceResultCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = widget.place.rating;
    final total = widget.place.userRatingsTotal;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 180 + (widget.index * 28)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PatifyTheme.radius20),
            boxShadow: [
              BoxShadow(
                color: PatifyTheme.textPrimary.withValues(
                  alpha: _pressed ? 0.04 : 0.07,
                ),
                blurRadius: _pressed ? 14 : 22,
                offset: Offset(0, _pressed ? 6 : 10),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(PatifyTheme.radius20),
              splashColor: widget.iconColor.withValues(alpha: 0.08),
              highlightColor: widget.iconColor.withValues(alpha: 0.04),
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapCancel: () => _setPressed(false),
              onTapUp: (_) => _setPressed(false),
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(
                              alpha: _pressed ? 0.18 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(widget.icon, color: widget.iconColor),
                        ),
                        const SizedBox(width: PatifyTheme.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.place.name,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: PatifyTheme.space4),
                              Text(
                                widget.categoryLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: PatifyTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: PatifyTheme.space12),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 180),
                          offset:
                              _pressed ? const Offset(0.08, 0) : Offset.zero,
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: PatifyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    Wrap(
                      spacing: PatifyTheme.space8,
                      runSpacing: PatifyTheme.space8,
                      children: [
                        _InfoBadge(
                          icon: Icons.location_on_outlined,
                          label: widget.locationLabel,
                        ),
                        _InfoBadge(
                          icon: Icons.star_rounded,
                          label: rating != null
                              ? rating.toStringAsFixed(1)
                              : 'Puan yok',
                          accent: PatifyTheme.accent,
                        ),
                        if (total != null)
                          _InfoBadge(
                            icon: Icons.rate_review_outlined,
                            label: '$total değerlendirme',
                          ),
                      ],
                    ),
                    if (widget.place.address != null &&
                        widget.place.address!.trim().isNotEmpty) ...[
                      const SizedBox(height: PatifyTheme.space16),
                      Text(
                        'Adres',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: PatifyTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: PatifyTheme.space4),
                      Text(
                        widget.place.address!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                    if (widget.place.phone != null &&
                        widget.place.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: PatifyTheme.space12),
                      Text(
                        'Telefon',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: PatifyTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: PatifyTheme.space4),
                      Text(
                        widget.place.phone!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RefreshFeedback {
  static void show(
    BuildContext context, {
    required String message,
    required bool success,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: PatifyTheme.space8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _InlineStatusPill extends StatelessWidget {
  const _InlineStatusPill({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: PatifyTheme.space12,
        vertical: PatifyTheme.space12,
      ),
      decoration: BoxDecoration(
        color: PatifyTheme.surfaceRaised.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: PatifyTheme.textSecondary),
          const SizedBox(width: PatifyTheme.space8),
          Text(text),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: PatifyTheme.space12,
        vertical: PatifyTheme.space8,
      ),
      decoration: BoxDecoration(
        color: PatifyTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: PatifyTheme.textSecondary),
          const SizedBox(width: PatifyTheme.space8),
          Text(label),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    this.accent,
  });

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? PatifyTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PatifyTheme.space12,
        vertical: PatifyTheme.space8,
      ),
      decoration: BoxDecoration(
        color: PatifyTheme.backgroundSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: PatifyTheme.space8),
          Text(label),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
