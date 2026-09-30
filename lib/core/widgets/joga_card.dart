import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum CardTone { normal, lime, fire }

/// Surface for grouped content. Use [tone] to draw attention sparingly.
class JogaCard extends StatelessWidget {
  const JogaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.md),
    this.onTap,
    this.tone = CardTone.normal,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final CardTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color border, Gradient? gradient) = switch (tone) {
      CardTone.normal => (AppColors.line, null),
      CardTone.lime => (
          AppColors.lime,
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lime.withValues(alpha: 0.12),
              AppColors.surface,
            ],
          ),
        ),
      CardTone.fire => (
          AppColors.fire.withValues(alpha: 0.5),
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.fire.withValues(alpha: 0.1),
              AppColors.surface,
            ],
          ),
        ),
    };

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          gradient: gradient,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
