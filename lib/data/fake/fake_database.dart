import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'fake_seed.dart';

/// In-memory stand-in for the real backend.
///
/// Holds all demo state for the session and notifies listeners whenever
/// something changes, so every screen showing that data refreshes. Replaced
/// by Supabase in the real app; nothing outside `data/fake` knows it exists.
class FakeDatabase extends ChangeNotifier {
  FakeDatabase({
    this.latency = const Duration(milliseconds: 250),
    DateTime? now,
  }) : seededAt = now ?? DateTime.now() {
    _seed();
  }

  /// Simulated network delay, so loading states are visible in the demo.
  final Duration latency;
  final DateTime seededAt;

  late Player me;
  final Map<String, Game> games = {};
  final Map<String, Game> finishedGames = {};
  final Map<String, MatchSheet> submittedSheets = {};
  final Map<String, SpaceHold> holds = {};
  final Set<String> waitlist = {};
  final List<MatchResult> results = [];
  final Map<String, List<Reward>> rewardsByGame = {};
  final List<WalletEntry> walletEntries = [];
  final Map<StatsPeriod, StatCounters> counters = {};
  final List<FormEntry> form = [];
  final List<bool> lastTwelveWeeks = [];

  bool signedIn = false;
  int streakWeeks = 4;
  int bestStreakWeeks = 9;
  bool playedThisWeek = false;

  int _nextId = 1000;

  String newId(String prefix) => '$prefix-${_nextId++}';

  DateTime get now => DateTime.now();

  Future<void> wait() => Future<void>.delayed(latency);

  /// Call after every write.
  void changed() => notifyListeners();

  Game game(String id) {
    final game = games[id] ?? finishedGames[id];
    if (game == null) throw StateError('Game $id not found');
    return game;
  }

  int get walletBalancePence =>
      walletEntries.fold(0, (sum, e) => sum + e.amountPence);

  void _seed() {
    me = FakeSeed.player(seededAt);
    for (final g in FakeSeed.games(seededAt)) {
      games[g.id] = g;
    }
    for (final g in FakeSeed.finishedToday(seededAt)) {
      finishedGames[g.id] = g;
    }
    results
      ..add(FakeSeed.lastResult(seededAt))
      ..addAll(FakeSeed.olderResults(seededAt));
    rewardsByGame[FakeSeed.lastPlayedGameId] = FakeSeed.lastResultRewards;
    walletEntries.addAll(FakeSeed.walletEntries(seededAt));
    form.addAll(FakeSeed.form);
    lastTwelveWeeks.addAll(FakeSeed.lastTwelveWeeks);
    counters
      ..[StatsPeriod.career] = StatCounters(24, 18, 11, 4, 14)
      ..[StatsPeriod.season] = StatCounters(12, 8, 6, 2, 7)
      ..[StatsPeriod.month] = StatCounters(4, 5, 3, 1, 3);
  }
}

/// Mutable running totals for one stats period.
class StatCounters {
  StatCounters(this.games, this.goals, this.assists, this.potm, this.wins);

  int games;
  int goals;
  int assists;
  int potm;
  int wins;
}
