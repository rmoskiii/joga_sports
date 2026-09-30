import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/models/stats.dart';

/// Stacked bars of goals and assists for the last 10 games.
class FormChart extends StatelessWidget {
  const FormChart({super.key, required this.form, this.height = 96});

  final List<FormEntry> form;
  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = form.fold<int>(1, (m, e) {
      final total = e.goals + e.assists;
      return total > m ? total : m;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in form)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _bar(entry.goals / peak * height, AppColors.lime,
                            top: true),
                        _bar(entry.assists / peak * height, AppColors.limeDeep,
                            top: entry.goals == 0),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.xs),
        Row(
          children: [
            for (final entry in form)
              Expanded(
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.won ? AppColors.lime : AppColors.line,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        const Row(
          children: [
            _Key(color: AppColors.lime, label: 'Goals'),
            SizedBox(width: Space.md),
            _Key(color: AppColors.limeDeep, label: 'Assists'),
            SizedBox(width: Space.md),
            _Key(color: AppColors.lime, label: 'Win', dot: true),
          ],
        ),
      ],
    );
  }

  Widget _bar(double h, Color color, {required bool top}) => Container(
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              top ? const BorderRadius.vertical(top: Radius.circular(3)) : null,
        ),
      );
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label, this.dot = false});

  final Color color;
  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: dot ? 6 : 10,
          height: dot ? 6 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: dot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: dot ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: Space.xs),
        Text(label, style: AppText.tiny),
      ],
    );
  }
}
