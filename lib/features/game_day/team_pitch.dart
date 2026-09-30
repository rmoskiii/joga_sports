import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/avatar.dart';
import '../../data/models/models.dart';

/// Top-down pitch with both teams laid out, "you" ringed in lime.
class TeamPitch extends StatelessWidget {
  const TeamPitch({
    super.key,
    required this.white,
    required this.orange,
    required this.meId,
  });

  final List<Person> white;
  final List<Person> orange;
  final String meId;

  /// Formation slots for one half, as fractions of the half's width and
  /// the pitch height. Index 0 is the goalkeeper.
  static const _slots = <Offset>[
    Offset(0.12, 0.5),
    Offset(0.38, 0.22),
    Offset(0.38, 0.78),
    Offset(0.7, 0.35),
    Offset(0.7, 0.65),
    Offset(0.88, 0.15),
    Offset(0.88, 0.85),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          const size = 30.0;

          Widget place(Person p, Offset slot, {required bool left}) {
            final x = left ? slot.dx * w / 2 : w - slot.dx * w / 2;
            return Positioned(
              left: x - size / 2,
              top: slot.dy * h - size / 2,
              child: PersonAvatar(
                person: p,
                size: size,
                highlight: p.id == meId,
                color: left ? AppColors.teamWhite : AppColors.teamOrange,
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(Radii.md),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _PitchPainter()),
                ),
                for (var i = 0; i < white.length && i < _slots.length; i++)
                  place(white[i], _slots[i], left: true),
                for (var i = 0; i < orange.length && i < _slots.length; i++)
                  place(orange[i], _slots[i], left: false),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stripes = 8;
    for (var i = 0; i < stripes; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
            size.width * i / stripes, 0, size.width / stripes + 1, size.height),
        Paint()
          ..color =
              i.isEven ? const Color(0xFF1F5A31) : const Color(0xFF1A4E2A),
      );
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final inset = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas
      ..drawRect(inset, line)
      ..drawLine(
        Offset(size.width / 2, inset.top),
        Offset(size.width / 2, inset.bottom),
        line,
      )
      ..drawCircle(size.center(Offset.zero), size.height * 0.16, line)
      ..drawRect(
        Rect.fromLTWH(
            inset.left, size.height * 0.3, size.width * 0.1, size.height * 0.4),
        line,
      )
      ..drawRect(
        Rect.fromLTWH(inset.right - size.width * 0.1, size.height * 0.3,
            size.width * 0.1, size.height * 0.4),
        line,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
