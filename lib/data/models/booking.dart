/// Price breakdown shown before paying.
class BookingQuote {
  const BookingQuote({
    required this.gamePence,
    required this.feePence,
    required this.walletAvailablePence,
    required this.isMember,
  });

  final int gamePence;

  /// Booking fee. Zero for Joga+ members.
  final int feePence;
  final int walletAvailablePence;
  final bool isMember;

  int get subtotalPence => gamePence + feePence;

  int walletAppliedPence({required bool useWallet}) => useWallet
      ? (walletAvailablePence < subtotalPence
          ? walletAvailablePence
          : subtotalPence)
      : 0;

  int totalPence({required bool useWallet}) =>
      subtotalPence - walletAppliedPence(useWallet: useWallet);
}

/// A space held for a player while they pay, so no one else can take it.
class SpaceHold {
  const SpaceHold({
    required this.id,
    required this.gameId,
    required this.expiresAt,
  });

  final String id;
  final String gameId;
  final DateTime expiresAt;

  Duration remaining([DateTime? now]) =>
      expiresAt.difference(now ?? DateTime.now());

  bool isExpired([DateTime? now]) => remaining(now).isNegative;
}

class Booking {
  const Booking({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.paidPence,
    required this.walletUsedPence,
    required this.createdAt,
  });

  final String id;
  final String gameId;
  final String playerId;
  final int paidPence;
  final int walletUsedPence;
  final DateTime createdAt;
}

/// What happens to the money when a player cancels.
enum CancelOutcome {
  /// Cancelled inside the free window: refunded to the wallet.
  refunded,

  /// Late cancellation: refunded only if someone else takes the space.
  refundIfFilled,
}
