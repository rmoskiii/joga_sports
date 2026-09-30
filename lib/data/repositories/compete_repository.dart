import '../models/models.dart';

/// Leaderboards and referrals (after the test period).
abstract interface class CompeteRepository {
  Future<Leaderboard> leaderboard(City city, LeaderboardMetric metric);

  Future<Referrals> referrals();
}
