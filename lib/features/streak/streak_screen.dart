import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../stats/widgets/streak_calendar.dart';

/// Weekly streak: play at least once each week (Monday to Sunday).
class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.services.player;
    return AsyncView<Streak>(
      load: player.streak,
      builder: (context, streak) => JogaScaffold(
        showBack: true,
        bottom: JogaButton(
          label: streak.playedThisWeek ? 'Find next game' : 'Keep it going',
          onPressed: () => context.go(Routes.find),
        ),
        children: [
          _Ring(streak: streak),
          JogaCard(
            tone: streak.playedThisWeek ? CardTone.lime : CardTone.fire,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This week', style: AppText.bodyStrong),
                      const SizedBox(height: Space.xxs),
                      Text(
                        streak.playedThisWeek
                            ? "You've played. Your streak is safe until next "
                                'week.'
                            : 'Play by ${Format.weekday(streak.weekEndsAt)} '
                                '${Format.time(streak.weekEndsAt)} to keep it.',
                        style: AppText.small,
                      ),
                    ],
                  ),
                ),
                JogaChip(
                  label: streak.playedThisWeek ? 'Played' : 'Not yet',
                  icon: streak.playedThisWeek ? Icons.check_rounded : null,
                  tone:
                      streak.playedThisWeek ? ChipTone.selected : ChipTone.fire,
                ),
              ],
            ),
          ),
          _RewardRow(
            icon: Icons.card_giftcard_rounded,
            title: streak.nextReward.title,
            subtitle: streak.nextReward.rewardLabel,
            trailing: '${streak.nextReward.remaining} to go',
          ),
          _RewardRow(
            icon: Icons.ac_unit_rounded,
            title: 'Streak freeze · ${AppConfig.membershipName}',
            subtitle: streak.freezesLeft > 0
                ? '${streak.freezesLeft} left this month'
                : 'Miss a week without losing your streak',
            trailing: streak.freezesLeft > 0 ? 'Ready' : 'Join',
            onTap: streak.freezesLeft > 0
                ? null
                : () => context.push(Routes.membership),
          ),
          const SectionLabel('Last 12 weeks'),
          JogaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreakCalendar(weeks: streak.lastTwelveWeeks),
                const SizedBox(height: Space.sm),
                Text(
                  'Best streak: ${streak.bestWeeks} weeks',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const Text(
            'How it works: play at least one game each week, Monday to '
            'Sunday. Miss a week and the streak resets, unless you have a '
            'streak freeze.',
            style: AppText.tiny,
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Space.sm),
        SizedBox.square(
          dimension: 170,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: streak.nextReward.ratio,
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                color: AppColors.fire,
                backgroundColor: AppColors.surfaceRaised,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.fire,
                    size: 28,
                  ),
                  Text(
                    '${streak.currentWeeks}',
                    style: AppText.hero.copyWith(
                      fontStyle: FontStyle.normal,
                      fontSize: 64,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        const Headline('Week streak', textAlign: TextAlign.center),
        const SizedBox(height: Space.xs),
        Text(
          '${streak.nextReward.progress} / ${streak.nextReward.target} weeks '
          'to your next reward',
          style: AppText.small,
        ),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.lime),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyStrong),
                Text(subtitle, style: AppText.small),
              ],
            ),
          ),
          Text(trailing, style: AppText.smallStrong),
        ],
      ),
    );
  }
}
