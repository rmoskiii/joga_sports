import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/widgets.dart';
import '../../data/fake/fake_seed.dart';

/// Demo only: every screen in the app, grouped by the player loop, so the
/// whole product can be reviewed in one sitting. Remove before launch.
class DemoHubScreen extends StatelessWidget {
  const DemoHubScreen({super.key});

  static final _stages = <(String, List<_Entry>)>[
    (
      'Find',
      [
        _Entry('Onboarding', Routes.onboarding, go: true),
        _Entry('Home', Routes.home, go: true),
        _Entry('Find games', Routes.find, go: true),
      ],
    ),
    (
      'Book',
      [
        _Entry('Game details', Routes.game(FakeSeed.lastSpaceGameId)),
        _Entry('Checkout (5-minute hold)',
            Routes.checkout(FakeSeed.lastSpaceGameId)),
        _Entry('Booking confirmed', Routes.confirmed(FakeSeed.lastSpaceGameId)),
        _Entry('Full game (waitlist)', Routes.game('g-104')),
      ],
    ),
    (
      'Play',
      [
        _Entry('My games', Routes.myGames, go: true),
        _Entry('Game day', Routes.gameDay(FakeSeed.tonightGameId)),
        _Entry(
          'Match control (organiser)',
          Routes.matchControl(FakeSeed.tonightGameId),
        ),
      ],
    ),
    (
      'Track',
      [
        _Entry('Post-game', Routes.postGame(FakeSeed.lastPlayedGameId)),
        _Entry('Stats', Routes.stats, go: true),
        _Entry('Profile', Routes.profile, go: true),
      ],
    ),
    (
      'Compete & reward',
      [
        _Entry('Streak', Routes.streak),
        _Entry('City leaderboard · after test', Routes.leaderboard),
        _Entry('Wallet', Routes.wallet),
      ],
    ),
    (
      'Grow & run',
      [
        _Entry('Joga+', Routes.membership),
        _Entry('Referrals · after test', Routes.referrals),
        _Entry('Admin dashboard', Routes.admin),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var number = 0;
    return JogaScaffold(
      showBack: true,
      children: [
        const Headline('All screens'),
        const Text(
          'Demo index. Tip: book the last space, then open Match control '
          "for tonight's game and submit a result to see stats, streak and "
          'wallet update everywhere.',
          style: AppText.small,
        ),
        for (final (stage, entries) in _stages) ...[
          SectionLabel(stage),
          JogaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final entry in entries)
                  ListTile(
                    dense: true,
                    leading: Text(
                      (++number).toString().padLeft(2, '0'),
                      style: AppText.h3.copyWith(color: AppColors.lime),
                    ),
                    title: Text(entry.label, style: AppText.bodyStrong),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => entry.go
                        ? context.go(entry.path)
                        : context.push(entry.path),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Space.md),
      ],
    );
  }
}

class _Entry {
  const _Entry(this.label, this.path, {this.go = false});

  final String label;
  final String path;

  /// Tabs and onboarding replace the stack instead of pushing.
  final bool go;
}
