import 'package:flutter/material.dart';

import '../../data/models/enums.dart';
import 'joga_chip.dart';

/// Sport picker. Football is live; other sports show as "soon" so the
/// multi-sport direction is visible from day one.
class SportSwitcher extends StatelessWidget {
  const SportSwitcher({
    super.key,
    this.selected = Sport.football,
    this.padding,
  });

  final Sport selected;
  final EdgeInsetsGeometry? padding;

  static const _icons = {
    Sport.football: Icons.sports_soccer_rounded,
    Sport.padel: Icons.sports_tennis_rounded,
    Sport.badminton: Icons.sports_tennis_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return ChipRow(
      padding: padding,
      children: [
        for (final sport in Sport.values)
          JogaChip(
            label: sport.isLive ? sport.label : '${sport.label} · soon',
            icon: _icons[sport],
            tone: sport == selected
                ? ChipTone.selected
                : sport.isLive
                    ? ChipTone.normal
                    : ChipTone.muted,
          ),
      ],
    );
  }
}
