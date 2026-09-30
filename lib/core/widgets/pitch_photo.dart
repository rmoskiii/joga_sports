import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Placeholder "photo" of a floodlit pitch, drawn in code.
///
/// Stands in for real venue photos until they exist. Swap for an
/// `Image.network` of the venue's photo later without changing layouts.
class PitchPhoto extends StatelessWidget {
  const PitchPhoto({
    super.key,
    this.height,
    this.borderRadius = Radii.md,
    this.child,
    this.fade = true,
  });

  final double? height;
  final double borderRadius;

  /// Content drawn over the bottom of the photo (titles, chips).
  final Widget? child;

  /// Darken the bottom so overlaid text is readable.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _FloodlitPitchPainter()),
            if (fade)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1],
                    colors: [Colors.transparent, Color(0xDD000000)],
                  ),
                ),
              ),
            if (child != null)
              Positioned(
                left: Space.md,
                right: Space.md,
                bottom: Space.md,
                child: child!,
              ),
          ],
        ),
      ),
    );
  }
}

class _FloodlitPitchPainter extends CustomPainter {
  const _FloodlitPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.38;

    // Night sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizon),
      Paint()..color = const Color(0xFF0B1711),
    );

    // Mowed turf stripes
    const stripes = 9;
    for (var i = 0; i < stripes; i++) {
      final paint = Paint()
        ..color = i.isEven ? const Color(0xFF236235) : const Color(0xFF1C5230);
      final left = w * i / stripes;
      canvas.drawRect(
        Rect.fromLTWH(left, horizon, w / stripes + 1, h - horizon),
        paint,
      );
    }

    // Goal on the horizon
    final goal =
        Rect.fromLTWH(w * 0.34, horizon - h * 0.12, w * 0.32, h * 0.14);
    final net = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var x = goal.left; x < goal.right; x += 5) {
      canvas.drawLine(Offset(x, goal.top), Offset(x, goal.bottom), net);
    }
    final frame = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(
      Path()
        ..moveTo(goal.left, goal.bottom)
        ..lineTo(goal.left, goal.top)
        ..lineTo(goal.right, goal.top)
        ..lineTo(goal.right, goal.bottom),
      frame,
    );

    // Floodlight glow
    for (final cx in [w * 0.12, w * 0.88]) {
      final center = Offset(cx, 0);
      final radius = w * 0.55;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFFFE6).withValues(alpha: 0.55),
              const Color(0x00FFFFE6),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
