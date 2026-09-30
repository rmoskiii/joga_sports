import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Wallet credit from rewards, referrals and refunds. Spent automatically
/// at checkout. Every movement is listed.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _icons = {
    WalletEntryType.reward: Icons.local_fire_department_rounded,
    WalletEntryType.referral: Icons.card_giftcard_rounded,
    WalletEntryType.booking: Icons.sports_soccer_rounded,
    WalletEntryType.refund: Icons.undo_rounded,
    WalletEntryType.topUp: Icons.add_card_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final wallet = context.services.wallet;
    return AsyncView<Wallet>(
      load: wallet.wallet,
      builder: (context, data) => JogaScaffold(
        showBack: true,
        children: [
          JogaCard(
            tone: CardTone.lime,
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.lime,
                  size: 30,
                ),
                const SizedBox(height: Space.sm),
                const Text('Wallet credit', style: AppText.small),
                Text(
                  Format.money(data.balancePence),
                  style: AppText.hero.copyWith(
                    fontStyle: FontStyle.normal,
                    fontSize: 52,
                  ),
                ),
                const Text(
                  'Used automatically at checkout',
                  style: AppText.tiny,
                ),
              ],
            ),
          ),
          JogaButton(
            label: 'Find a game',
            onPressed: () => context.go(Routes.find),
          ),
          const SectionLabel('Milestones'),
          for (final m in data.milestones)
            JogaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(m.title, style: AppText.bodyStrong)),
                      Text(
                        '${m.progress}/${m.target} · ${m.rewardLabel}',
                        style: AppText.small,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  JogaProgressBar(
                    value: m.ratio,
                    color: m.isStreak ? AppColors.fire : AppColors.lime,
                  ),
                ],
              ),
            ),
          const SectionLabel('Activity'),
          JogaCard(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: Column(
              children: [
                for (var i = 0; i < data.entries.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.line),
                  _EntryRow(
                    entry: data.entries[i],
                    icon: _icons[data.entries[i].type]!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.icon});

  final WalletEntry entry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final credit = entry.amountPence >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: AppText.smallStrong),
                Text(Format.shortDate(entry.date), style: AppText.tiny),
              ],
            ),
          ),
          Text(
            Format.moneySigned(entry.amountPence),
            style: AppText.bodyStrong.copyWith(
              color: credit ? AppColors.lime : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
