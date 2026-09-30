import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';

/// Joga+: no booking fees, full stats, streak freeze and bigger rewards.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    await context.services.membership.subscribe();
    if (!mounted) return;
    setState(() => _joining = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome to Joga+. Booking fees are gone.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membership = context.services.membership;
    return AsyncView<MembershipOffer>(
      load: membership.offer,
      builder: (context, offer) => JogaScaffold(
        showBack: true,
        bottom: offer.isActive
            ? const JogaButton(
                label: "You're a member",
                icon: Icons.check_rounded,
                onPressed: null,
              )
            : JogaButton(
                label: 'Join ${offer.name}',
                loading: _joining,
                onPressed: _join,
              ),
        children: [
          const SizedBox(height: Space.md),
          const Center(
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.lime,
              size: 48,
            ),
          ),
          Headline(
            offer.name,
            style: AppText.hero.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          const Text(
            'YOUR FOOTBALL. TRACKED.',
            style: AppText.label,
            textAlign: TextAlign.center,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: Format.money(offer.monthlyPence),
                  style: AppText.h1,
                ),
                const TextSpan(text: ' / month', style: AppText.small),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          JogaCard(
            child: Column(
              children: [
                for (final benefit in offer.benefits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.xs),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.lime,
                          size: 20,
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(child: Text(benefit, style: AppText.body)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const JogaCard(
            tone: CardTone.lime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pays for itself', style: AppText.bodyStrong),
                SizedBox(height: Space.xxs),
                Text(
                  'Play 5 games a month and you save £5 in booking fees, '
                  'before any rewards.',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const Text(
            'Billed monthly through the App Store, Google Play, or by card '
            'on the web. Cancel any time. Demo: no payment is taken.',
            style: AppText.tiny,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
