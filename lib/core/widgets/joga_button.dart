import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum JogaButtonVariant { primary, secondary, ghost }

/// The app's button. Full width by default, upper-case label.
class JogaButton extends StatelessWidget {
  const JogaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = JogaButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  const JogaButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  }) : variant = JogaButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final JogaButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (bg, fg, border) = switch (variant) {
      JogaButtonVariant.primary => (
          AppColors.lime,
          AppColors.onLime,
          AppColors.lime,
        ),
      JogaButtonVariant.secondary => (
          AppColors.surfaceRaised,
          AppColors.textPrimary,
          AppColors.line,
        ),
      JogaButtonVariant.ghost => (
          Colors.transparent,
          AppColors.lime,
          Colors.transparent,
        ),
    };

    final content = loading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: Space.sm),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  style: AppText.button.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled || loading ? 1 : 0.4,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Container(
            width: expand ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
