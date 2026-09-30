import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thin rounded progress bar.
class JogaProgressBar extends StatelessWidget {
  const JogaProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.lime,
    this.height = 6,
  });

  /// 0 to 1.
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.surfaceRaised),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1).toDouble(),
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
