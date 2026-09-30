import 'enums.dart';
import 'person.dart';

enum LeaderboardMetric {
  goals('Goals'),
  assists('Assists'),
  potm('POTM'),
  streak('Streak');

  const LeaderboardMetric(this.label);
  final String label;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.position,
    required this.person,
    required this.value,
    required this.isMe,
  });

  final int position;
  final Person person;
  final int value;
  final bool isMe;
}

class Leaderboard {
  const Leaderboard({
    required this.city,
    required this.metric,
    required this.monthLabel,
    required this.entries,
    required this.prize,
  });

  final City city;
  final LeaderboardMetric metric;
  final String monthLabel;
  final List<LeaderboardEntry> entries;
  final String prize;
}

enum ReferralStage {
  joined('Joined'),
  firstGame('First game'),
  rewarded('£2 reward');

  const ReferralStage(this.label);
  final String label;
}

class ReferralEntry {
  const ReferralEntry({required this.name, required this.stage});

  final String name;
  final ReferralStage stage;
}

class Referrals {
  const Referrals({
    required this.code,
    required this.rewardPence,
    required this.entries,
  });

  final String code;
  final int rewardPence;
  final List<ReferralEntry> entries;
}
