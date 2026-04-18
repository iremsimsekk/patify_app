import 'package:flutter/material.dart';

class PatiSurfaceCard extends StatelessWidget {
  const PatiSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 30,
    this.color,
    this.borderOpacity = 0.72,
    this.shadowOpacity = 0.045,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final double borderOpacity;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: borderOpacity),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PatiBadge extends StatelessWidget {
  const PatiBadge({
    super.key,
    required this.label,
    required this.tintColor,
  });

  final String label;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class PatiIconContainer extends StatelessWidget {
  const PatiIconContainer({
    super.key,
    required this.icon,
    required this.startColor,
    required this.endColor,
    this.overlayIcon,
    this.showOverlayDot = false,
    this.size = 68,
    this.radius = 24,
    this.iconSize = 30,
  });

  final IconData icon;
  final Color startColor;
  final Color endColor;
  final IconData? overlayIcon;
  final bool showOverlayDot;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showOverlayDot)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          if (overlayIcon != null)
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                overlayIcon,
                size: 15,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          Icon(
            icon,
            color: colorScheme.onSurface,
            size: iconSize,
          ),
        ],
      ),
    );
  }
}

class PatiArrowChip extends StatelessWidget {
  const PatiArrowChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: colorScheme.onSurface.withValues(alpha: 0.62),
      ),
    );
  }
}
