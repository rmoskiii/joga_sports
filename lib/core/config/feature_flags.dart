/// Features that are designed but switched on after the test period.
///
/// In the demo everything is on so the full vision can be reviewed. Before
/// the MVP ships, set the "after test" flags to false.
abstract final class FeatureFlags {
  // After the test period (P1)
  static const leaderboards = true;
  static const referrals = true;
  static const waitlist = true;

  // Future sports. Shown as "coming soon" in the sport switcher.
  static const multiSport = false;
}
