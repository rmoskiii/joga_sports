// Shared enums for the domain.

/// Sports on the platform. Football launches first; the others are designed
/// in from the start so the data model never assumes football.
enum Sport {
  football('Football', isLive: true),
  padel('Padel', isLive: false),
  badminton('Badminton', isLive: false);

  const Sport(this.label, {required this.isLive});
  final String label;
  final bool isLive;
}

enum City {
  cardiff('Cardiff'),
  bristol('Bristol');

  const City(this.label);
  final String label;
}

/// Game formats. Capacity is total players across both teams.
enum GameFormat {
  fiveASide('5-a-side', Sport.football, 10),
  sevenASide('7-a-side', Sport.football, 14);

  const GameFormat(this.label, this.sport, this.capacity);
  final String label;
  final Sport sport;
  final int capacity;
}

enum SkillLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  competitive('Competitive');

  const SkillLevel(this.label);
  final String label;
}

/// Tags that help players find the right game.
enum GameTag {
  casual('Casual'),
  competitive('Competitive'),
  mixed('Mixed'),
  over30s('Over-30s'),
  womens("Women's");

  const GameTag(this.label);
  final String label;
}

enum UserRole { player, organiser, admin }

enum Team {
  white('White'),
  orange('Orange');

  const Team(this.label);
  final String label;
}
