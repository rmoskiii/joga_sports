import 'package:flutter_test/flutter_test.dart';
import 'package:joga_sports/core/di/app_services.dart';
import 'package:joga_sports/data/fake/fake_seed.dart';
import 'package:joga_sports/data/models/models.dart';

void main() {
  late AppServices services;

  setUp(() => services = AppServices.fake(latency: Duration.zero));

  test('booking the last space fills the game and uses wallet credit',
      () async {
    const id = FakeSeed.lastSpaceGameId;
    final before = await services.wallet.wallet();

    final hold = await services.bookings.holdSpace(id);
    final booking = await services.bookings.confirm(hold, useWallet: true);

    final game = await services.games.getGame(id);
    final after = await services.wallet.wallet();

    expect(game.isFull, isTrue);
    expect(game.hasPlayer(FakeSeed.ray.id), isTrue);
    expect(booking.walletUsedPence, greaterThan(0));
    expect(
      after.balancePence,
      before.balancePence - booking.walletUsedPence,
    );
  });

  test('a full game cannot be held', () async {
    const id = FakeSeed.lastSpaceGameId;
    final hold = await services.bookings.holdSpace(id);
    await services.bookings.confirm(hold, useWallet: false);

    await expectLater(services.bookings.holdSpace(id), throwsStateError);
  });

  test('Joga+ members pay no booking fee', () async {
    await services.membership.subscribe();
    final quote = await services.bookings.quote(FakeSeed.lastSpaceGameId);
    expect(quote.feePence, 0);
  });

  test('submitting a result updates stats, streak and results', () async {
    const id = FakeSeed.tonightGameId;
    final statsBefore = await services.player.stats(StatsPeriod.career);
    final streakBefore = await services.player.streak();

    final sheet = await services.matches.loadSheet(id);
    final lines = [
      for (final line in sheet.lines)
        line.person.id == FakeSeed.ray.id ? line.copyWith(goals: 2) : line,
    ];
    await services.matches.submit(
      sheet.copyWith(lines: lines, potmId: FakeSeed.ray.id),
    );

    final statsAfter = await services.player.stats(StatsPeriod.career);
    final streakAfter = await services.player.streak();
    final summary = await services.player.postGame(id);

    expect(statsAfter.games, statsBefore.games + 1);
    expect(statsAfter.goals, statsBefore.goals + 2);
    expect(statsAfter.potm, statsBefore.potm + 1);
    expect(streakAfter.currentWeeks, streakBefore.currentWeeks + 1);
    expect(streakAfter.playedThisWeek, isTrue);
    expect(summary.result.potm, isTrue);
    expect(summary.unlocked, isNotEmpty);
  });

  test('match sheet score builds from goals', () async {
    final sheet = await services.matches.loadSheet(FakeSeed.tonightGameId);
    final lines = [
      for (final line in sheet.lines)
        line.team == Team.white ? line.copyWith(goals: 1) : line,
    ];
    final updated = sheet.copyWith(lines: lines);
    expect(updated.scoreFor(Team.white), updated.team(Team.white).length);
    expect(updated.scoreFor(Team.orange), 0);
  });
}
