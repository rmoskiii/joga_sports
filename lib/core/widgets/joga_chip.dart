import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum ChipTone { normal, selected, danger, fire, muted }

/// Small pill for filters, status and tags.
class JogaChip extends StatelessWidget {
  const JogaChip({
    super.key,
    required this.label,
    this.tone = ChipTone.normal,
    this.icon,
    this.onTap,
  });

  /// A filter chip that toggles between normal and selected.
  factory JogaChip.filter({
    Key? key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      JogaChip(
        key: key,
        label: label,
        tone: selected ? ChipTone.selected : ChipTone.normal,
        onTap: onTap,
      );

  final String label;
  final ChipTone tone;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      ChipTone.normal => (
          AppColors.surfaceRaised,
          AppColors.textPrimary,
          AppColors.line,
        ),
      ChipTone.selected => (AppColors.lime, AppColors.onLime, AppColors.lime),
      ChipTone.danger => (
          AppColors.danger.withValues(alpha: 0.12),
          AppColors.danger,
          AppColors.danger.withValues(alpha: 0.4),
        ),
      ChipTone.fire => (
          AppColors.fire.withValues(alpha: 0.12),
          AppColors.fire,
          AppColors.fire.withValues(alpha: 0.4),
        ),
      ChipTone.muted => (
          Colors.transparent,
          AppColors.textMuted,
          AppColors.line,
        ),
    };

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.md - 1,
            vertical: Space.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: Space.xs),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of chips.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: Space.xs + 2),
            children[i],
          ],
        ],
      ),
    );
  }
}
