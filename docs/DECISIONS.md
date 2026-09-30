# Product decisions

Agreed before the build. Change here first, then in code.

| Topic | Decision | Where in code |
|---|---|---|
| Name | Joga Sports; membership is **Joga+** | `AppConfig` |
| Launch sport | Football only. Data model is sport-aware (`Sport`, `GameFormat`) so padel and badminton slot in later | `data/models/enums.dart` |
| Streak rule | **Weekly**: play at least once Monday–Sunday. Joga+ gets one streak freeze a month | `Streak`, `FakeMatchRepository` |
| Player of the match | **Picked by the organiser** in Match control. Player vote can come later | `match_control_screen.dart` |
| Player ratings | **None for now.** Post-game feedback is about the game and organiser, not players | `post_game_screen.dart` |
| Leaderboards, referrals, waitlist | Built, **switched on after the test period** | `FeatureFlags` |
| Admin | **Desktop web first**, with a phone layout for today's games | `admin_screen.dart` |
| Joga+ benefits | No booking fees, full stats, streak freeze, double milestone rewards, early access | `FakeSeed.membershipBenefits` |
| Booking fee | £1 per booking, free for Joga+ | `AppConfig.bookingFeePence` |
| Space hold | 5 minutes while paying | `AppConfig.spaceHold` |
| Cancellation | Free up to 24h before. After that, refunded only if the space is filled | `AppConfig.freeCancellation` |
| Photos | Placeholder pitch graphics until venue photos exist | `PitchPhoto` |

## Still to decide

- Reward amounts per milestone (placeholders: £2.50 at 25 games, £5 at a
  10-week streak, doubled for Joga+)
- Whether organisers and venues are paid through the platform (Stripe
  Connect)
- Final logo (the `JogaLogo` widget is a placeholder)
