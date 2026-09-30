/// Formatting helpers for money, dates and durations.
///
/// Kept dependency-free on purpose. Swap for `intl` if localisation is
/// needed later.
abstract final class Format {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _longDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 800 -> "£8.00"
  static String money(int pence) {
    final sign = pence < 0 ? '−' : '';
    final abs = pence.abs();
    final pounds = abs ~/ 100;
    final rem = (abs % 100).toString().padLeft(2, '0');
    return '$sign£$pounds.$rem';
  }

  /// 800 -> "£8", 650 -> "£6.50"
  static String moneyShort(int pence) =>
      pence % 100 == 0 ? '£${pence ~/ 100}' : money(pence);

  /// 250 -> "+£2.50", -800 -> "−£8.00"
  static String moneySigned(int pence) =>
      pence >= 0 ? '+${money(pence)}' : money(pence);

  /// 19:30
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Tue
  static String weekday(DateTime d) => _days[d.weekday - 1];

  /// Tuesday
  static String weekdayLong(DateTime d) => _longDays[d.weekday - 1];

  /// 7 Oct
  static String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// Tue 7 Oct
  static String shortDate(DateTime d) => '${weekday(d)} ${dayMonth(d)}';

  /// "Tonight", "Tomorrow", or "Thu".
  static String relativeDay(DateTime d, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final diff = _dateOnly(d).difference(today).inDays;
    if (diff == 0) return 'Tonight';
    if (diff == 1) return 'Tomorrow';
    return weekday(d);
  }

  /// "2 days to go", "Today"
  static String daysToGo(DateTime d, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final diff = _dateOnly(d).difference(today).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '$diff days to go';
  }

  /// 4:59
  static String minutesSeconds(Duration d) {
    final s = d.inSeconds.clamp(0, 359999);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  /// 01 : 24 : 36
  static String countdown(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(s ~/ 3600)} : ${two((s % 3600) ~/ 60)} : ${two(s % 60)}';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
