/// App-wide constants. Product names and prices live here so they are easy
/// to change in one place.
abstract final class AppConfig {
  static const appName = 'Joga Sports';
  static const membershipName = 'Joga+';

  static const bookingFeePence = 100;
  static const membershipMonthlyPence = 499;
  static const referralRewardPence = 200;

  /// How long the last space is held while a player pays.
  static const spaceHold = Duration(minutes: 5);

  /// Free cancellation window before kick-off.
  static const freeCancellation = Duration(hours: 24);
}
