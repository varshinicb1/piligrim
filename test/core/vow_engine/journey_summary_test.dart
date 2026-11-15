import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

void main() {
  const start = LocalDate(2027, 11, 16);
  const clock = JourneyClock(startDate: start, plannedDays: 41);
  const template = ObservanceTemplate(
    id: 't',
    version: '1',
    tradition: 'test',
    minDays: 41,
    defaultDays: 41,
    maxDays: 60,
    vows: [
      VowDefinition(id: 'a'),
      VowDefinition(id: 'b'),
    ],
    milestones: [
      MilestoneDefinition(
        id: 'first',
        anchor: MilestoneAnchor.start,
        offsetDays: 0,
      ),
      MilestoneDefinition(
        id: 'eve',
        anchor: MilestoneAnchor.end,
        offsetDays: -1,
      ),
    ],
    mascotTheme: 'none',
  );

  JourneySummary summarize(LocalDate today, List<DayRecord> records) =>
      summarizeJourney(
        clock: clock,
        template: template,
        today: today,
        records: records,
      );

  test('counts checked-in days and kept vows, ignoring unknown vows', () {
    final summary = summarize(start.addDays(2), [
      DayRecord(date: start, keptVowIds: {'a', 'b'}),
      DayRecord(date: start.addDays(1), keptVowIds: {'a', 'retired_vow'}),
      DayRecord(date: start.addDays(2), keptVowIds: {}, hasReflection: true),
    ]);
    expect(summary.daysElapsed, 3);
    expect(summary.daysCheckedIn, 3);
    expect(summary.vowsKept, 3);
    expect(summary.missedDays, 0);
  });

  test('an entry with nothing ticked and no note is not a check-in', () {
    final summary = summarize(start, [DayRecord(date: start, keptVowIds: {})]);
    expect(summary.daysCheckedIn, 0);
  });

  test('ignores records outside the journey', () {
    final summary = summarize(start, [
      DayRecord(date: start.addDays(-1), keptVowIds: {'a'}),
    ]);
    expect(summary.daysCheckedIn, 0);
    expect(summary.vowsKept, 0);
  });

  test('day 1 has no missed days', () {
    expect(summarize(start, []).missedDays, 0);
  });

  test('counts the run of unrecorded days that ends yesterday', () {
    expect(summarize(start.addDays(1), []).missedDays, 1);
    expect(summarize(start.addDays(5), []).missedDays, 5);
    expect(
      summarize(start.addDays(5), [
        DayRecord(date: start.addDays(2), keptVowIds: {'a'}),
      ]).missedDays,
      2,
    );
    expect(
      summarize(start.addDays(5), [
        DayRecord(date: start.addDays(4), keptVowIds: {'a'}),
      ]).missedDays,
      0,
    );
  });

  test('today being unrecorded is not a missed day', () {
    final summary = summarize(start.addDays(1), [
      DayRecord(date: start, keptVowIds: {'a'}),
    ]);
    expect(summary.missedDays, 0);
  });

  test('there are no missed days before or after the journey', () {
    expect(summarize(start.addDays(-3), []).missedDays, 0);
    expect(summarize(start.addDays(41), []).missedDays, 0);
  });

  test('places milestones from the start and from the end', () {
    expect(template.milestonesOnDay(1, 41).single.id, 'first');
    expect(template.milestonesOnDay(40, 41).single.id, 'eve');
    expect(template.milestonesOnDay(47, 48).single.id, 'eve');
    expect(template.milestonesOnDay(20, 41), isEmpty);
  });
}
