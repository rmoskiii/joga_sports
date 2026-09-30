import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

enum _PayMethod { applePay, card }

/// Checkout. Holds the space for five minutes while the player pays, so
/// no one can take it mid-payment. Wallet credit comes off automatically.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.gameId});

  final String gameId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Game? _game;
  BookingQuote? _quote;
  SpaceHold? _hold;
  String? _error;
  Timer? _ticker;
  bool _useWallet = true;
  bool _paying = false;
  _PayMethod _method = _PayMethod.applePay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final services = context.services;
    setState(() => _error = null);
    try {
      final game = await services.games.getGame(widget.gameId);
      final quote = await services.bookings.quote(widget.gameId);
      final hold = await services.bookings.holdSpace(widget.gameId);
      if (!mounted) return;
      setState(() {
        _game = game;
        _quote = quote;
        _hold = hold;
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _pay() async {
    final hold = _hold;
    if (hold == null) return;
    setState(() => _paying = true);
    try {
      await context.services.bookings.confirm(hold, useWallet: _useWallet);
      if (!mounted) return;
      context.pushReplacement(Routes.confirmed(widget.gameId));
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final quote = _quote;
    final hold = _hold;

    if (_error != null && hold == null) {
      return JogaScaffold(
        showBack: true,
        children: [
          const Headline('Lock in\nyour spot'),
          JogaCard(
            tone: CardTone.fire,
            child: Text(_error!, style: AppText.bodyStrong),
          ),
        ],
      );
    }
    if (game == null || quote == null || hold == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.lime),
        ),
      );
    }

    final expired = hold.isExpired();
    final total = quote.totalPence(useWallet: _useWallet);
    final walletApplied = quote.walletAppliedPence(useWallet: _useWallet);

    return JogaScaffold(
      showBack: true,
      bottom: JogaButton(
        label: expired
            ? 'Hold again'
            : total == 0
                ? 'Confirm · paid with credit'
                : 'Pay ${Format.money(total)} & play',
        icon: expired ? Icons.refresh_rounded : Icons.lock_rounded,
        loading: _paying,
        onPressed: expired ? _start : _pay,
      ),
      children: [
        const Headline('Lock in\nyour spot'),
        _HoldCard(hold: hold),
        if (_error != null)
          Text(_error!, style: AppText.small.copyWith(color: AppColors.danger)),
        _GameSummary(game: game),
        JogaCard(
          child: Column(
            children: [
              PriceRow(label: 'Game', value: Format.money(quote.gamePence)),
              PriceRow(
                label: 'Booking fee',
                value: quote.isMember
                    ? 'Free with ${AppConfig.membershipName}'
                    : Format.money(quote.feePence),
                color: quote.isMember ? AppColors.lime : null,
              ),
              if (walletApplied > 0)
                PriceRow(
                  label: 'Wallet credit',
                  value: Format.money(-walletApplied),
                  color: AppColors.lime,
                ),
              const JogaDivider(),
              PriceRow(
                label: 'Total',
                value: Format.money(total),
                strong: true,
              ),
            ],
          ),
        ),
        if (quote.walletAvailablePence > 0)
          _ToggleRow(
            title: 'Use wallet credit',
            subtitle: '${Format.money(quote.walletAvailablePence)} available',
            value: _useWallet,
            onChanged: (v) => setState(() => _useWallet = v),
          ),
        if (!quote.isMember) const _MembershipUpsell(),
        const SectionLabel('Pay with'),
        _MethodRow(
          icon: Icons.apple,
          label: 'Apple Pay',
          selected: _method == _PayMethod.applePay,
          onTap: () => setState(() => _method = _PayMethod.applePay),
        ),
        _MethodRow(
          icon: Icons.credit_card_rounded,
          label: 'Visa •••• 4417',
          selected: _method == _PayMethod.card,
          onTap: () => setState(() => _method = _PayMethod.card),
        ),
        const Text(
          'Demo: no real payment is taken.',
          style: AppText.tiny,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HoldCard extends StatelessWidget {
  const _HoldCard({required this.hold});

  final SpaceHold hold;

  @override
  Widget build(BuildContext context) {
    final expired = hold.isExpired();
    return JogaCard(
      tone: CardTone.fire,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? 'Your hold has ended' : 'Space held for you',
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: Space.xxs),
                Text(
                  expired
                      ? 'Hold it again to carry on.'
                      : 'No one else can take it while you pay.',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          Text(
            Format.minutesSeconds(hold.remaining()),
            style: AppText.h1.copyWith(color: AppColors.fire, fontSize: 28),
          ),
        ],
      ),
    );
  }
}

class _GameSummary extends StatelessWidget {
  const _GameSummary({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      padding: const EdgeInsets.all(Space.sm),
      child: Row(
        children: [
          const SizedBox(
            width: 64,
            height: 50,
            child: PitchPhoto(borderRadius: Radii.sm, fade: false),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Headline(game.format.label, style: AppText.h3),
                Text(
                  '${Format.shortDate(game.startsAt)} · '
                  '${Format.time(game.startsAt)} · ${game.venue.name}',
                  style: AppText.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyStrong),
                Text(subtitle, style: AppText.small),
              ],
            ),
          ),
          _Tick(on: value),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: Space.md),
          Expanded(child: Text(label, style: AppText.bodyStrong)),
          _Tick(on: selected),
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: on ? AppColors.lime : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: on ? AppColors.lime : AppColors.line, width: 1.5),
      ),
      child: on
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.onLime)
          : null,
    );
  }
}

class _MembershipUpsell extends StatelessWidget {
  const _MembershipUpsell();

  @override
  Widget build(BuildContext context) {
    return JogaCard(
      tone: CardTone.lime,
      onTap: () => context.push(Routes.membership),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline(
            '${AppConfig.membershipName} members pay no booking fees',
            style: AppText.h3,
            color: AppColors.lime,
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${Format.money(AppConfig.membershipMonthlyPence)} / month · '
            'Learn more',
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}
