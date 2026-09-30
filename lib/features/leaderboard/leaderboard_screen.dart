import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Monthly city tables. After the test period (FeatureFlags.leaderboards).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  City _city = City.cardiff;
  LeaderboardMetric _metric = LeaderboardMetric.goals;

  @override
  Widget build(BuildContext context) {
    final compete = context.services.compete;
    return AsyncView<Leaderboard>(
      key: ValueKey((_city, _metric)),
      load: () => compete.leaderboard(_city, _metric),
      builder: (context, board) => JogaScaffold(
        showBack: true,
        children: [
          Headline('${board.city.label} table'),
          Row(
            children: [
              for (final city in City.values) ...[
                JogaChip.filter(
                  label: city.label,
                  selected: city == _city,
                  onTap: () => setState(() => _city = city),
                ),
                const SizedBox(width: Space.sm),
              ],
              const Spacer(),
              JogaChip(label: board.monthLabel, tone: ChipTone.muted),
            ],
          ),
          ChipRow(
            children: [
              for (final metric in LeaderboardMetric.values)
                JogaChip.filter(
                  label: metric.label,
                  selected: metric == _metric,
                  onTap: () => setState(() => _metric = metric),
                ),
            ],
          ),
          JogaCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: Space.xs,
            ),
            child: Column(
              children: [
                for (final entry in board.entries) _Row(entry: entry),
              ],
            ),
          ),
          if (!board.entries.any((e) => e.isMe))
            Text(
              "You're not ranked in ${board.city.label} yet. "
              'Play a game there to join the table.',
              style: AppText.small,
            ),
          JogaCard(
            tone: CardTone.lime,
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.lime),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly prize', style: AppText.bodyStrong),
                      Text(board.prize, style: AppText.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final medal = switch (entry.position) {
      1 => const Color(0xFFFFD166),
      2 => const Color(0xFFC9CED6),
      3 => const Color(0xFFD08B5B),
      _ => null,
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medal != null
                ? Icon(Icons.emoji_events_rounded, color: medal, size: 20)
                : Text(
                    '${entry.position}',
                    style: AppText.h3.copyWith(
                      color: entry.isMe ? AppColors.lime : AppColors.textMuted,
                    ),
                  ),
          ),
          PersonAvatar(person: entry.person, size: 30, highlight: entry.isMe),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              entry.isMe
                  ? '${entry.person.shortName} (you)'
                  : entry.person.shortName,
              style: entry.isMe ? AppText.bodyStrong : AppText.body,
            ),
          ),
          Text('${entry.value}', style: AppText.h3),
        ],
      ),
    );

    if (!entry.isMe) return row;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Space.xs),
      padding: const EdgeInsets.symmetric(horizontal: Space.sm),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: AppColors.lime),
      ),
      child: row,
    );
  }
}
