import '../models/models.dart';

/// Joga+.
///
/// Real version: RevenueCat, backed by App Store / Google Play billing in
/// the apps and Stripe on the web.
abstract interface class MembershipRepository {
  Future<MembershipOffer> offer();

  Future<void> subscribe();
}
