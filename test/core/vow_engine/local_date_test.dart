import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

void main() {
  test('round-trips ISO dates', () {
    expect(LocalDate.parse('2027-11-16'), const LocalDate(2027, 11, 16));
    expect(const LocalDate(2027, 1, 5).toIso(), '2027-01-05');
  });

  test('rejects malformed and impossible dates', () {
    expect(() => LocalDate.parse('16-11-2027'), throwsFormatException);
    expect(() => LocalDate.parse('2027-02-30'), throwsFormatException);
  });

  test('adds days across month and year ends', () {
    expect(
      const LocalDate(2027, 11, 16).addDays(40),
      const LocalDate(2027, 12, 26),
    );
    expect(
      const LocalDate(2027, 12, 31).addDays(1),
      const LocalDate(2028, 1, 1),
    );
    expect(
      const LocalDate(2028, 3, 1).addDays(-1),
      const LocalDate(2028, 2, 29),
    );
  });

  test('counts whole days between dates', () {
    expect(
      const LocalDate(2027, 12, 26).daysSince(const LocalDate(2027, 11, 16)),
      40,
    );
    expect(
      const LocalDate(2027, 11, 15).daysSince(const LocalDate(2027, 11, 16)),
      -1,
    );
  });

  test('ignores the time of day', () {
    expect(
      LocalDate.fromDateTime(DateTime(2027, 11, 16, 23, 59)),
      const LocalDate(2027, 11, 16),
    );
  });
}
