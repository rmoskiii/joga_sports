import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Give £2, get £2 once the friend plays their first game. After the test
/// period (FeatureFlags.referrals).
class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compete = context.services.compete;
    return AsyncView<Referrals>(
      load: compete.referrals,
      builder: (context, data) {
        final reward = Format.moneyShort(data.rewardPence);
        return JogaScaffold(
          showBack: true,
          bottom: JogaButton(
            label: 'Invite friends',
            icon: Icons.ios_share_rounded,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opens the share sheet in the real app.'),
              ),
            ),
          ),
          children: [
            Headline('Give $reward.', style: AppText.hero),
            Headline('Get $reward.',
                style: AppText.hero, color: AppColors.lime),
            Text(
              'Invite a friend. They get $reward credit, and you get $reward '
              'when they finish their first game.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            JogaCard(
              child: Row(
                children: [
                  Expanded(
                    child: Headline(
                      data.code,
                      style: AppText.h1.copyWith(letterSpacing: 2),
                    ),
                  ),
                  JogaChip(
                    label: 'Copy',
                    icon: Icons.copy_rounded,
                    tone: ChipTone.selected,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: data.code));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SectionLabel('Your referrals'),
            for (final entry in data.entries) _ReferralRow(entry: entry),
          ],
        );
      },
    );
  }
}

class _ReferralRow extends StatelessWidget {
  const _ReferralRow({required this.entry});

  final ReferralEntry entry;

  @override
  Widget build(BuildContext context) {
    final done = entry.stage == ReferralStage.rewarded;
    return JogaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(entry.name, style: AppText.bodyStrong)),
              Text(
                done ? 'Reward earned' : 'In progress',
                style: AppText.small.copyWith(
                  color: done ? AppColors.lime : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              for (final stage in ReferralStage.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: Space.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JogaProgressBar(
                          value: stage.index <= entry.stage.index ? 1 : 0,
                          height: 4,
                        ),
                        const SizedBox(height: Space.xs),
                        Text(stage.label, style: AppText.tiny),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
