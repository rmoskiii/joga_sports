import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Last 12 weeks as squares. Filled = played that week. The current week
/// has a dashed-look outline until it's played.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.weeks});

  /// Oldest first; last item is the current week.
  final List<bool> weeks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < weeks.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: weeks[i] ? AppColors.lime : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                    border: i == weeks.length - 1 && !weeks[i]
                        ? Border.all(color: AppColors.fire, width: 1.5)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
