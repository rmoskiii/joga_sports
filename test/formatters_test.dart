import 'package:flutter_test/flutter_test.dart';
import 'package:joga_sports/core/utils/formatters.dart';

void main() {
  group('Format.money', () {
    test('formats pence as pounds', () {
      expect(Format.money(800), '£8.00');
      expect(Format.money(650), '£6.50');
      expect(Format.money(-250), '−£2.50');
    });

    test('short form drops .00', () {
      expect(Format.moneyShort(800), '£8');
      expect(Format.moneyShort(650), '£6.50');
    });

    test('signed form', () {
      expect(Format.moneySigned(250), '+£2.50');
      expect(Format.moneySigned(-800), '−£8.00');
    });
  });

  group('Format dates', () {
    final now = DateTime(2026, 10, 6, 12); // a Tuesday

    test('relative day', () {
      expect(
          Format.relativeDay(DateTime(2026, 10, 6, 19), now: now), 'Tonight');
      expect(
          Format.relativeDay(DateTime(2026, 10, 7, 19), now: now), 'Tomorrow');
      expect(Format.relativeDay(DateTime(2026, 10, 9, 19), now: now), 'Fri');
    });

    test('countdown', () {
      expect(
        Format.countdown(const Duration(hours: 1, minutes: 24, seconds: 36)),
        '01 : 24 : 36',
      );
      expect(Format.countdown(const Duration(seconds: -5)), '00 : 00 : 00');
    });
  });
}
