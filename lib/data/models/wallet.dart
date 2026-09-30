import 'match.dart';

enum WalletEntryType { reward, referral, booking, refund, topUp }

class WalletEntry {
  const WalletEntry({
    required this.label,
    required this.type,
    required this.amountPence,
    required this.date,
  });

  final String label;
  final WalletEntryType type;

  /// Positive for credit in, negative for credit spent.
  final int amountPence;
  final DateTime date;
}

/// Wallet credit. The balance is always the sum of the entries, mirroring
/// the append-only ledger in the database.
class Wallet {
  const Wallet({required this.entries, required this.milestones});

  final List<WalletEntry> entries;
  final List<Milestone> milestones;

  int get balancePence => entries.fold(0, (sum, e) => sum + e.amountPence);
}
