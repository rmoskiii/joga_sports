import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Find: browse and filter games by day, city, format, level and tags.
class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  GameFilter _filter = const GameFilter();

  void _update(GameFilter filter) => setState(() => _filter = filter);

  @override
  Widget build(BuildContext context) {
    final games = context.services.games;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.gutter,
                Space.md,
                Space.gutter,
                Space.sm,
              ),
              child: const Headline('Find your\nnext game'),
            ),
            _Filters(filter: _filter, onChanged: _update),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView<List<Game>>(
                key: ValueKey(_filter),
                load: () => games.findGames(_filter),
                builder: (context, results) => _Results(
                  games: results,
                  city: _filter.city,
                  onClear: () => _update(GameFilter(city: _filter.city)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.filter, required this.onChanged});

  final GameFilter filter;
  final ValueChanged<GameFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const pad = EdgeInsets.symmetric(horizontal: Space.gutter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SportSwitcher(padding: pad),
        const SizedBox(height: Space.sm),
        ChipRow(
          padding: pad,
          children: [
            for (final day in DayFilter.values)
              JogaChip.filter(
                label: day.label,
                selected: filter.day == day,
                onTap: () => onChanged(filter.copyWith(day: day)),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        ChipRow(
          padding: pad,
          children: [
            for (final city in City.values)
              JogaChip.filter(
                label: city.label,
                selected: filter.city == city,
                onTap: () => onChanged(filter.copyWith(city: city)),
              ),
            for (final format in GameFormat.values)
              JogaChip.filter(
                label: format.label,
                selected: filter.format == format,
                onTap: () => onChanged(
                  filter.copyWith(
                    format: () => filter.format == format ? null : format,
                  ),
                ),
              ),
            JogaChip.filter(
              label: 'Under £7',
              selected: filter.maxPricePence != null,
              onTap: () => onChanged(
                filter.copyWith(
                  maxPricePence: () =>
                      filter.maxPricePence == null ? 699 : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        ChipRow(
          padding: pad,
          children: [
            for (final level in SkillLevel.values)
              JogaChip.filter(
                label: level.label,
                selected: filter.level == level,
                onTap: () => onChanged(
                  filter.copyWith(
                    level: () => filter.level == level ? null : level,
                  ),
                ),
              ),
            for (final tag in GameTag.values)
              JogaChip.filter(
                label: tag.label,
                selected: filter.tag == tag,
                onTap: () => onChanged(
                  filter.copyWith(tag: () => filter.tag == tag ? null : tag),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.games,
    required this.city,
    required this.onClear,
  });

  final List<Game> games;
  final City city;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No games match these filters.',
                style: AppText.bodyStrong,
              ),
              const SizedBox(height: Space.sm),
              JogaButton.secondary(
                label: 'Clear filters',
                expand: false,
                onPressed: onClear,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.sm,
        Space.gutter,
        Space.xl,
      ),
      itemCount: games.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: Space.sm),
      itemBuilder: (context, i) {
        if (i == games.length) {
          return Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              '${games.length} ${games.length == 1 ? 'game' : 'games'} '
              'in ${city.label} · sorted by kick-off',
              style: AppText.tiny,
              textAlign: TextAlign.center,
            ),
          );
        }
        final game = games[i];
        return GameListTile(
          game: game,
          onTap: () => context.push(Routes.game(game.id)),
        );
      },
    );
  }
}
