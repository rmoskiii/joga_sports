import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_screen.dart';
import '../../features/booking/booking_confirmed_screen.dart';
import '../../features/booking/checkout_screen.dart';
import '../../features/demo/demo_hub_screen.dart';
import '../../features/find/find_screen.dart';
import '../../features/game/game_details_screen.dart';
import '../../features/game_day/game_day_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/match_control/match_control_screen.dart';
import '../../features/membership/membership_screen.dart';
import '../../features/my_games/my_games_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/post_game/post_game_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/referrals/referrals_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/streak/streak_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import 'routes.dart';

/// App navigation.
///
/// The five tabs live in a [StatefulShellRoute] so each tab keeps its own
/// scroll position and history. Everything else opens full screen on top.
GoRouter buildRouter({String initialLocation = Routes.onboarding}) {
  String id(GoRouterState state) => state.pathParameters['id']!;

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          _tab(Routes.home, const HomeScreen()),
          _tab(Routes.find, const FindScreen()),
          _tab(Routes.myGames, const MyGamesScreen()),
          _tab(Routes.stats, const StatsScreen()),
          _tab(Routes.profile, const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/game/:id',
        builder: (context, state) => GameDetailsScreen(gameId: id(state)),
        routes: [
          GoRoute(
            path: 'checkout',
            builder: (context, state) => CheckoutScreen(gameId: id(state)),
          ),
          GoRoute(
            path: 'confirmed',
            builder: (context, state) =>
                BookingConfirmedScreen(gameId: id(state)),
          ),
          GoRoute(
            path: 'day',
            builder: (context, state) => GameDayScreen(gameId: id(state)),
          ),
          GoRoute(
            path: 'match-control',
            builder: (context, state) => MatchControlScreen(gameId: id(state)),
          ),
          GoRoute(
            path: 'post-game',
            builder: (context, state) => PostGameScreen(gameId: id(state)),
          ),
        ],
      ),
      GoRoute(
        path: Routes.streak,
        builder: (context, state) => const StreakScreen(),
      ),
      GoRoute(
        path: Routes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: Routes.membership,
        builder: (context, state) => const MembershipScreen(),
      ),
      GoRoute(
        path: Routes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: Routes.referrals,
        builder: (context, state) => const ReferralsScreen(),
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: Routes.demo,
        builder: (context, state) => const DemoHubScreen(),
      ),
    ],
  );
}

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
      routes: [
        GoRoute(path: path, builder: (context, state) => screen),
      ],
    );
