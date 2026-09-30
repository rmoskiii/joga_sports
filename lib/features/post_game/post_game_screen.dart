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
import 'share_card.dart';

typedef _PostGameData = ({PostGameSummary summary, Player me});

/// The payoff: result, your numbers and anything you unlocked.
class PostGameScreen extends StatelessWidget {
  const PostGameScreen({super.key, required this.gameId});

  final String gameId;

  static Future<_PostGameData> _load(AppServices s, String id) async {
    final (summary, me) =
        await (s.player.postGame(id), s.player.currentPlayer()).wait;
    return (summary: summary, me: me);
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return Scaffold(
      body: AsyncView<_PostGameData>(
        load: () => _load(services, gameId),
        builder: (context, data) =>
            _PostGame(summary: data.summary, me: data.me),
      ),
    );
  }
}

class _PostGame extends StatefulWidget {
  const _PostGame({required this.summary, required this.me});

  final PostGameSummary summary;
  final Player me;

  @override
  State<_PostGame> createState() => _PostGameState();
}

class _PostGameState extends State<_PostGame> {
  final _feedback = <String>{};

  static const _feedbackOptions = [
    'Good level',
    'Great organiser',
    'Fair teams',
    'Would play again',
  ];

  void _share() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.xxl,
          0,
          Space.xxl,
          Space.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 440),
              child: ShareCard(
                result: widget.summary.result,
                name: widget.me.firstName,
              ),
            ),
            const SizedBox(height: Space.lg),
            JogaButton(
              label: 'Share to Instagram',
              icon: Icons.ios_share_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing is wired in with the real app.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final r = summary.result;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 170,
          child: PitchPhoto(
            borderRadius: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Headline(
                    'Game complete',
                    style: AppText.hero.copyWith(fontSize: 38),
                  ),
                ),
                IconButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.home),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.gutter,
            Space.md,
            Space.gutter,
            Space.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${r.venueName} · ${Format.shortDate(r.playedAt)} · '
                '${r.format.label}',
                style: AppText.small,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.md),
              _Scoreline(result: r),
              const SizedBox(height: Space.lg),
              StatRow(
                tiles: [
                  StatTile(value: '${r.goals}', label: 'Goals'),
                  StatTile(value: '${r.assists}', label: 'Assists'),
                  StatTile(
                    value: '',
                    label: 'POTM',
                    icon: r.potm
                        ? Icons.emoji_events_rounded
                        : Icons.emoji_events_outlined,
                    valueColor: r.potm ? AppColors.fire : AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              Center(
                child: JogaChip(
                  label: '${summary.streakWeeks}-week streak',
                  icon: Icons.local_fire_department_rounded,
                  tone: ChipTone.fire,
                  onTap: () => context.push(Routes.streak),
                ),
              ),
              if (summary.unlocked.isNotEmpty) ...[
                const SectionLabel('Unlocked'),
                for (final reward in summary.unlocked) ...[
                  _RewardTile(reward: reward),
                  const SizedBox(height: Space.sm),
                ],
              ],
              const SectionLabel('Next milestone'),
              JogaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.nextMilestone.title,
                            style: AppText.bodyStrong,
                          ),
                        ),
                        Text(
                          '${summary.nextMilestone.progress} / '
                          '${summary.nextMilestone.target}',
                          style: AppText.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.sm),
                    JogaProgressBar(value: summary.nextMilestone.ratio),
                    const SizedBox(height: Space.xs),
                    Text(
                      'Reward: ${summary.nextMilestone.rewardLabel}',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              const SectionLabel('How was the game?'),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (final option in _feedbackOptions)
                    JogaChip.filter(
                      label: option,
                      selected: _feedback.contains(option),
                      onTap: () => setState(
                        () => _feedback.contains(option)
                            ? _feedback.remove(option)
                            : _feedback.add(option),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.xl),
              JogaButton.secondary(
                label: 'Share your game',
                icon: Icons.ios_share_rounded,
                onPressed: _share,
              ),
              const SizedBox(height: Space.sm),
              JogaButton(
                label: 'Find next game',
                onPressed: () => context.go(Routes.find),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Scoreline extends StatelessWidget {
  const _Scoreline({required this.result});

  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    final mine = result.myTeam;
    final theirs = mine == Team.white ? Team.orange : Team.white;
    final label = result.won
        ? 'You won'
        : result.drew
            ? 'Draw'
            : 'You lost';

    Widget side(Team team, int score, {required bool muted}) => Column(
          children: [
            Text(team.label.toUpperCase(), style: AppText.label),
            Text(
              '$score',
              style: AppText.hero.copyWith(
                fontStyle: FontStyle.normal,
                color: muted ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        side(mine, result.myScore, muted: false),
        JogaChip(
          label: label,
          tone: result.won ? ChipTone.selected : ChipTone.normal,
        ),
        side(theirs, result.theirScore, muted: !result.won),
      ],
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.reward});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    final credit = reward.creditPence;
    return JogaCard(
      tone: credit != null ? CardTone.lime : CardTone.normal,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: credit != null ? AppColors.lime : AppColors.fire,
              shape: BoxShape.circle,
            ),
            child: Icon(
              credit != null
                  ? Icons.savings_rounded
                  : Icons.local_fire_department_rounded,
              color: AppColors.onLime,
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title, style: AppText.bodyStrong),
                Text(reward.subtitle, style: AppText.small),
              ],
            ),
          ),
          if (credit != null)
            Text(
              Format.moneySigned(credit),
              style: AppText.h2.copyWith(color: AppColors.lime),
            ),
        ],
      ),
    );
  }
}
