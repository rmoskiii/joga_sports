# Joga Sports

Find, book and play organised football, with stats, streaks and rewards.
Launching in Cardiff and Bristol. Football first; padel, badminton and other
sports later.

This repo is the **demo skeleton**: every screen of the MVP, running on dummy
data for a player called **Ray**. There is no backend, login or payment yet.
The architecture is set up so real services slot in behind the same
interfaces without touching the screens.

---

## Quick start

Requires Flutter (stable) with Dart 3.6 or newer.

```bash
# First time only: creates the ios/, android/ and web/ folders,
# gets packages, formats, analyses and runs the tests.
./tool/setup.sh

# Run the demo
flutter run -d chrome        # web
flutter run                  # iOS simulator / Android emulator / device
```

In VS Code, open the folder and use the **Joga (Chrome)** or
**Joga (device / simulator)** launch configurations.

On Windows, run the commands in `tool/setup.sh` one by one.

## Demo walkthrough

1. **Get started** on onboarding (signs in as Ray).
2. **Home**: next game countdown, streak nudge, season numbers, "For you".
3. **Find** → Gôl Cardiff (last space) → **Join game** → checkout holds the
   space for 5 minutes → **Pay** → confirmation. The game now appears in
   My Games and the wallet balance drops.
4. **My games** → tonight's game → **Game day** → **Organiser view** →
   Match control: tick attendance, log goals and assists, pick POTM,
   **Submit**. Post-game shows the result, and stats, streak, wallet and
   milestones update across the app.
5. **Profile → All screens (demo index)** lists every screen. Profile also
   has a **View the app as** switch (Player / Organiser / Admin).

## Project structure

```
lib/
  main.dart                 Entry point. Picks demo or real services.
  app.dart                  Root widget: theme, router, services.
  core/
    config/                 App constants, feature flags
    di/                     AppServices (all repositories) + AppScope
    router/                 Routes (paths) + GoRouter setup
    theme/                  Colours, spacing, type scale, Material theme
    utils/                  Formatters (money, dates, countdowns)
    widgets/                Shared UI kit (buttons, cards, chips, game cards…)
  data/
    models/                 Plain Dart domain models (no code generation)
    repositories/           Interfaces the app talks to
    fake/                   In-memory demo backend + seed data for Ray
  features/                 One folder per screen or flow
    onboarding/ home/ find/ game/ booking/ my_games/ game_day/
    match_control/ post_game/ stats/ profile/ streak/ leaderboard/
    wallet/ membership/ referrals/ admin/ demo/ shell/
test/                       Unit tests for formatters and fake repositories,
                            plus a widget smoke test
docs/                       Screens, decisions, backend plan
```

## Architecture in one minute

```
Screen (features/)  →  AppServices (core/di)  →  Repository interface (data/repositories)
                                                   ├── Fake…Repository   (now)
                                                   └── Supabase…Repository (next)
```

- Screens never import `data/fake`. They call `context.services.<repo>`.
- `AsyncView` loads data, shows loading and error states, and reloads
  automatically when data changes (e.g. after a booking).
- Models are plain immutable classes with `copyWith`. No build_runner.
- Only one dependency: `go_router`. Fonts (Barlow, OFL licence) are bundled.

## Going from demo to real

1. Create the backend repo (see `docs/BACKEND_PLAN.md`).
2. Add `supabase_flutter`, then write `Supabase…Repository` classes that
   implement the interfaces in `data/repositories/`.
3. Add `AppServices.supabase()` and switch to it in `main.dart`.
4. Add an auth redirect in `core/router/app_router.dart`.
5. Turn the "after test" features off in `core/config/feature_flags.dart`.
6. Delete `features/demo/` and the demo role switch in Profile.

## Conventions

- One screen per file; screen-only widgets stay private in the same file.
- Colours, spacing and text styles only from `core/theme`.
- Routes only via `Routes.*`, never hard-coded strings.
- Product names and prices only from `AppConfig`.
- Run `dart format lib test` and `flutter analyze` before committing.

## Docs

- `docs/SCREENS.md`: every screen, its route and file
- `docs/DECISIONS.md`: product decisions agreed so far
- `docs/BACKEND_PLAN.md`: backend repo, tables and how each repository maps
