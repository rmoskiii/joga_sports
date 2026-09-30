import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/app_scope.dart';
import '../../core/di/app_services.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

typedef _ConfirmedData = ({Game game, Streak streak, List<Game> more});

/// Booking confirmed: clear reassurance, quick actions and the next game.
class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key, required this.gameId});

  final String gameId;

  static Future<_ConfirmedData> _load(AppServices s, String id) async {
    final me = await s.player.currentPlayer();
    final (game, streak, more) = await (
      s.games.getGame(id),
      s.player.streak(),
      s.games.recommendedFor(me.id),
    ).wait;
    return (game: game, streak: streak, more: more);
  }

  void _soon(BuildContext context, String what) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$what is wired in with the real app.')),
      );

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return Scaffold(
      body: SafeArea(
        child: AsyncView<_ConfirmedData>(
          load: () => _load(services, gameId),
          builder: (context, data) {
            final game = data.game;
            final next = data.more.where((g) => g.id != game.id).firstOrNull;
            return ListView(
              padding: const EdgeInsets.all(Space.gutter),
              children: [
                const SizedBox(height: Space.xl),
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x80C6F135), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 56,
                      color: AppColors.onLime,
                    ),
                  ),
                ),
                const SizedBox(height: Space.lg),
                const Headline(
                  'Your spot\nis locked!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Space.sm),
                Text(
                  '${Format.weekdayLong(game.startsAt)} · '
                  '${Format.time(game.startsAt)}\n'
                  '${game.venue.name} · ${game.format.label}',
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Space.lg),
                JogaCard(
                  tone: CardTone.lime,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.fire,
                      ),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          data.streak.playedThisWeek
                              ? 'Another game this week. Your streak is safe.'
                              : 'This game keeps your '
                                  '${data.streak.currentWeeks}-week streak alive.',
                          style: AppText.smallStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.md),
                JogaButton(
                  label: 'View game',
                  onPressed: () =>
                      context.pushReplacement(Routes.gameDay(game.id)),
                ),
                const SizedBox(height: Space.sm),
                JogaButton.secondary(
                  label: 'Get directions',
                  icon: Icons.near_me_rounded,
                  onPressed: () => _soon(context, 'Directions'),
                ),
                const SizedBox(height: Space.sm),
                JogaButton.secondary(
                  label: 'Add to calendar',
                  icon: Icons.event_rounded,
                  onPressed: () => _soon(context, 'Add to calendar'),
                ),
                if (next != null) ...[
                  const SectionLabel('Keep playing'),
                  GameListTile(
                    game: next,
                    onTap: () => context.pushReplacement(Routes.game(next.id)),
                  ),
                ],
                const SizedBox(height: Space.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(Routes.home),
                    child: const Text('Back to home'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
