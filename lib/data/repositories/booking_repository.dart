import '../models/models.dart';

/// Booking, paying and cancelling.
///
/// Real version: a Postgres function that locks the game row, so two people
/// can't take the last space, plus Stripe for payment.
abstract interface class BookingRepository {
  Future<BookingQuote> quote(String gameId);

  /// Holds a space for a few minutes (AppConfig.spaceHold) while the
  /// player pays.
  Future<SpaceHold> holdSpace(String gameId);

  Future<Booking> confirm(SpaceHold hold, {required bool useWallet});

  /// Cancels a booking. Inside the free window it's refunded; outside it,
  /// it's refunded only if someone else fills the space.
  Future<CancelOutcome> cancel(String gameId);

  Future<void> joinWaitlist(String gameId);
}
