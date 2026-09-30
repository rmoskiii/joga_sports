import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/di/app_scope.dart';
import '../../core/di/app_services.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

typedef _MyGamesData = ({List<Game> upcoming, List<MatchResult> completed});

/// Upcoming bookings and completed games with results.
class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  bool _showCompleted = false;

  static Future<_MyGamesData> _load(AppServices s) async {
    final me = await s.player.currentPlayer();
    final (upcoming, completed) =
        await (s.games.upcomingFor(me.id), s.player.recentResults()).wait;
    return (upcoming: upcoming, completed: completed);
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return Scaffold(
      body: SafeArea(
        child: AsyncView<_MyGamesData>(
          load: () => _load(services),
          builder: (context, data) => ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              Space.md,
              Space.gutter,
              Space.xl,
            ),
            children: [
              const Headline('My games'),
              const SizedBox(height: Space.md),
              Row(
                children: [
                  JogaChip.filter(
                    label: 'Upcoming (${data.upcoming.length})',
                    selected: !_showCompleted,
                    onTap: () => setState(() => _showCompleted = false),
                  ),
                  const SizedBox(width: Space.sm),
                  JogaChip.filter(
                    label: 'Completed',
                    selected: _showCompleted,
                    onTap: () => setState(() => _showCompleted = true),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              if (_showCompleted)
                ..._completed(context, data.completed)
              else
                ..._upcoming(context, data.upcoming),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _upcoming(BuildContext context, List<Game> games) {
    if (games.isEmpty) {
      return [
        const Text('No games booked yet.', style: AppText.bodyStrong),
        const SizedBox(height: Space.md),
        JogaButton(
          label: 'Find a game',
          onPressed: () => context.go(Routes.find),
        ),
      ];
    }
    return [
      for (final game in games) ...[
        GameCard(
          game: game,
          onTap: () => context.push(Routes.gameDay(game.id)),
          footer: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.lime),
              const SizedBox(width: Space.xs + 2),
              Text(
                'Booked · ${Format.daysToGo(game.startsAt)}',
                style: AppText.smallStrong,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _confirmCancel(context, game),
                child: Text(
                  'Cancel',
                  style: AppText.small.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
      ],
      Text(
        'Free cancellation until ${AppConfig.freeCancellation.inHours}h '
        "before kick-off. After that, you're refunded if your space is filled.",
        style: AppText.tiny,
      ),
    ];
  }

  List<Widget> _completed(BuildContext context, List<MatchResult> results) {
    return [
      for (final r in results) ...[
        JogaCard(
          onTap: () => context.push(Routes.postGame(r.gameId)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Format.shortDate(r.playedAt)} · ${r.venueName}',
                      style: AppText.bodyStrong,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      '${r.format.label} · ${r.goals} goals · '
                      '${r.assists} assists${r.potm ? ' · POTM' : ''}',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              JogaChip(
                label: r.scoreLine,
                tone: r.won ? ChipTone.selected : ChipTone.normal,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
      ],
    ];
  }

  Future<void> _confirmCancel(BuildContext context, Game game) async {
    final isLate =
        game.startsAt.difference(DateTime.now()) < AppConfig.freeCancellation;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.gutter,
          0,
          Space.gutter,
          Space.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Headline('Cancel this game?', style: AppText.h2),
            const SizedBox(height: Space.sm),
            Text(
              isLate
                  ? "It's less than ${AppConfig.freeCancellation.inHours} hours "
                      "to kick-off. We'll release your space, and you'll be "
                      'refunded to your wallet if someone takes it.'
                  : "You'll get a full refund to your wallet.",
              style: AppText.body,
            ),
            const SizedBox(height: Space.lg),
            JogaButton(
              label: 'Yes, cancel',
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: Space.sm),
            JogaButton.secondary(
              label: 'Keep my spot',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final outcome = await context.services.bookings.cancel(game.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome == CancelOutcome.refunded
              ? 'Cancelled. ${Format.money(game.pricePence)} is back in your wallet.'
              : "Cancelled. You'll be refunded if your space is filled.",
        ),
      ),
    );
  }
}
