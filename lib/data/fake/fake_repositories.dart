import '../../core/config/app_config.dart';
import '../../core/utils/formatters.dart';
import '../models/models.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/compete_repository.dart';
import '../repositories/games_repository.dart';
import '../repositories/match_repository.dart';
import '../repositories/membership_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/wallet_repository.dart';
import 'fake_database.dart';
import 'fake_seed.dart';

// Fake implementations of every repository, backed by [FakeDatabase].
// Each one mirrors what the real Supabase version will do, so screens
// don't change when the real backend is wired in.

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._db);
  final FakeDatabase _db;

  @override
  bool get isSignedIn => _db.signedIn;

  Future<void> _signIn() async {
    await _db.wait();
    _db.signedIn = true;
    _db.changed();
  }

  @override
  Future<void> signInWithApple() => _signIn();

  @override
  Future<void> signInWithGoogle() => _signIn();

  @override
  Future<void> signInWithEmail(String email) => _signIn();

  @override
  Future<void> signOut() async {
    await _db.wait();
    _db.signedIn = false;
    _db.changed();
  }
}

class FakeGamesRepository implements GamesRepository {
  FakeGamesRepository(this._db);
  final FakeDatabase _db;

  Iterable<Game> get _upcoming =>
      _db.games.values.where((g) => g.startsAt.isAfter(_db.now)).toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  @override
  Future<List<Game>> findGames(GameFilter filter) async {
    await _db.wait();
    final today = DateTime(_db.now.year, _db.now.month, _db.now.day);
    bool matchesDay(DateTime d) {
      final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
      return switch (filter.day) {
        DayFilter.all => true,
        DayFilter.today => diff == 0,
        DayFilter.tomorrow => diff == 1,
        DayFilter.weekend =>
          d.weekday == DateTime.saturday || d.weekday == DateTime.sunday,
      };
    }

    return _upcoming
        .where((g) => g.venue.city == filter.city)
        .where((g) => matchesDay(g.startsAt))
        .where((g) => filter.format == null || g.format == filter.format)
        .where((g) => filter.level == null || g.level == filter.level)
        .where((g) => filter.tag == null || g.tags.contains(filter.tag))
        .where(
          (g) =>
              filter.maxPricePence == null ||
              g.pricePence <= filter.maxPricePence!,
        )
        .toList();
  }

  @override
  Future<List<Game>> recommendedFor(String playerId) async {
    await _db.wait();
    final me = _db.me;
    return _upcoming
        .where((g) => g.venue.city == me.city)
        .where((g) => !g.isFull && !g.hasPlayer(playerId))
        .where((g) => g.level == me.level || g.tags.contains(GameTag.casual))
        .take(3)
        .toList();
  }

  @override
  Future<Game> getGame(String gameId) async {
    await _db.wait();
    return _db.game(gameId);
  }

  @override
  Future<List<Game>> upcomingFor(String playerId) async {
    await _db.wait();
    final since = _db.now.subtract(const Duration(hours: 2));
    return _db.games.values
        .where((g) => g.hasPlayer(playerId) && g.startsAt.isAfter(since))
        .where((g) => !_db.submittedSheets.containsKey(g.id))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }
}

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository(this._db);
  final FakeDatabase _db;

  @override
  Future<BookingQuote> quote(String gameId) async {
    await _db.wait();
    final game = _db.game(gameId);
    return BookingQuote(
      gamePence: game.pricePence,
      feePence: _db.me.isMember ? 0 : AppConfig.bookingFeePence,
      walletAvailablePence: _db.walletBalancePence,
      isMember: _db.me.isMember,
    );
  }

  @override
  Future<SpaceHold> holdSpace(String gameId) async {
    await _db.wait();
    final game = _db.game(gameId);
    if (game.isFull) throw StateError('This game is full');
    final hold = SpaceHold(
      id: _db.newId('hold'),
      gameId: gameId,
      expiresAt: _db.now.add(AppConfig.spaceHold),
    );
    _db.holds[hold.id] = hold;
    return hold;
  }

  @override
  Future<Booking> confirm(SpaceHold hold, {required bool useWallet}) async {
    await _db.wait();
    if (!_db.holds.containsKey(hold.id) || hold.isExpired(_db.now)) {
      throw StateError('Your hold expired. Please try again.');
    }
    _db.holds.remove(hold.id);

    final game = _db.game(hold.gameId);
    final quote = BookingQuote(
      gamePence: game.pricePence,
      feePence: _db.me.isMember ? 0 : AppConfig.bookingFeePence,
      walletAvailablePence: _db.walletBalancePence,
      isMember: _db.me.isMember,
    );
    final walletUsed = quote.walletAppliedPence(useWallet: useWallet);

    _db.games[game.id] = game.copyWith(
      players: [...game.players, _db.me.person],
    );
    if (walletUsed > 0) {
      _db.walletEntries.add(
        WalletEntry(
          label: 'Game booking · ${game.venue.name}',
          type: WalletEntryType.booking,
          amountPence: -walletUsed,
          date: _db.now,
        ),
      );
    }
    _db.changed();

    return Booking(
      id: _db.newId('booking'),
      gameId: game.id,
      playerId: _db.me.id,
      paidPence: quote.totalPence(useWallet: useWallet),
      walletUsedPence: walletUsed,
      createdAt: _db.now,
    );
  }

  @override
  Future<CancelOutcome> cancel(String gameId) async {
    await _db.wait();
    final game = _db.game(gameId);
    _db.games[gameId] = game.copyWith(
      players: game.players.where((p) => p.id != _db.me.id).toList(),
    );

    final insideFreeWindow =
        game.startsAt.difference(_db.now) >= AppConfig.freeCancellation;
    if (insideFreeWindow) {
      _db.walletEntries.add(
        WalletEntry(
          label: 'Refund · ${game.venue.name}',
          type: WalletEntryType.refund,
          amountPence: game.pricePence,
          date: _db.now,
        ),
      );
    }
    _db.changed();
    return insideFreeWindow
        ? CancelOutcome.refunded
        : CancelOutcome.refundIfFilled;
  }

  @override
  Future<void> joinWaitlist(String gameId) async {
    await _db.wait();
    _db.waitlist.add(gameId);
    _db.changed();
  }
}

class FakePlayerRepository implements PlayerRepository {
  FakePlayerRepository(this._db);
  final FakeDatabase _db;

  static const _gameMilestones = [10, 25, 50, 100, 250];

  @override
  Future<Player> currentPlayer() async {
    await _db.wait();
    return _db.me;
  }

  @override
  Future<HomeSummary> homeSummary() async {
    await _db.wait();
    return HomeSummary(
      stats: _stats(StatsPeriod.season),
      streak: _streak(),
      lastResult: _db.results.isEmpty ? null : _db.results.first,
    );
  }

  @override
  Future<PlayerStats> stats(StatsPeriod period) async {
    await _db.wait();
    return _stats(period);
  }

  @override
  Future<Streak> streak() async {
    await _db.wait();
    return _streak();
  }

  @override
  Future<List<MatchResult>> recentResults() async {
    await _db.wait();
    return List.unmodifiable(_db.results);
  }

  @override
  Future<PostGameSummary> postGame(String gameId) async {
    await _db.wait();
    final result = _db.results.firstWhere(
      (r) => r.gameId == gameId,
      orElse: () => throw StateError('No result for game $gameId yet'),
    );
    return PostGameSummary(
      result: result,
      streakWeeks: _db.streakWeeks,
      unlocked: _db.rewardsByGame[gameId] ?? const [],
      nextMilestone: _nextGamesMilestone(),
    );
  }

  @override
  Future<void> setRole(UserRole role) async {
    _db.me = _db.me.copyWith(role: role);
    _db.changed();
  }

  PlayerStats _stats(StatsPeriod period) {
    final c = _db.counters[period]!;
    return PlayerStats(
      period: period,
      games: c.games,
      goals: c.goals,
      assists: c.assists,
      potm: c.potm,
      wins: c.wins,
      form: List.unmodifiable(_db.form),
      bestVenue: FakeSeed.golCardiff.name,
      cityRank: 8,
    );
  }

  Streak _streak() {
    final now = _db.now;
    final sunday = DateTime(now.year, now.month, now.day + (7 - now.weekday));
    return Streak(
      currentWeeks: _db.streakWeeks,
      bestWeeks: _db.bestStreakWeeks,
      lastTwelveWeeks: List.unmodifiable(_db.lastTwelveWeeks),
      playedThisWeek: _db.playedThisWeek,
      weekEndsAt: DateTime(sunday.year, sunday.month, sunday.day, 23, 59),
      nextReward: Milestone(
        title: '10-week streak',
        progress: _db.streakWeeks,
        target: 10,
        rewardLabel: _db.me.isMember ? '£10 wallet credit' : '£5 wallet credit',
        isStreak: true,
      ),
      freezesLeft: _db.me.isMember ? 1 : 0,
    );
  }

  Milestone _nextGamesMilestone() {
    final played = _db.counters[StatsPeriod.career]!.games;
    final target = _gameMilestones.firstWhere(
      (m) => m > played,
      orElse: () => played + 100,
    );
    return Milestone(
      title: '$target games played',
      progress: played,
      target: target,
      rewardLabel: 'A free game',
    );
  }
}

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository(this._db);
  final FakeDatabase _db;

  @override
  Future<MatchSheet> loadSheet(String gameId) async {
    await _db.wait();
    final existing = _db.submittedSheets[gameId];
    if (existing != null) return existing;

    final game = _db.game(gameId);
    final half = (game.players.length / 2).ceil();
    return MatchSheet(
      game: game,
      lines: [
        for (var i = 0; i < game.players.length; i++)
          MatchLine(
            person: game.players[i],
            team: i < half ? Team.white : Team.orange,
          ),
      ],
    );
  }

  @override
  Future<void> submit(MatchSheet sheet) async {
    await _db.wait();
    final game = sheet.game;
    _db.submittedSheets[game.id] = sheet.copyWith(submitted: true);

    final myLine = sheet.lines.where((l) => l.person.id == _db.me.id);
    if (myLine.isEmpty || !myLine.first.attended) {
      _db.changed();
      return;
    }
    final line = myLine.first;
    final other = line.team == Team.white ? Team.orange : Team.white;
    final result = MatchResult(
      gameId: game.id,
      venueName: game.venue.name,
      format: game.format,
      playedAt: game.startsAt,
      myTeam: line.team,
      myScore: sheet.scoreFor(line.team),
      theirScore: sheet.scoreFor(other),
      goals: line.goals,
      assists: line.assists,
      potm: sheet.potmId == _db.me.id,
    );
    _db.results.insert(0, result);
    _applyToStats(result);
    _db.changed();
  }

  void _applyToStats(MatchResult r) {
    for (final c in _db.counters.values) {
      c
        ..games += 1
        ..goals += r.goals
        ..assists += r.assists
        ..potm += r.potm ? 1 : 0
        ..wins += r.won ? 1 : 0;
    }
    _db.form
      ..add(FormEntry(goals: r.goals, assists: r.assists, won: r.won))
      ..removeAt(0);

    final rewards = <Reward>[];
    if (!_db.playedThisWeek) {
      _db.playedThisWeek = true;
      _db.streakWeeks += 1;
      if (_db.streakWeeks > _db.bestStreakWeeks) {
        _db.bestStreakWeeks = _db.streakWeeks;
      }
      _db.lastTwelveWeeks[_db.lastTwelveWeeks.length - 1] = true;
      rewards.add(
        Reward(
          title: '${_db.streakWeeks}-week streak',
          subtitle: 'Play again next week to keep it going',
        ),
      );
    }
    if (r.potm) {
      rewards.add(
        const Reward(
            title: 'Player of the match', subtitle: 'Picked by the organiser'),
      );
    }

    final career = _db.counters[StatsPeriod.career]!.games;
    if (career == 25 || career == 50 || career == 100) {
      final credit = _db.me.isMember ? 500 : 250;
      rewards.add(
        Reward(
          title: 'Milestone reached',
          subtitle: '$career games played',
          creditPence: credit,
        ),
      );
      _db.walletEntries.add(
        WalletEntry(
          label: '$career games milestone',
          type: WalletEntryType.reward,
          amountPence: credit,
          date: _db.now,
        ),
      );
    }
    _db.rewardsByGame[r.gameId] = rewards;
  }
}

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this._db);
  final FakeDatabase _db;

  @override
  Future<Wallet> wallet() async {
    await _db.wait();
    final career = _db.counters[StatsPeriod.career]!.games;
    final multiplier = _db.me.isMember ? 2 : 1;
    return Wallet(
      entries: _db.walletEntries.reversed.toList(),
      milestones: [
        Milestone(
          title: career < 25 ? '25 games' : '50 games',
          progress: career,
          target: career < 25 ? 25 : 50,
          rewardLabel: Format.money(250 * multiplier),
        ),
        Milestone(
          title: '10-week streak',
          progress: _db.streakWeeks,
          target: 10,
          rewardLabel: Format.money(500 * multiplier),
          isStreak: true,
        ),
        Milestone(
          title: '10 POTM awards',
          progress: _db.counters[StatsPeriod.career]!.potm,
          target: 10,
          rewardLabel: 'Badge',
        ),
      ],
    );
  }
}

class FakeCompeteRepository implements CompeteRepository {
  FakeCompeteRepository(this._db);
  final FakeDatabase _db;

  @override
  Future<Leaderboard> leaderboard(City city, LeaderboardMetric metric) async {
    await _db.wait();
    final pool = city == City.cardiff
        ? FakeSeed.people.take(12).toList()
        : FakeSeed.people.skip(12).take(12).toList();
    final base = switch (metric) {
      LeaderboardMetric.goals => [14, 12, 10, 9, 8, 7, 7, 6, 5, 5, 4, 3],
      LeaderboardMetric.assists => [11, 9, 9, 8, 7, 6, 5, 5, 4, 4, 3, 2],
      LeaderboardMetric.potm => [4, 3, 3, 2, 2, 2, 1, 1, 1, 1, 1, 0],
      LeaderboardMetric.streak => [14, 12, 11, 9, 8, 8, 7, 6, 5, 4, 4, 3],
    };

    final entries = <LeaderboardEntry>[];
    if (city == _db.me.city) {
      // Put Ray in 8th so the "you" row is visible.
      final myValue = switch (metric) {
        LeaderboardMetric.goals => _db.counters[StatsPeriod.month]!.goals + 1,
        LeaderboardMetric.assists =>
          _db.counters[StatsPeriod.month]!.assists + 2,
        LeaderboardMetric.potm => _db.counters[StatsPeriod.month]!.potm,
        LeaderboardMetric.streak => _db.streakWeeks,
      };
      for (var i = 0; i < 7; i++) {
        entries.add(_entry(i + 1, pool[i], base[i]));
      }
      entries.add(
        LeaderboardEntry(
            position: 8, person: _db.me.person, value: myValue, isMe: true),
      );
      for (var i = 7; i < 10; i++) {
        entries.add(_entry(i + 2, pool[i], base[i + 1]));
      }
    } else {
      for (var i = 0; i < 10; i++) {
        entries.add(_entry(i + 1, pool[i], base[i]));
      }
    }

    return Leaderboard(
      city: city,
      metric: metric,
      monthLabel: _monthName(_db.now.month),
      entries: entries,
      prize: 'Top of the ${metric.label.toLowerCase()} table wins a month of '
          'free games.',
    );
  }

  @override
  Future<Referrals> referrals() async {
    await _db.wait();
    return Referrals(
      code: '${_db.me.firstName.toUpperCase()}24',
      rewardPence: AppConfig.referralRewardPence,
      entries: FakeSeed.referrals,
    );
  }

  LeaderboardEntry _entry(int position, Person person, int value) =>
      LeaderboardEntry(
          position: position, person: person, value: value, isMe: false);

  static String _monthName(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];
}

class FakeMembershipRepository implements MembershipRepository {
  FakeMembershipRepository(this._db);
  final FakeDatabase _db;

  @override
  Future<MembershipOffer> offer() async {
    await _db.wait();
    return MembershipOffer(
      name: AppConfig.membershipName,
      monthlyPence: AppConfig.membershipMonthlyPence,
      benefits: FakeSeed.membershipBenefits,
      isActive: _db.me.isMember,
    );
  }

  @override
  Future<void> subscribe() async {
    await _db.wait();
    _db.me = _db.me.copyWith(isMember: true);
    _db.changed();
  }
}

class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository(this._db);
  final FakeDatabase _db;

  static const _venueCostPence = {
    GameFormat.fiveASide: 5500,
    GameFormat.sevenASide: 7000,
  };

  @override
  Future<AdminDashboard> dashboard() async {
    await _db.wait();
    final weekAhead = _db.now.add(const Duration(days: 7));

    AdminGameRow row(Game g, {required bool outstanding}) => AdminGameRow(
          game: g,
          revenuePence: g.booked * g.pricePence,
          venueCostPence: _venueCostPence[g.format]!,
          resultOutstanding: outstanding,
        );

    final finished = _db.finishedGames.values
        .where((g) => !_db.submittedSheets.containsKey(g.id))
        .map((g) => row(g, outstanding: true));
    final upcoming = _db.games.values
        .where((g) => g.startsAt.isBefore(weekAhead))
        .where((g) => !_db.submittedSheets.containsKey(g.id))
        .map((g) => row(g, outstanding: false));

    return AdminDashboard(
      date: _db.now,
      games: [...finished, ...upcoming]
        ..sort((a, b) => a.game.startsAt.compareTo(b.game.startsAt)),
    );
  }
}
