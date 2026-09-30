import 'match.dart';

enum StatsPeriod {
  career('Career'),
  season('Season'),
  month('Month');

  const StatsPeriod(this.label);
  final String label;
}

/// One game in the form chart.
class FormEntry {
  const FormEntry(
      {required this.goals, required this.assists, required this.won});

  final int goals;
  final int assists;
  final bool won;
}

class PlayerStats {
  const PlayerStats({
    required this.period,
    required this.games,
    required this.goals,
    required this.assists,
    required this.potm,
    required this.wins,
    required this.form,
    required this.bestVenue,
    required this.cityRank,
  });

  final StatsPeriod period;
  final int games;
  final int goals;
  final int assists;
  final int potm;
  final int wins;

  /// Last 10 games, oldest first.
  final List<FormEntry> form;

  // Joga+ stats
  final String bestVenue;
  final int cityRank;

  double get goalsPerGame => games == 0 ? 0 : goals / games;
  int get winRatePercent => games == 0 ? 0 : (wins / games * 100).round();
}

/// Weekly streak: play at least once each week (Mon–Sun) to keep it.
class Streak {
  const Streak({
    required this.currentWeeks,
    required this.bestWeeks,
    required this.lastTwelveWeeks,
    required this.playedThisWeek,
    required this.weekEndsAt,
    required this.nextReward,
    required this.freezesLeft,
  });

  final int currentWeeks;
  final int bestWeeks;

  /// Oldest first. The last item is the current week.
  final List<bool> lastTwelveWeeks;
  final bool playedThisWeek;
  final DateTime weekEndsAt;
  final Milestone nextReward;

  /// Joga+ perk: miss a week without losing the streak.
  final int freezesLeft;
}

/// Everything shown on Home, loaded in one call.
class HomeSummary {
  const HomeSummary({
    required this.stats,
    required this.streak,
    required this.lastResult,
  });

  final PlayerStats stats;
  final Streak streak;
  final MatchResult? lastResult;
}
