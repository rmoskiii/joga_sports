import 'package:flutter/material.dart';

/// Joga Sports colour palette.
///
/// Dark, floodlit-pitch look with a neon lime accent. Every colour in the
/// app should come from here so a rebrand is a one-file change.
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFF090A09);
  static const surface = Color(0xFF15181A);
  static const surfaceRaised = Color(0xFF1E2224);
  static const line = Color(0xFF2A2F2E);

  // Text
  static const textPrimary = Color(0xFFF2F4EF);
  static const textSecondary = Color(0xFFC9CEC8);
  static const textMuted = Color(0xFF8E948F);

  // Brand
  static const lime = Color(0xFFC6F135);
  static const limeDeep = Color(0xFF5E7A1C);
  static const onLime = Color(0xFF000000);

  // Semantic
  static const fire = Color(0xFFFF8A1F); // streaks, rewards, orange team
  static const danger = Color(0xFFFF5A4E);
  static const success = lime;

  // Teams
  static const teamWhite = textPrimary;
  static const teamOrange = fire;

  // Placeholder avatar colours (until real profile photos exist).
  static const avatars = <Color>[
    Color(0xFFF2F4EF),
    Color(0xFFC6F135),
    Color(0xFFFF8A1F),
    Color(0xFF9AA7A0),
    Color(0xFFE0B38A),
    Color(0xFF7FB3D5),
    Color(0xFFD9D2F5),
  ];
}
