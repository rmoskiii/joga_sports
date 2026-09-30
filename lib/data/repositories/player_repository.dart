import '../models/models.dart';

/// The signed-in player: profile, stats, streak and results.
abstract interface class PlayerRepository {
  Future<Player> currentPlayer();

  Future<HomeSummary> homeSummary();

  Future<PlayerStats> stats(StatsPeriod period);

  Future<Streak> streak();

  Future<List<MatchResult>> recentResults();

  Future<PostGameSummary> postGame(String gameId);

  /// Demo only: switch between player, organiser and admin views.
  Future<void> setRole(UserRole role);
}
