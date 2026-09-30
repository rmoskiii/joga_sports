import '../models/models.dart';

/// Finding and reading games.
abstract interface class GamesRepository {
  Future<List<Game>> findGames(GameFilter filter);

  /// Personalised "For you" games: the player's level, usual days and
  /// favourite venues.
  Future<List<Game>> recommendedFor(String playerId);

  Future<Game> getGame(String gameId);

  /// Games the player has booked that haven't kicked off yet.
  Future<List<Game>> upcomingFor(String playerId);
}
