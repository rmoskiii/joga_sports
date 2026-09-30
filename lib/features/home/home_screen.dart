import 'dart:async';

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

typedef _HomeData = ({
  Player me,
  HomeSummary summary,
  List<Game> upcoming,
  List<Game> forYou,
});

/// Home: next game, streak nudge, season numbers and personalised games.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Future<_HomeData> _load(AppServices s) async {
    final me = await s.player.currentPlayer();
    final (summary, upcoming, forYou) = await (
      s.player.homeSummary(),
      s.games.upcomingFor(me.id),
      s.games.recommendedFor(me.id),
    ).wait;
    return (me: me, summary: summary, upcoming: upcoming, forYou: forYou);
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return Scaffold(
      body: SafeArea(
        child: AsyncView<_HomeData>(
          load: () => _load(services),
          builder: (context, data) => _HomeBody(data: data),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data});

  final _HomeData data;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final me = data.me;
    final stats = data.summary.stats;
    final streak = data.summary.streak;
    final next = data.upcoming.isEmpty ? null : data.upcoming.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.md,
        Space.gutter,
        Space.xl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(), style: AppText.small),
                  Headline(me.firstName),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.profile),
              child: PersonAvatar(person: me.person, size: 42),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            JogaChip(
              label: '${streak.currentWeeks}-week streak',
              icon: Icons.local_fire_department_rounded,
              tone: ChipTone.fire,
              onTap: () => context.push(Routes.streak),
            ),
            const SizedBox(width: Space.sm),
            JogaChip(
              label: me.city.label,
              icon: Icons.place_rounded,
              onTap: () => context.go(Routes.find),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        const SportSwitcher(),
        const SizedBox(height: Space.md),
        GestureDetector(
          onTap: () => context.go(Routes.stats),
          child: StatRow(
            tiles: [
              StatTile(value: '${stats.games}', label: 'Games'),
              StatTile(value: '${stats.goals}', label: 'Goals'),
              StatTile(value: '${stats.assists}', label: 'Assists'),
            ],
          ),
        ),
        if (next != null) ...[
          SectionLabel(
            'Your next game',
            action: 'My games',
            onAction: () => context.go(Routes.myGames),
          ),
          GameCard(
            game: next,
            onTap: () => context.push(Routes.gameDay(next.id)),
            footer: _NextGameFooter(game: next),
          ),
        ],
        const SizedBox(height: Space.md),
        _StreakNudge(streak: streak),
        SectionLabel(
          'For you',
          action: 'See all',
          onAction: () => context.go(Routes.find),
        ),
        if (data.forYou.isEmpty)
          const Text('No new games near you right now.', style: AppText.small)
        else
          for (final game in data.forYou) ...[
            GameCard(
              game: game,
              reason: game.level == me.level ? 'Your level' : 'Near you',
              onTap: () => context.push(Routes.game(game.id)),
            ),
            const SizedBox(height: Space.md),
          ],
        if (!me.isMember) const _MembershipPromo(),
      ],
    );
  }
}

class _NextGameFooter extends StatefulWidget {
  const _NextGameFooter({required this.game});

  final Game game;

  @override
  State<_NextGameFooter> createState() => _NextGameFooterState();
}

class _NextGameFooterState extends State<_NextGameFooter> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.game.startsAt.difference(DateTime.now());
    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: AppColors.lime),
        const SizedBox(width: Space.xs + 2),
        Text(
          left.isNegative
              ? 'Kicked off'
              : 'Kick-off in ${Format.countdown(left)}',
          style: AppText.smallStrong,
        ),
        const Spacer(),
        const JogaChip(label: 'Booked', tone: ChipTone.selected),
      ],
    );
  }
}

class _StreakNudge extends StatelessWidget {
  const _StreakNudge({required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context) {
    final safe = streak.playedThisWeek;
    return JogaCard(
      tone: safe ? CardTone.lime : CardTone.fire,
      onTap: () => context.push(Routes.streak),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                safe
                    ? Icons.verified_rounded
                    : Icons.local_fire_department_rounded,
                size: 18,
                color: safe ? AppColors.lime : AppColors.fire,
              ),
              const SizedBox(width: Space.xs + 2),
              Expanded(
                child: Text(
                  safe
                      ? 'Streak safe this week'
                      : 'Play by Sunday to hit ${streak.currentWeeks + 1} weeks',
                  style: AppText.bodyStrong,
                ),
              ),
              if (!safe)
                Text(
                  '${Format.weekday(streak.weekEndsAt)} '
                  '${Format.time(streak.weekEndsAt)}',
                  style: AppText.tiny,
                ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            '${streak.nextReward.remaining} weeks to go until '
            '${streak.nextReward.rewardLabel}.',
            style: AppText.small,
          ),
          const SizedBox(height: Space.sm),
          JogaProgressBar(
            value: streak.nextReward.ratio,
            color: AppColors.fire,
          ),
        ],
      ),
    );
  }
}

class _MembershipPromo extends StatelessWidget {
  const _MembershipPromo();

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      tone: CardTone.lime,
      onTap: () => context.push(Routes.membership),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.lime),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Headline(
                  '${AppConfig.membershipName} · no booking fees',
                  style: AppText.h3,
                  color: AppColors.lime,
                ),
                const SizedBox(height: Space.xxs),
                Text(
                  '${Format.money(AppConfig.membershipMonthlyPence)} a month. '
                  'Full stats and bigger rewards.',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
