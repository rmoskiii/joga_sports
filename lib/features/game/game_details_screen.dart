import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/config/feature_flags.dart';
import '../../core/di/app_scope.dart';
import '../../core/di/app_services.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

typedef _GameData = ({Game game, Player me});

/// Everything a player needs to commit: who's in, organiser, venue and the
/// full price upfront.
class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key, required this.gameId});

  final String gameId;

  static Future<_GameData> _load(AppServices s, String id) async {
    final (game, me) =
        await (s.games.getGame(id), s.player.currentPlayer()).wait;
    return (game: game, me: me);
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return Scaffold(
      body: AsyncView<_GameData>(
        load: () => _load(services, gameId),
        builder: (context, data) => _GameDetails(game: data.game, me: data.me),
      ),
    );
  }
}

class _GameDetails extends StatelessWidget {
  const _GameDetails({required this.game, required this.me});

  final Game game;
  final Player me;

  @override
  Widget build(BuildContext context) {
    final booked = game.hasPlayer(me.id);
    final fee = me.isMember ? 0 : AppConfig.bookingFeePence;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(game: game),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.gutter,
                  Space.md,
                  Space.gutter,
                  Space.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Headline(game.format.label),
                    const SizedBox(height: Space.xxs),
                    Headline(
                      '${game.venue.name} · ${game.pitch}',
                      style: AppText.h3,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      '${Format.shortDate(game.startsAt)} · '
                      '${Format.time(game.startsAt)} · '
                      '${game.duration.inMinutes} mins · ${game.level.label}',
                      style: AppText.small,
                    ),
                    const SizedBox(height: Space.sm),
                    ChipRow(
                      children: [
                        for (final tag in game.tags) JogaChip(label: tag.label),
                        const JogaChip(label: 'Bibs provided'),
                        const JogaChip(label: 'Floodlit'),
                      ],
                    ),
                    const SizedBox(height: Space.md),
                    _PlayersCard(game: game, me: me),
                    const SizedBox(height: Space.md),
                    _OrganiserCard(game: game),
                    const SizedBox(height: Space.md),
                    _VenueCard(venue: game.venue),
                    if (!booked) ...[
                      const SizedBox(height: Space.md),
                      _PriceCard(game: game, feePence: fee),
                    ],
                    const SizedBox(height: Space.md),
                    const _CancellationNote(),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomAction(game: game, booked: booked, feePence: fee),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const PitchPhoto(borderRadius: 0),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.find),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersCard extends StatelessWidget {
  const _PlayersCard({required this.game, required this.me});

  final Game game;
  final Player me;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${game.booked} / ${game.capacity} players',
                  style: AppText.bodyStrong,
                ),
              ),
              SpacesChip(game: game),
            ],
          ),
          const SizedBox(height: Space.sm),
          JogaProgressBar(value: game.fillRatio),
          const SizedBox(height: Space.md),
          Row(
            children: [
              AvatarStack(people: game.players, max: 6),
              const Spacer(),
              Text(game.level.label, style: AppText.tiny),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrganiserCard extends StatelessWidget {
  const _OrganiserCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Row(
        children: [
          PersonAvatar(
            person: game.organiser,
            size: 38,
            color: AppColors.fire,
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.organiser.shortName} · Organiser',
                  style: AppText.bodyStrong,
                ),
                Text(
                  '${game.organiserGamesRun} games run',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: AppColors.lime, size: 20),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(venue.address, style: AppText.smallStrong),
          const SizedBox(height: Space.xs),
          Text('${venue.surface} · Parking: ${venue.parking}',
              style: AppText.small),
          const SizedBox(height: Space.sm),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opens Apple or Google Maps in the real app.'),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.near_me_rounded,
                    size: 16, color: AppColors.lime),
                const SizedBox(width: Space.xs),
                Text(
                  'Get directions',
                  style: AppText.smallStrong.copyWith(color: AppColors.lime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.game, required this.feePence});

  final Game game;
  final int feePence;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      child: Column(
        children: [
          PriceRow(label: 'Game', value: Format.money(game.pricePence)),
          PriceRow(
            label: 'Booking fee',
            value: feePence == 0 ? 'Free' : Format.money(feePence),
            color: feePence == 0 ? AppColors.lime : null,
          ),
          if (feePence > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push(Routes.membership),
                child: Text(
                  'Free booking with ${AppConfig.membershipName} ›',
                  style: AppText.small.copyWith(color: AppColors.lime),
                ),
              ),
            ),
          const JogaDivider(),
          PriceRow(
            label: 'Total',
            value: Format.money(game.pricePence + feePence),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _CancellationNote extends StatelessWidget {
  const _CancellationNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, size: 18, color: AppColors.lime),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Text(
            'Free cancellation up to '
            '${AppConfig.freeCancellation.inHours} hours before kick-off. '
            "After that, you're refunded if someone else takes your space.",
            style: AppText.small,
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatefulWidget {
  const _BottomAction({
    required this.game,
    required this.booked,
    required this.feePence,
  });

  final Game game;
  final bool booked;
  final int feePence;

  @override
  State<_BottomAction> createState() => _BottomActionState();
}

class _BottomActionState extends State<_BottomAction> {
  bool _busy = false;

  Future<void> _joinWaitlist() async {
    setState(() => _busy = true);
    await context.services.bookings.joinWaitlist(widget.game.id);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("You're on the waitlist. We'll tell you if a space opens."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final Widget action;
    if (widget.booked) {
      action = JogaButton(
        label: "You're in · Game day",
        icon: Icons.check_rounded,
        onPressed: () => context.push(Routes.gameDay(game.id)),
      );
    } else if (game.isFull) {
      action = FeatureFlags.waitlist
          ? JogaButton.secondary(
              label: 'Game full · Join waitlist',
              loading: _busy,
              onPressed: _joinWaitlist,
            )
          : const JogaButton(label: 'Game full', onPressed: null);
    } else {
      action = JogaButton(
        label: 'Join game · '
            '${Format.moneyShort(game.pricePence + widget.feePence)}',
        onPressed: () => context.push(Routes.checkout(game.id)),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.md,
        Space.gutter,
        Space.md,
      ),
      child: SafeArea(top: false, child: action),
    );
  }
}
