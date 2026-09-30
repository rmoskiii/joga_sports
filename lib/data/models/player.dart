import 'enums.dart';
import 'person.dart';

/// The signed-in player's profile.
class Player {
  const Player({
    required this.person,
    required this.city,
    required this.level,
    required this.position,
    required this.memberSince,
    required this.isMember,
    required this.role,
    required this.reliabilityPercent,
  });

  final Person person;
  final City city;
  final SkillLevel level;
  final String position;
  final DateTime memberSince;

  /// Has an active Joga+ membership.
  final bool isMember;
  final UserRole role;

  /// Share of booked games the player actually turned up to.
  final int reliabilityPercent;

  String get id => person.id;
  String get firstName => person.firstName;

  Player copyWith({bool? isMember, UserRole? role}) => Player(
        person: person,
        city: city,
        level: level,
        position: position,
        memberSince: memberSince,
        isMember: isMember ?? this.isMember,
        role: role ?? this.role,
        reliabilityPercent: reliabilityPercent,
      );
}
