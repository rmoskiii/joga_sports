import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Story-sized card players can share after a game. Every share is free
/// advertising in the city.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.result, required this.name});

  final MatchResult result;
  final String name;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const PitchPhoto(borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JogaLogo(size: 22),
                  const Spacer(),
                  Headline(name, style: AppText.hero.copyWith(fontSize: 44)),
                  Text(
                    '${result.venueName} · ${Format.shortDate(result.playedAt)}',
                    style: AppText.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  Row(
                    children: [
                      _Big(value: '${result.goals}', label: 'Goals'),
                      _Big(value: '${result.assists}', label: 'Assists'),
                      _Big(value: result.scoreLine, label: 'Result'),
                    ],
                  ),
                  if (result.potm) ...[
                    const SizedBox(height: Space.md),
                    const JogaChip(
                      label: 'Player of the match',
                      icon: Icons.emoji_events_rounded,
                      tone: ChipTone.fire,
                    ),
                  ],
                  const SizedBox(height: Space.md),
                  Text(
                    'Find a game at joga.app',
                    style: AppText.tiny.copyWith(color: AppColors.lime),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Big extends StatelessWidget {
  const _Big({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.h1.copyWith(color: AppColors.lime)),
          Text(label.toUpperCase(), style: AppText.tiny),
        ],
      ),
    );
  }
}
