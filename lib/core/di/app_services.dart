import 'package:flutter/foundation.dart';

import '../../data/fake/fake_database.dart';
import '../../data/fake/fake_repositories.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/compete_repository.dart';
import '../../data/repositories/games_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/membership_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/wallet_repository.dart';

/// Every repository the app uses, in one place.
///
/// Screens only ever talk to these interfaces. To move from dummy data to
/// the real backend, add an `AppServices.supabase()` factory that builds
/// Supabase implementations, and switch to it in `main.dart`.
class AppServices {
  AppServices({
    required this.auth,
    required this.games,
    required this.bookings,
    required this.player,
    required this.matches,
    required this.wallet,
    required this.compete,
    required this.membership,
    required this.admin,
    required this.changes,
  });

  /// Demo mode: everything runs in memory with dummy data for Ray.
  factory AppServices.fake({
    Duration latency = const Duration(milliseconds: 250),
  }) {
    final db = FakeDatabase(latency: latency);
    return AppServices(
      auth: FakeAuthRepository(db),
      games: FakeGamesRepository(db),
      bookings: FakeBookingRepository(db),
      player: FakePlayerRepository(db),
      matches: FakeMatchRepository(db),
      wallet: FakeWalletRepository(db),
      compete: FakeCompeteRepository(db),
      membership: FakeMembershipRepository(db),
      admin: FakeAdminRepository(db),
      changes: db,
    );
  }

  final AuthRepository auth;
  final GamesRepository games;
  final BookingRepository bookings;
  final PlayerRepository player;
  final MatchRepository matches;
  final WalletRepository wallet;
  final CompeteRepository compete;
  final MembershipRepository membership;
  final AdminRepository admin;

  /// Fires whenever data changes, so open screens reload. In the real app
  /// this is driven by Supabase realtime or by the repositories after
  /// writes.
  final Listenable changes;
}
