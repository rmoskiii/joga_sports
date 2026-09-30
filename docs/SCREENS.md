# Screens

18 product screens plus the demo index, grouped by the player loop.
"After test" screens are built but switched off for the MVP via
`FeatureFlags`.

| # | Stage | Screen | Route | File | Scope |
|---|---|---|---|---|---|
| 1 | Find | Onboarding | `/onboarding` | `features/onboarding/onboarding_screen.dart` | MVP |
| 2 | Find | Home | `/home` | `features/home/home_screen.dart` | MVP |
| 3 | Find | Find games | `/find` | `features/find/find_screen.dart` | MVP |
| 4 | Book | Game details | `/game/:id` | `features/game/game_details_screen.dart` | MVP |
| 5 | Book | Checkout (5-minute hold) | `/game/:id/checkout` | `features/booking/checkout_screen.dart` | MVP |
| 6 | Book | Booking confirmed | `/game/:id/confirmed` | `features/booking/booking_confirmed_screen.dart` | MVP |
| 7 | Play | My games | `/my-games` | `features/my_games/my_games_screen.dart` | MVP |
| 8 | Play | Game day | `/game/:id/day` | `features/game_day/game_day_screen.dart` | MVP |
| 9 | Play | Match control (organiser) | `/game/:id/match-control` | `features/match_control/match_control_screen.dart` | MVP |
| 10 | Track | Post-game + share card | `/game/:id/post-game` | `features/post_game/post_game_screen.dart` | MVP |
| 11 | Track | Stats | `/stats` | `features/stats/stats_screen.dart` | MVP |
| 12 | Track | Profile | `/profile` | `features/profile/profile_screen.dart` | MVP |
| 13 | Reward | Streak | `/streak` | `features/streak/streak_screen.dart` | MVP |
| 14 | Compete | City leaderboard | `/leaderboard` | `features/leaderboard/leaderboard_screen.dart` | After test |
| 15 | Reward | Wallet | `/wallet` | `features/wallet/wallet_screen.dart` | MVP |
| 16 | Grow | Joga+ | `/joga-plus` | `features/membership/membership_screen.dart` | MVP |
| 17 | Grow | Referrals | `/referrals` | `features/referrals/referrals_screen.dart` | After test |
| 18 | Run | Admin dashboard | `/admin` | `features/admin/admin_screen.dart` | MVP |
| – | Demo | All screens index | `/demo` | `features/demo/demo_hub_screen.dart` | Demo only |

## Differentiators built into the demo

- **For you** games on Home (level, city, casual tags)
- **5-minute hold** on the last space at checkout
- **Refund if your space is filled** on late cancellations
- **Reliability %** on the player profile
- **Game tags**: Casual, Competitive, Mixed, Over-30s, Women's
- **Shareable post-game card**
- **Sport switcher** with padel and badminton marked "soon"
