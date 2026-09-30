# Backend plan

## Recommendation: a separate repo

Keep the backend in its own repo, **`joga-backend`**, as a Supabase CLI
project:

```
joga-backend/
  supabase/
    config.toml
    migrations/        SQL: tables, views, functions, row-level security
    functions/         Edge functions (TypeScript): Stripe, RevenueCat, jobs
    seed.sql           The same dummy data as this app's FakeSeed (Ray etc.)
  README.md
```

Why separate:

- **Different release cycles.** Database migrations deploy on their own
  (`supabase db push`); app builds go through the App Store and Google Play.
- **Tidier history and access.** App and backend changes don't get mixed,
  and a future backend or data person can be given access to just that repo.
- **The app only depends on the interfaces** in `lib/data/repositories/`,
  so the two can move independently.

(A single repo with a `supabase/` folder also works for a one-person team.
Either way, the structure below is the same.)

## Tables

| Table | Purpose |
|---|---|
| `profiles` | One per user: name, city, level, position, role (player / organiser / admin) |
| `venues` | Name, city, address, surface, parking, photo |
| `games` | Sport, format, venue, pitch, start time, duration, level, tags, price, capacity, organiser |
| `space_holds` | Game, player, expires at. Protects the last space while paying |
| `bookings` | Game, player, status, amount paid, wallet used, Stripe payment id |
| `waitlist` | Game, player, joined at (after test) |
| `match_lines` | Game, player, team, attended, goals, assists |
| `match_results` | Game, scores, player of the match, submitted by, submitted at |
| `wallet_ledger` | **Append-only.** Every credit and debit. Balance = sum |
| `rewards` | Rules for milestones and streak rewards, so amounts change without code |
| `memberships` | Joga+ status, synced from RevenueCat |
| `referrals` | Referrer, referred, stage (after test) |

Views: `player_stats` (career / season / month), `player_streaks` (weeks
played), `leaderboards` (monthly per city, materialised).

## Database functions (called by the app)

| Function | What it does |
|---|---|
| `hold_space(game_id)` | Locks the game row, checks capacity, creates a 5-minute hold |
| `confirm_booking(hold_id, use_wallet)` | Validates the hold, writes the booking and ledger entry. Card payments go through a Stripe edge function first |
| `cancel_booking(game_id)` | Applies the 24-hour rule; refunds to wallet or marks "refund if filled" |
| `submit_match(game_id, lines, potm_id)` | Organiser only. Writes results, updates stats, streaks, rewards and ledger in one transaction |

Scheduled job: release expired holds; refund late cancellations whose space
was filled.

## Row-level security

- Players read games and venues; read and write only their own bookings,
  profile and wallet.
- Organisers can write match lines and results only for their own games.
- Admins read everything and manage games, venues, refunds.

## How each app repository maps

| App interface | Supabase implementation |
|---|---|
| `AuthRepository` | Supabase Auth (Apple, Google, email) |
| `GamesRepository` | `games` + `venues` queries; "For you" as a view or function |
| `BookingRepository` | `hold_space`, `confirm_booking`, `cancel_booking`, Stripe |
| `PlayerRepository` | `profiles`, `player_stats`, `player_streaks`, `match_results` |
| `MatchRepository` | `match_lines` + `submit_match` |
| `WalletRepository` | `wallet_ledger` + `rewards` |
| `CompeteRepository` | `leaderboards`, `referrals` |
| `MembershipRepository` | RevenueCat SDK; status mirrored in `memberships` |
| `AdminRepository` | Admin views: games per day with revenue, venue cost, margin |
| `AppServices.changes` | Supabase realtime on the tables each screen shows |
