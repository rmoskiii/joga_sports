/// Joga+ membership offer.
class MembershipOffer {
  const MembershipOffer({
    required this.name,
    required this.monthlyPence,
    required this.benefits,
    required this.isActive,
  });

  final String name;
  final int monthlyPence;
  final List<String> benefits;
  final bool isActive;
}
