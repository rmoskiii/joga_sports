import 'game.dart';

enum GameHealth {
  full('Full'),
  filling('Filling'),
  atRisk('At risk');

  const GameHealth(this.label);
  final String label;
}

/// One row in the admin's games list, with money per game.
class AdminGameRow {
  const AdminGameRow({
    required this.game,
    required this.revenuePence,
    required this.venueCostPence,
    required this.resultOutstanding,
  });

  final Game game;
  final int revenuePence;
  final int venueCostPence;

  /// The game has finished but the organiser hasn't submitted the result.
  final bool resultOutstanding;

  int get marginPence => revenuePence - venueCostPence;

  GameHealth get health {
    if (game.isFull) return GameHealth.full;
    if (game.fillRatio < 0.5) return GameHealth.atRisk;
    return GameHealth.filling;
  }
}

class AdminDashboard {
  const AdminDashboard({required this.date, required this.games});

  final DateTime date;
  final List<AdminGameRow> games;

  int get gamesCount => games.length;
  int get players => games.fold(0, (sum, g) => sum + g.game.booked);
  int get almostFull => games.where((g) => g.game.isAlmostFull).length;
  int get atRisk => games.where((g) => g.health == GameHealth.atRisk).length;
  int get resultsOutstanding => games.where((g) => g.resultOutstanding).length;
  int get revenuePence => games.fold(0, (sum, g) => sum + g.revenuePence);
  int get marginPence => games.fold(0, (sum, g) => sum + g.marginPence);
}
