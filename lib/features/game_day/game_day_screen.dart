import 'dart:async';

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
import 'team_pitch.dart';

typedef _GameDayData = ({Game game, Player me});

/// Game day: countdown, teams on the pitch and what to bring.
class GameDayScreen extends StatelessWidget {
  const GameDayScreen({super.key, required this.gameId});

  final String gameId;

  static Future<_GameDayData> _load(AppServices s, String id) async {
    final (game, me) =
        await (s.games.getGame(id), s.player.currentPlayer()).wait;
    return (game: game, me: me);
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return AsyncView<_GameDayData>(
      load: () => _load(services, gameId),
      builder: (context, data) => _GameDay(game: data.game, me: data.me),
    );
  }
}

class _GameDay extends StatelessWidget {
  const _GameDay({required this.game, required this.me});

  final Game game;
  final Player me;

  @override
  Widget build(BuildContext context) {
    final half = (game.players.length / 2).ceil();
    final white = game.players.take(half).toList();
    final orange = game.players.skip(half).toList();
    final myTeam = white.any((p) => p.id == me.id) ? Team.white : Team.orange;

    return JogaScaffold(
      showBack: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JogaButton(
            label: 'Get directions',
            icon: Icons.near_me_rounded,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opens Apple or Google Maps in the real app.'),
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          JogaButton.secondary(
            label: 'Organiser view · Match control',
            icon: Icons.sports_rounded,
            onPressed: () => context.push(Routes.matchControl(game.id)),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            const Headline('Game day'),
            const SizedBox(width: Space.sm),
            const Icon(Icons.local_fire_department_rounded,
                color: AppColors.fire),
            const Spacer(),
            const JogaChip(label: 'Booked', tone: ChipTone.selected),
          ],
        ),
        Text(
          '${game.venue.name} · ${game.pitch} · ${game.format.label}',
          style: AppText.small,
        ),
        _Countdown(kickOff: game.startsAt),
        SectionLabel(
          "Teams · you're in ${myTeam.label.toLowerCase()}",
          trailing:
              Text('${game.booked}/${game.capacity}', style: AppText.tiny),
        ),
        TeamPitch(white: white, orange: orange, meId: me.id),
        Row(
          children: [
            const _TeamKey(color: AppColors.teamWhite, label: 'White'),
            const SizedBox(width: Space.lg),
            const _TeamKey(color: AppColors.teamOrange, label: 'Orange'),
            const Spacer(),
            const Text('Teams set by the organiser', style: AppText.tiny),
          ],
        ),
        const SectionLabel('Before you go'),
        _InfoRow(label: 'Surface', value: game.venue.surface),
        _InfoRow(label: 'Parking', value: game.venue.parking),
        _InfoRow(
          label: 'Check in with',
          value: '${game.organiser.shortName} on arrival',
        ),
        const _InfoRow(label: 'Bring', value: 'Water · dark and light top'),
      ],
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.kickOff});

  final DateTime kickOff;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
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
    final left = widget.kickOff.difference(DateTime.now());
    return JogaCard(
      padding: const EdgeInsets.symmetric(vertical: Space.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.lime),
              const SizedBox(width: Space.xs + 2),
              Text(
                left.isNegative ? 'KICKED OFF' : 'KICK-OFF IN',
                style: AppText.label.copyWith(color: AppColors.lime),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            Format.countdown(left),
            style: AppText.hero.copyWith(
              fontStyle: FontStyle.normal,
              fontSize: 48,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: Space.xs),
          const Text('HRS · MINS · SECS', style: AppText.tiny),
        ],
      ),
    );
  }
}

class _TeamKey extends StatelessWidget {
  const _TeamKey({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: Space.xs),
        Text(label, style: AppText.small),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Row(
        children: [
          Text(label, style: AppText.small),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              value,
              style: AppText.smallStrong,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
