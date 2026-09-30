import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../theme/app_colors.dart';

/// Initials avatar. Replace with the player's photo when profiles have one.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.person,
    this.size = 30,
    this.highlight = false,
    this.color,
  });

  final Person person;
  final double size;

  /// Lime ring, e.g. to mark "you".
  final bool highlight;
  final Color? color;

  static Color colourFor(String id) =>
      AppColors.avatars[id.hashCode.abs() % AppColors.avatars.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? colourFor(person.id),
        border: Border.all(
          color: highlight ? AppColors.lime : AppColors.surface,
          width: highlight ? 2.5 : 2,
        ),
      ),
      child: Text(
        person.initials,
        style: TextStyle(
          color: AppColors.onLime,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// Overlapping avatars with a "+N" counter.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.people,
    this.max = 5,
    this.size = 28,
  });

  final List<Person> people;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(max).toList();
    final extra = people.length - shown.length;
    final overlap = size * 0.3;
    final count = shown.length + (extra > 0 ? 1 : 0);
    final width = count == 0 ? 0.0 : size + (count - 1) * (size - overlap);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: PersonAvatar(person: shown[i], size: size),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceRaised,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
