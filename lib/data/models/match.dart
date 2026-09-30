import 'enums.dart';
import 'game.dart';
import 'person.dart';

/// One player's line on the organiser's match sheet.
class MatchLine {
  const MatchLine({
    required this.person,
    required this.team,
    this.attended = true,
    this.goals = 0,
    this.assists = 0,
  });

  final Person person;
  final Team team;
  final bool attended;
  final int goals;
  final int assists;

  MatchLine copyWith({bool? attended, int? goals, int? assists}) => MatchLine(
        person: person,
        team: team,
        attended: attended ?? this.attended,
        goals: goals ?? this.goals,
        assists: assists ?? this.assists,
      );
}

/// The organiser's match sheet, filled in pitch-side in Match Control.
class MatchSheet {
  const MatchSheet({
    required this.game,
    required this.lines,
    this.potmId,
    this.submitted = false,
  });

  final Game game;
  final List<MatchLine> lines;

  /// Player of the match, picked by the organiser.
  final String? potmId;
  final bool submitted;

  /// The score builds itself from goals logged.
  int scoreFor(Team team) => lines
      .where((l) => l.team == team && l.attended)
      .fold(0, (sum, l) => sum + l.goals);

  List<MatchLine> team(Team team) =>
      lines.where((l) => l.team == team).toList();

  MatchSheet copyWith({
    List<MatchLine>? lines,
    String? potmId,
    bool? submitted,
  }) =>
      MatchSheet(
        game: game,
        lines: lines ?? this.lines,
        potmId: potmId ?? this.potmId,
        submitted: submitted ?? this.submitted,
      );
}

/// A finished game from one player's point of view.
class MatchResult {
  const MatchResult({
    required this.gameId,
    required this.venueName,
    required this.format,
    required this.playedAt,
    required this.myTeam,
    required this.myScore,
    required this.theirScore,
    required this.goals,
    required this.assists,
    required this.potm,
  });

  final String gameId;
  final String venueName;
  final GameFormat format;
  final DateTime playedAt;
  final Team myTeam;
  final int myScore;
  final int theirScore;
  final int goals;
  final int assists;
  final bool potm;

  bool get won => myScore > theirScore;
  bool get drew => myScore == theirScore;

  /// "W 7–5"
  String get scoreLine =>
      '${won ? 'W' : drew ? 'D' : 'L'} $myScore–$theirScore';
}

/// A reward unlocked by playing (streaks, milestones, referrals).
class Reward {
  const Reward({
    required this.title,
    required this.subtitle,
    this.creditPence,
  });

  final String title;
  final String subtitle;
  final int? creditPence;
}

/// Everything shown on the post-game screen.
class PostGameSummary {
  const PostGameSummary({
    required this.result,
    required this.streakWeeks,
    required this.unlocked,
    required this.nextMilestone,
  });

  final MatchResult result;
  final int streakWeeks;
  final List<Reward> unlocked;
  final Milestone nextMilestone;
}

/// Progress towards a reward.
class Milestone {
  const Milestone({
    required this.title,
    required this.progress,
    required this.target,
    required this.rewardLabel,
    this.isStreak = false,
  });

  final String title;
  final int progress;
  final int target;
  final String rewardLabel;
  final bool isStreak;

  double get ratio => (progress / target).clamp(0, 1).toDouble();
  int get remaining => (target - progress).clamp(0, target);
}
