import '../models/models.dart';

/// Organiser's Match Control.
abstract interface class MatchRepository {
  Future<MatchSheet> loadSheet(String gameId);

  /// Submitting updates every player's stats, streaks and rewards.
  Future<void> submit(MatchSheet sheet);
}
