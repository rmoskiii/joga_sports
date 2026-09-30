import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale.
///
/// Display styles use Barlow Condensed (bold, condensed, sporty) and are
/// shown in upper case via [Headline]. Body styles use Barlow.
abstract final class AppText {
  static const _display = 'BarlowCondensed';
  static const _body = 'Barlow';

  // Display
  static const hero = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    fontSize: 56,
    height: 0.88,
    color: AppColors.textPrimary,
  );
  static const h1 = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 0.95,
    color: AppColors.textPrimary,
  );
  static const h2 = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: 22,
    height: 1,
    color: AppColors.textPrimary,
  );
  static const h3 = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: 18,
    height: 1,
    color: AppColors.textPrimary,
  );
  static const number = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: 26,
    height: 1,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const label = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    letterSpacing: 1.4,
    color: AppColors.textMuted,
  );
  static const button = TextStyle(
    fontFamily: _display,
    fontWeight: FontWeight.w800,
    fontSize: 17,
    letterSpacing: 0.8,
  );

  // Body
  static const body = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  static const bodyStrong = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );
  static const small = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    height: 1.35,
    color: AppColors.textMuted,
  );
  static const smallStrong = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );
  static const tiny = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    height: 1.3,
    color: AppColors.textMuted,
  );
}
