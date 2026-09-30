import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// A big number with a small label underneath.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
  });

  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Space.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          if (icon != null)
            Icon(icon, size: 26, color: valueColor ?? AppColors.lime)
          else
            Text(
              value,
              style: AppText.number.copyWith(color: valueColor),
            ),
          const SizedBox(height: Space.xs),
          Text(
            label.toUpperCase(),
            style: AppText.tiny.copyWith(letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}

/// Equal-width row of [StatTile]s.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.tiles});

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: Space.sm),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}
