import 'enums.dart';
import 'person.dart';
import 'venue.dart';

/// An organised game players can book a space in.
class Game {
  const Game({
    required this.id,
    required this.format,
    required this.venue,
    required this.pitch,
    required this.startsAt,
    required this.duration,
    required this.level,
    required this.tags,
    required this.pricePence,
    required this.players,
    required this.organiser,
    required this.organiserGamesRun,
  });

  final String id;
  final GameFormat format;
  final Venue venue;
  final String pitch;
  final DateTime startsAt;
  final Duration duration;
  final SkillLevel level;
  final List<GameTag> tags;
  final int pricePence;
  final List<Person> players;
  final Person organiser;
  final int organiserGamesRun;

  Sport get sport => format.sport;
  int get capacity => format.capacity;
  int get booked => players.length;
  int get spacesLeft => capacity - booked;
  bool get isFull => spacesLeft <= 0;
  bool get isLastSpace => spacesLeft == 1;
  bool get isAlmostFull => spacesLeft > 0 && spacesLeft <= 2;
  double get fillRatio => booked / capacity;

  bool hasPlayer(String personId) => players.any((p) => p.id == personId);

  Game copyWith({List<Person>? players}) => Game(
        id: id,
        format: format,
        venue: venue,
        pitch: pitch,
        startsAt: startsAt,
        duration: duration,
        level: level,
        tags: tags,
        pricePence: pricePence,
        players: players ?? this.players,
        organiser: organiser,
        organiserGamesRun: organiserGamesRun,
      );
}

/// Filters on the Find screen.
class GameFilter {
  const GameFilter({
    this.city = City.cardiff,
    this.day = DayFilter.all,
    this.format,
    this.level,
    this.tag,
    this.maxPricePence,
  });

  final City city;
  final DayFilter day;
  final GameFormat? format;
  final SkillLevel? level;
  final GameTag? tag;
  final int? maxPricePence;

  GameFilter copyWith({
    City? city,
    DayFilter? day,
    GameFormat? Function()? format,
    SkillLevel? Function()? level,
    GameTag? Function()? tag,
    int? Function()? maxPricePence,
  }) =>
      GameFilter(
        city: city ?? this.city,
        day: day ?? this.day,
        format: format != null ? format() : this.format,
        level: level != null ? level() : this.level,
        tag: tag != null ? tag() : this.tag,
        maxPricePence:
            maxPricePence != null ? maxPricePence() : this.maxPricePence,
      );
}

enum DayFilter {
  all('Any day'),
  today('Tonight'),
  tomorrow('Tomorrow'),
  weekend('Weekend');

  const DayFilter(this.label);
  final String label;
}
