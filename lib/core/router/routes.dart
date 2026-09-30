/// Every route in the app. Use these helpers instead of typing paths.
abstract final class Routes {
  static const onboarding = '/onboarding';

  // Bottom-nav tabs
  static const home = '/home';
  static const find = '/find';
  static const myGames = '/my-games';
  static const stats = '/stats';
  static const profile = '/profile';

  // Game flow
  static String game(String id) => '/game/$id';
  static String checkout(String id) => '/game/$id/checkout';
  static String confirmed(String id) => '/game/$id/confirmed';
  static String gameDay(String id) => '/game/$id/day';
  static String matchControl(String id) => '/game/$id/match-control';
  static String postGame(String id) => '/game/$id/post-game';

  // Player
  static const streak = '/streak';
  static const wallet = '/wallet';
  static const membership = '/joga-plus';

  // Compete (after test)
  static const leaderboard = '/leaderboard';
  static const referrals = '/referrals';

  // Operations
  static const admin = '/admin';

  /// Demo only: index of every screen.
  static const demo = '/demo';
}
