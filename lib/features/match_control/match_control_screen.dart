import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

enum _Step {
  attendance('Attendance'),
  goals('Goals'),
  assists('Assists'),
  potm('POTM'),
  review('Submit');

  const _Step(this.label);
  final String label;
}

/// Organiser's pitch-side screen. Five quick steps, big targets, no typing.
/// The score builds itself from the goals logged.
class MatchControlScreen extends StatefulWidget {
  const MatchControlScreen({super.key, required this.gameId});

  final String gameId;

  @override
  State<MatchControlScreen> createState() => _MatchControlScreenState();
}

class _MatchControlScreenState extends State<MatchControlScreen> {
  MatchSheet? _sheet;
  _Step _step = _Step.attendance;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sheet = await context.services.matches.loadSheet(widget.gameId);
      if (mounted) setState(() => _sheet = sheet);
    });
  }

  void _updateLine(int index, MatchLine Function(MatchLine) change) {
    final sheet = _sheet!;
    final lines = [...sheet.lines];
    lines[index] = change(lines[index]);
    setState(() => _sheet = sheet.copyWith(lines: lines));
  }

  bool get _canContinue => _step != _Step.potm || _sheet?.potmId != null;

  Future<void> _next() async {
    if (_step != _Step.review) {
      setState(() => _step = _Step.values[_step.index + 1]);
      return;
    }
    setState(() => _submitting = true);
    await context.services.matches.submit(_sheet!);
    if (!mounted) return;
    context.pushReplacement(Routes.postGame(widget.gameId));
  }

  void _back() {
    if (_step == _Step.attendance) {
      context.pop();
    } else {
      setState(() => _step = _Step.values[_step.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheet = _sheet;
    if (sheet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.lime)),
      );
    }

    return JogaScaffold(
      showBack: true,
      backLabel: 'Game day',
      bottom: Row(
        children: [
          if (_step != _Step.attendance) ...[
            Expanded(
              child: JogaButton.secondary(label: 'Back', onPressed: _back),
            ),
            const SizedBox(width: Space.sm),
          ],
          Expanded(
            flex: 2,
            child: JogaButton(
              label: _step == _Step.review
                  ? 'Submit result'
                  : 'Next: ${_Step.values[_step.index + 1].label}',
              loading: _submitting,
              onPressed: _canContinue ? _next : null,
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            const Expanded(child: Headline('Match control')),
            const JogaChip(label: 'Organiser', tone: ChipTone.fire),
          ],
        ),
        Text(
          '${sheet.game.venue.name} · ${Format.shortDate(sheet.game.startsAt)} '
          '· ${Format.time(sheet.game.startsAt)}',
          style: AppText.small,
        ),
        _StepBar(current: _step),
        _ScoreCard(sheet: sheet),
        ..._stepBody(sheet),
      ],
    );
  }

  List<Widget> _stepBody(MatchSheet sheet) {
    final indexed = [
      for (var i = 0; i < sheet.lines.length; i++) (i, sheet.lines[i]),
    ];
    final attended = indexed.where((e) => e.$2.attended).toList();

    switch (_step) {
      case _Step.attendance:
        return [
          const Text('Tick who turned up.', style: AppText.small),
          _PlayerList(
            children: [
              for (final (i, line) in indexed)
                _LineRow(
                  line: line,
                  trailing: _TickBox(
                    on: line.attended,
                    onTap: () => _updateLine(
                      i,
                      (l) => l.copyWith(attended: !l.attended),
                    ),
                  ),
                ),
            ],
          ),
        ];
      case _Step.goals:
      case _Step.assists:
        final isGoals = _step == _Step.goals;
        return [
          Text(
            isGoals ? 'Tap + for each goal.' : 'Tap + for each assist.',
            style: AppText.small,
          ),
          _PlayerList(
            children: [
              for (final (i, line) in attended)
                _LineRow(
                  line: line,
                  trailing: _Stepper(
                    value: isGoals ? line.goals : line.assists,
                    onChanged: (v) => _updateLine(
                      i,
                      (l) => isGoals
                          ? l.copyWith(goals: v)
                          : l.copyWith(assists: v),
                    ),
                  ),
                ),
            ],
          ),
        ];
      case _Step.potm:
        return [
          const Text('Pick the player of the match.', style: AppText.small),
          _PlayerList(
            children: [
              for (final (_, line) in attended)
                _LineRow(
                  line: line,
                  onTap: () => setState(
                    () => _sheet = sheet.copyWith(potmId: line.person.id),
                  ),
                  trailing: Icon(
                    sheet.potmId == line.person.id
                        ? Icons.emoji_events_rounded
                        : Icons.emoji_events_outlined,
                    color: sheet.potmId == line.person.id
                        ? AppColors.fire
                        : AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ];
      case _Step.review:
        final potm = sheet.lines
            .where((l) => l.person.id == sheet.potmId)
            .map((l) => l.person.shortName)
            .firstOrNull;
        final noShows = sheet.lines.where((l) => !l.attended).length;
        return [
          JogaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PriceRow(label: 'Played', value: '${attended.length}'),
                PriceRow(label: 'No-shows', value: '$noShows'),
                PriceRow(
                  label: 'Goals',
                  value:
                      '${sheet.scoreFor(Team.white) + sheet.scoreFor(Team.orange)}',
                ),
                PriceRow(label: 'Player of the match', value: potm ?? '–'),
              ],
            ),
          ),
          const Text(
            "Submitting updates every player's stats, streaks and rewards, "
            'and sends them their post-game summary.',
            style: AppText.small,
          ),
        ];
    }
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current});

  final _Step current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final step in _Step.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: step.index <= current.index
                          ? AppColors.lime
                          : AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    step.label,
                    style: AppText.tiny.copyWith(
                      color: step == current
                          ? AppColors.lime
                          : AppColors.textMuted,
                      fontWeight:
                          step == current ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.sheet});

  final MatchSheet sheet;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('WHITE', style: AppText.label),
              const SizedBox(width: Space.md),
              Text(
                '${sheet.scoreFor(Team.white)} – ${sheet.scoreFor(Team.orange)}',
                style: AppText.h1.copyWith(fontSize: 36),
              ),
              const SizedBox(width: Space.md),
              const Text('ORANGE', style: AppText.label),
            ],
          ),
          const Text('Score builds from goals logged', style: AppText.tiny),
        ],
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.trailing, this.onTap});

  final MatchLine line;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.sm),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: line.team == Team.white
                    ? AppColors.teamWhite
                    : AppColors.teamOrange,
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                line.person.shortName,
                style: AppText.bodyStrong.copyWith(
                  color: line.attended ? null : AppColors.textMuted,
                  decoration: line.attended ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _TickBox extends StatelessWidget {
  const _TickBox({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: on ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? AppColors.lime : AppColors.line,
            width: 1.5,
          ),
        ),
        child: on
            ? const Icon(Icons.check_rounded, color: AppColors.onLime)
            : null,
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.textMuted,
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppText.h3,
            ),
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
            color: AppColors.lime,
          ),
        ],
      ),
    );
  }
}
