import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/app_scope.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';

/// First screen: brand, city choice and sign-in options.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  City _city = City.cardiff;
  bool _loading = false;

  Future<void> _signIn(Future<void> Function() method) async {
    setState(() => _loading = true);
    await method();
    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.services.auth;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PitchPhoto(borderRadius: 0),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(child: _content(auth)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(AuthRepository auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.xl),
        const Center(child: JogaLogo(size: 30)),
        const Spacer(),
        const Text('PLAY\nMORE.', style: AppText.hero),
        const SizedBox(height: Space.md),
        Text(
          'Find games. Track your football.\nBuild your streak.',
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Space.lg),
        const Text('YOUR CITY', style: AppText.label),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            for (final city in City.values) ...[
              JogaChip.filter(
                label: city.label,
                selected: city == _city,
                onTap: () => setState(() => _city = city),
              ),
              const SizedBox(width: Space.sm),
            ],
          ],
        ),
        const SizedBox(height: Space.xl),
        JogaButton(
          label: 'Get started',
          loading: _loading,
          onPressed: () => _signIn(() => auth.signInWithEmail('ray@joga.demo')),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: JogaButton.secondary(
                label: 'Apple',
                icon: Icons.apple,
                onPressed:
                    _loading ? null : () => _signIn(auth.signInWithApple),
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: JogaButton.secondary(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed:
                    _loading ? null : () => _signIn(auth.signInWithGoogle),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        const Text(
          'Demo: signs in as Ray with dummy data.',
          style: AppText.tiny,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.lg),
      ],
    );
  }
}
