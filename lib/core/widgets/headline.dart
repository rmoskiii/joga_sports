import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Display text in upper case (Barlow Condensed).
class Headline extends StatelessWidget {
  const Headline(
    this.text, {
    super.key,
    this.style = AppText.h1,
    this.color,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: color == null ? style : style.copyWith(color: color),
      textAlign: textAlign,
    );
  }
}

/// Small upper-case label above a section, with an optional action.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.action,
    this.onAction,
    this.trailing,
  });

  final String text;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg, bottom: Space.sm),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: AppText.label)),
          if (trailing != null) trailing!,
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppText.small.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
