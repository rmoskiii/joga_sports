import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// "Label ........ £8.00" line for price breakdowns and summaries.
class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.color,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = (strong ? AppText.bodyStrong : AppText.body).copyWith(
      color: color ?? AppColors.textPrimary,
      fontSize: strong ? 17 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: style.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin divider in the app's line colour.
class JogaDivider extends StatelessWidget {
  const JogaDivider({super.key, this.spacing = Space.sm});

  final double spacing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: spacing),
        child: const Divider(height: 1, color: AppColors.line),
      );
}
