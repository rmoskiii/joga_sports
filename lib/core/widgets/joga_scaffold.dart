import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Standard screen layout: optional back bar, scrolling body with the
/// app's side gutter, and an optional pinned bottom action.
class JogaScaffold extends StatelessWidget {
  const JogaScaffold({
    super.key,
    required this.children,
    this.showBack = false,
    this.backLabel = 'Back',
    this.actions = const [],
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(
      Space.gutter,
      Space.sm,
      Space.gutter,
      Space.xl,
    ),
    this.spacing = Space.md,
  });

  final List<Widget> children;
  final bool showBack;
  final String backLabel;
  final List<Widget> actions;

  /// Pinned action area (e.g. "Pay & play").
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  /// Gap between children.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: bottom == null,
        child: Column(
          children: [
            if (showBack || actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.sm,
                  Space.xs,
                  Space.sm,
                  0,
                ),
                child: Row(
                  children: [
                    if (showBack)
                      TextButton.icon(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(Routes.home),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        label: Text(backLabel, style: AppText.small),
                      ),
                    const Spacer(),
                    ...actions,
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: padding,
                itemCount: children.length,
                separatorBuilder: (_, __) => SizedBox(height: spacing),
                itemBuilder: (_, i) => children[i],
              ),
            ),
            if (bottom != null)
              Container(
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
                child: SafeArea(top: false, child: bottom!),
              ),
          ],
        ),
      ),
    );
  }
}
