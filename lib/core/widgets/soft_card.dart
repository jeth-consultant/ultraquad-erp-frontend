import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A card with a soft shadow + hairline border, used in place of flat
/// AI-generated-looking containers. [radius] is deliberately varied a
/// little between call sites rather than locked to one constant.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius = 18,
    this.borderColor,
    this.margin,
    this.topAccentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  /// Draws a thick colored line across the top edge of the card — used
  /// on dashboard stat cards to color-code each metric.
  final Color? topAccentColor;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: borderColor ?? AppColors.border);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: topAccentColor == null
            ? border
            : Border(top: BorderSide(color: topAccentColor!, width: 3), left: border.left, right: border.right, bottom: border.bottom),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

/// A small rounded status label, e.g. "PAID" / "UNPAID" / "WAIVED".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    );
  }
}
