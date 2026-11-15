import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

void main() {
  const start = LocalDate(2027, 11, 16);
  const clock = JourneyClock(startDate: start, plannedDays: 41);

  test('the last day of a 41-day journey is 40 days after the first', () {
    expect(clock.lastDate, const LocalDate(2027, 12, 26));
  });

  test('numbers days from 1 and returns null outside the journey', () {
    expect(clock.dayNumberOn(start), 1);
    expect(clock.dayNumberOn(const LocalDate(2027, 12, 26)), 41);
    expect(clock.dayNumberOn(const LocalDate(2027, 11, 15)), isNull);
    expect(clock.dayNumberOn(const LocalDate(2027, 12, 27)), isNull);
  });

  test('dateOfDay is the inverse of dayNumberOn', () {
    for (var day = 1; day <= 41; day++) {
      expect(clock.dayNumberOn(clock.dateOfDay(day)), day);
    }
    expect(() => clock.dateOfDay(0), throwsRangeError);
    expect(() => clock.dateOfDay(42), throwsRangeError);
  });

  test('reports the phase before, during and after', () {
    expect(clock.phaseOn(const LocalDate(2027, 11, 15)), JourneyPhase.upcoming);
    expect(clock.phaseOn(start), JourneyPhase.active);
    expect(clock.phaseOn(const LocalDate(2027, 12, 26)), JourneyPhase.active);
    expect(clock.phaseOn(const LocalDate(2027, 12, 27)), JourneyPhase.complete);
  });

  test('progress runs from 0 before the start to 1 on the last day', () {
    expect(clock.progressOn(const LocalDate(2027, 11, 10)), 0);
    expect(clock.progressOn(start), closeTo(1 / 41, 1e-9));
    expect(clock.progressOn(const LocalDate(2027, 12, 26)), 1);
    expect(clock.progressOn(const LocalDate(2028, 1, 30)), 1);
  });

  test('counts the days until the start', () {
    expect(clock.daysUntilStart(const LocalDate(2027, 11, 13)), 3);
    expect(clock.daysUntilStart(start), 0);
  });
}
