import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material theme. Kept deliberately small: most styling lives in the
/// shared widgets in `core/widgets`, so screens stay consistent.
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.onLime,
      secondary: AppColors.fire,
      onSecondary: AppColors.onLime,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.onLime,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Barlow',
      dividerColor: AppColors.line,
      splashColor: AppColors.lime.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.lime,
      ),
    );
  }
}
