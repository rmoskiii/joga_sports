import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Placeholder wordmark until the real logo is supplied.
class JogaLogo extends StatelessWidget {
  const JogaLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size * 0.9,
          height: size * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.sports_soccer_rounded,
            color: AppColors.onLime,
            size: size * 0.66,
          ),
        ),
        SizedBox(width: size * 0.3),
        Text(
          'JOGA',
          style: AppText.hero.copyWith(fontSize: size, height: 1),
        ),
      ],
    );
  }
}
