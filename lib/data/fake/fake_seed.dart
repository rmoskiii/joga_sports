import '../models/models.dart';

/// Dummy data for the demo. Everything here is made up.
///
/// Dates are relative to "now" so the demo always looks live: Ray has a
/// game kicking off in about an hour and a half, and there are games to
/// book over the next few days.
abstract final class FakeSeed {
  // People ------------------------------------------------------------------

  static const ray = Person(id: 'p-ray', firstName: 'Ray', lastName: 'Mensah');

  static const dan = Person(id: 'p-dan', firstName: 'Dan', lastName: 'Thomas');

  static const people = <Person>[
    Person(id: 'p-ade', firstName: 'Ade', lastName: 'Rotimi'),
    Person(id: 'p-sam', firstName: 'Sam', lastName: 'Kelly'),
    Person(id: 'p-liam', firstName: 'Liam', lastName: 'Price'),
    Person(id: 'p-gethin', firstName: 'Gethin', lastName: 'Knight'),
    Person(id: 'p-omar', firstName: 'Omar', lastName: 'Bashir'),
    Person(id: 'p-tomi', firstName: 'Tomi', lastName: 'Fashola'),
    Person(id: 'p-mo', firstName: 'Mo', lastName: 'Nasser'),
    Person(id: 'p-rhys', firstName: 'Rhys', lastName: 'Evans'),
    Person(id: 'p-jack', firstName: 'Jack', lastName: 'Williams'),
    Person(id: 'p-chris', firstName: 'Chris', lastName: 'Davies'),
    Person(id: 'p-alex', firstName: 'Alex', lastName: 'Parry'),
    Person(id: 'p-matt', firstName: 'Matt', lastName: 'Griffiths'),
    Person(id: 'p-tom', firstName: 'Tom', lastName: 'Lewis'),
    Person(id: 'p-kieran', firstName: 'Kieran', lastName: "O'Neill"),
    Person(id: 'p-josh', firstName: 'Josh', lastName: 'Bennett'),
    Person(id: 'p-kwame', firstName: 'Kwame', lastName: 'Asante'),
    Person(id: 'p-dylan', firstName: 'Dylan', lastName: 'Walsh'),
    Person(id: 'p-callum', firstName: 'Callum', lastName: 'Jones'),
    Person(id: 'p-ben', firstName: 'Ben', lastName: 'Hughes'),
    Person(id: 'p-luke', firstName: 'Luke', lastName: 'Stevens'),
    Person(id: 'p-harri', firstName: 'Harri', lastName: 'Watkins'),
    Person(id: 'p-idris', firstName: 'Idris', lastName: 'Yusuf'),
    Person(id: 'p-sophie', firstName: 'Sophie', lastName: 'Hale'),
    Person(id: 'p-amara', firstName: 'Amara', lastName: 'Obi'),
    Person(id: 'p-ellie', firstName: 'Ellie', lastName: 'Morgan'),
    Person(id: 'p-grace', firstName: 'Grace', lastName: 'Lloyd'),
  ];

  static List<Person> pick(int from, int count) =>
      [for (var i = 0; i < count; i++) people[(from + i) % people.length]];

  static Player player(DateTime now) => Player(
        person: ray,
        city: City.cardiff,
        level: SkillLevel.intermediate,
        position: 'Winger',
        memberSince: DateTime(now.year, now.month - 7),
        isMember: false,
        role: UserRole.player,
        reliabilityPercent: 98,
      );

  // Venues ------------------------------------------------------------------

  static const golCardiff = Venue(
    id: 'v-gol',
    name: 'Gôl Cardiff',
    city: City.cardiff,
    address: 'Leckwith Road, Cardiff CF11 8AZ',
    surface: '3G · moulds or astros',
    parking: 'Free, on site',
  );
  static const leckwith = Venue(
    id: 'v-leckwith',
    name: 'Leckwith 3G',
    city: City.cardiff,
    address: 'Leckwith Close, Cardiff CF11 8AX',
    surface: '3G · moulds or astros',
    parking: 'Free, on site',
  );
  static const canton = Venue(
    id: 'v-canton',
    name: 'Canton Sports Cage',
    city: City.cardiff,
    address: 'Market Road, Cardiff CF5 1QE',
    surface: 'Astro · astros only',
    parking: 'Street parking',
  );
  static const splott = Venue(
    id: 'v-splott',
    name: 'Splott 3G',
    city: City.cardiff,
    address: 'Splott Road, Cardiff CF24 2BZ',
    surface: '3G · moulds or astros',
    parking: 'Pay and display',
  );
  static const templeQuay = Venue(
    id: 'v-temple',
    name: 'Temple Quay Cage',
    city: City.bristol,
    address: 'Temple Gate, Bristol BS1 6PL',
    surface: 'Astro · astros only',
    parking: 'NCP nearby',
  );
  static const eastville = Venue(
    id: 'v-eastville',
    name: 'Eastville 3G',
    city: City.bristol,
    address: 'Eastville Park, Bristol BS5 6YA',
    surface: '3G · moulds or astros',
    parking: 'Free, on site',
  );
  static const ashton = Venue(
    id: 'v-ashton',
    name: 'Ashton Park Astro',
    city: City.bristol,
    address: 'Blackmoors Lane, Bristol BS3 2JL',
    surface: 'Astro · astros only',
    parking: 'Free, on site',
  );

  // Games -------------------------------------------------------------------

  /// Ray's booked game tonight. Used by Game Day, Match Control, Post-game.
  static const tonightGameId = 'g-100';

  /// A game with one space left, for the booking demo.
  static const lastSpaceGameId = 'g-101';

  /// Ray's last completed game.
  static const lastPlayedGameId = 'g-099';

  static List<Game> games(DateTime now) {
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

    int daysToSaturday() => (DateTime.saturday - now.weekday) % 7;

    Game game({
      required String id,
      required GameFormat format,
      required Venue venue,
      required String pitch,
      required DateTime startsAt,
      required SkillLevel level,
      required List<GameTag> tags,
      required int pricePence,
      required List<Person> players,
      Person organiser = dan,
      int organiserGamesRun = 142,
    }) =>
        Game(
          id: id,
          format: format,
          venue: venue,
          pitch: pitch,
          startsAt: startsAt,
          duration: const Duration(minutes: 60),
          level: level,
          tags: tags,
          pricePence: pricePence,
          players: players,
          organiser: organiser,
          organiserGamesRun: organiserGamesRun,
        );

    return [
      // Ray's game tonight: full, kicks off in 1h 24m.
      game(
        id: tonightGameId,
        format: GameFormat.fiveASide,
        venue: golCardiff,
        pitch: 'Pitch 1',
        startsAt: now.add(const Duration(hours: 1, minutes: 24, seconds: 36)),
        level: SkillLevel.intermediate,
        tags: [GameTag.mixed],
        pricePence: 800,
        players: [ray, ...pick(0, 9)],
      ),
      game(
        id: lastSpaceGameId,
        format: GameFormat.fiveASide,
        venue: golCardiff,
        pitch: 'Pitch 2',
        startsAt: at(1, 19),
        level: SkillLevel.intermediate,
        tags: [GameTag.mixed],
        pricePence: 800,
        players: pick(4, 9),
      ),
      game(
        id: 'g-102',
        format: GameFormat.sevenASide,
        venue: canton,
        pitch: 'Main cage',
        startsAt: at(1, 20),
        level: SkillLevel.beginner,
        tags: [GameTag.casual],
        pricePence: 600,
        players: pick(8, 8),
        organiser: people[10],
        organiserGamesRun: 56,
      ),
      game(
        id: 'g-103',
        format: GameFormat.fiveASide,
        venue: splott,
        pitch: 'Pitch 3',
        startsAt: at(2, 18, 30),
        level: SkillLevel.competitive,
        tags: [GameTag.competitive],
        pricePence: 700,
        players: pick(12, 6),
      ),
      game(
        id: 'g-104',
        format: GameFormat.sevenASide,
        venue: leckwith,
        pitch: 'Pitch 1',
        startsAt: at(3, 19),
        level: SkillLevel.intermediate,
        tags: [GameTag.mixed],
        pricePence: 600,
        players: pick(2, 14),
      ),
      game(
        id: 'g-105',
        format: GameFormat.fiveASide,
        venue: golCardiff,
        pitch: 'Pitch 4',
        startsAt: at(4, 20),
        level: SkillLevel.intermediate,
        tags: [GameTag.over30s, GameTag.casual],
        pricePence: 800,
        players: pick(15, 5),
        organiser: people[12],
        organiserGamesRun: 88,
      ),
      game(
        id: 'g-106',
        format: GameFormat.fiveASide,
        venue: leckwith,
        pitch: 'Pitch 2',
        startsAt: at(daysToSaturday() == 0 ? 7 : daysToSaturday(), 10),
        level: SkillLevel.beginner,
        tags: [GameTag.womens, GameTag.casual],
        pricePence: 600,
        players: pick(22, 4),
        organiser: people[23],
        organiserGamesRun: 31,
      ),
      game(
        id: 'g-108',
        format: GameFormat.sevenASide,
        venue: leckwith,
        pitch: 'Pitch 1',
        startsAt: at(daysToSaturday() == 0 ? 7 : daysToSaturday(), 18),
        level: SkillLevel.intermediate,
        tags: [GameTag.mixed],
        pricePence: 600,
        players: [ray, ...pick(6, 7)],
      ),
      // Bristol
      game(
        id: 'g-201',
        format: GameFormat.fiveASide,
        venue: templeQuay,
        pitch: 'Cage A',
        startsAt: at(1, 19, 30),
        level: SkillLevel.intermediate,
        tags: [GameTag.mixed],
        pricePence: 750,
        players: pick(3, 7),
        organiser: people[8],
        organiserGamesRun: 64,
      ),
      game(
        id: 'g-202',
        format: GameFormat.sevenASide,
        venue: eastville,
        pitch: 'Pitch 2',
        startsAt: at(2, 20),
        level: SkillLevel.competitive,
        tags: [GameTag.competitive],
        pricePence: 650,
        players: pick(9, 10),
        organiser: people[8],
        organiserGamesRun: 64,
      ),
      game(
        id: 'g-203',
        format: GameFormat.fiveASide,
        venue: ashton,
        pitch: 'Pitch 1',
        startsAt: at(3, 18),
        level: SkillLevel.beginner,
        tags: [GameTag.casual, GameTag.over30s],
        pricePence: 700,
        players: pick(18, 9),
        organiser: people[8],
        organiserGamesRun: 64,
      ),
    ];
  }

  /// Games that finished earlier today without a submitted result. Admin
  /// view only.
  static List<Game> finishedToday(DateTime now) => [
        Game(
          id: 'g-090',
          format: GameFormat.fiveASide,
          venue: canton,
          pitch: 'Main cage',
          startsAt: now.subtract(const Duration(hours: 3)),
          duration: const Duration(minutes: 60),
          level: SkillLevel.intermediate,
          tags: const [GameTag.mixed],
          pricePence: 700,
          players: pick(1, 10),
          organiser: people[10],
          organiserGamesRun: 56,
        ),
        Game(
          id: 'g-091',
          format: GameFormat.sevenASide,
          venue: eastville,
          pitch: 'Pitch 1',
          startsAt: now.subtract(const Duration(hours: 2)),
          duration: const Duration(minutes: 60),
          level: SkillLevel.beginner,
          tags: const [GameTag.casual],
          pricePence: 600,
          players: pick(5, 6),
          organiser: people[8],
          organiserGamesRun: 64,
        ),
      ];

  // History -----------------------------------------------------------------

  static MatchResult lastResult(DateTime now) => MatchResult(
        gameId: lastPlayedGameId,
        venueName: golCardiff.name,
        format: GameFormat.fiveASide,
        playedAt: now.subtract(const Duration(days: 7)),
        myTeam: Team.white,
        myScore: 7,
        theirScore: 5,
        goals: 3,
        assists: 2,
        potm: true,
      );

  static List<MatchResult> olderResults(DateTime now) => [
        MatchResult(
          gameId: 'g-095',
          venueName: leckwith.name,
          format: GameFormat.sevenASide,
          playedAt: now.subtract(const Duration(days: 11)),
          myTeam: Team.orange,
          myScore: 4,
          theirScore: 6,
          goals: 1,
          assists: 1,
          potm: false,
        ),
        MatchResult(
          gameId: 'g-093',
          venueName: splott.name,
          format: GameFormat.fiveASide,
          playedAt: now.subtract(const Duration(days: 16)),
          myTeam: Team.white,
          myScore: 5,
          theirScore: 5,
          goals: 2,
          assists: 0,
          potm: false,
        ),
      ];

  static const lastResultRewards = <Reward>[
    Reward(title: 'Player of the match', subtitle: 'Your 4th POTM award'),
    Reward(
      title: '4-week streak',
      subtitle: 'Kept alive for another week',
    ),
  ];

  /// Oldest first. The last item is the game above.
  static const form = <FormEntry>[
    FormEntry(goals: 1, assists: 1, won: true),
    FormEntry(goals: 0, assists: 2, won: false),
    FormEntry(goals: 1, assists: 0, won: true),
    FormEntry(goals: 2, assists: 1, won: true),
    FormEntry(goals: 0, assists: 0, won: false),
    FormEntry(goals: 1, assists: 1, won: true),
    FormEntry(goals: 3, assists: 0, won: true),
    FormEntry(goals: 2, assists: 0, won: false),
    FormEntry(goals: 1, assists: 1, won: false),
    FormEntry(goals: 3, assists: 2, won: true),
  ];

  /// Oldest first. The last item is the current week (not played yet).
  static const lastTwelveWeeks = <bool>[
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    false,
  ];

  static List<WalletEntry> walletEntries(DateTime now) => [
        WalletEntry(
          label: 'Welcome credit',
          type: WalletEntryType.reward,
          amountPence: 300,
          date: now.subtract(const Duration(days: 60)),
        ),
        WalletEntry(
          label: 'Refund · Canton cancelled',
          type: WalletEntryType.refund,
          amountPence: 600,
          date: now.subtract(const Duration(days: 30)),
        ),
        WalletEntry(
          label: 'Game booking · Splott 3G',
          type: WalletEntryType.booking,
          amountPence: -600,
          date: now.subtract(const Duration(days: 16)),
        ),
        WalletEntry(
          label: 'Referral · Sophie',
          type: WalletEntryType.referral,
          amountPence: 200,
          date: now.subtract(const Duration(days: 12)),
        ),
        WalletEntry(
          label: '20 games milestone',
          type: WalletEntryType.reward,
          amountPence: 250,
          date: now.subtract(const Duration(days: 11)),
        ),
      ];

  static const membershipBenefits = <String>[
    'No booking fees on any game',
    'Full stats: form, city rank and best venue',
    'Streak freeze once a month',
    'Double milestone rewards',
    'Early access to popular games',
  ];

  static const referrals = <ReferralEntry>[
    ReferralEntry(name: 'Sophie', stage: ReferralStage.rewarded),
    ReferralEntry(name: 'Josh', stage: ReferralStage.firstGame),
    ReferralEntry(name: 'Kieran', stage: ReferralStage.joined),
  ];
}
