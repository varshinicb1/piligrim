import 'journey_clock.dart';
import 'local_date.dart';
import 'observance_template.dart';

/// What the devotee recorded on one day, reduced to what the engine needs.
class DayRecord {
  const DayRecord({
    required this.date,
    required this.keptVowIds,
    this.hasReflection = false,
  });

  final LocalDate date;
  final Set<String> keptVowIds;
  final bool hasReflection;

  bool get isCheckedIn => keptVowIds.isNotEmpty || hasReflection;
}

/// Counts for a journey so far. There is deliberately no streak and no
/// "failed" state: a missed day is met with comfort, never shame.
class JourneySummary {
  const JourneySummary({
    required this.phase,
    required this.daysElapsed,
    required this.daysCheckedIn,
    required this.vowsKept,
    required this.missedDays,
  });

  final JourneyPhase phase;
  final int daysElapsed;
  final int daysCheckedIn;
  final int vowsKept;

  /// Days in a row, ending yesterday, with nothing recorded. 0 on day 1 and
  /// outside an active journey. The companion comforts when this is above 0.
  final int missedDays;
}

JourneySummary summarizeJourney({
  required JourneyClock clock,
  required ObservanceTemplate template,
  required LocalDate today,
  required Iterable<DayRecord> records,
}) {
  final vowIds = template.vows.map((vow) => vow.id).toSet();
  final inJourney = [
    for (final record in records)
      if (clock.dayNumberOn(record.date) != null && record.isCheckedIn) record,
  ];
  final checkedInDates = inJourney.map((record) => record.date).toSet();
  final phase = clock.phaseOn(today);
  var missedDays = 0;
  if (phase == JourneyPhase.active) {
    var date = today.addDays(-1);
    while (clock.dayNumberOn(date) != null && !checkedInDates.contains(date)) {
      missedDays++;
      date = date.addDays(-1);
    }
  }

  return JourneySummary(
    phase: phase,
    daysElapsed: clock.daysElapsedOn(today),
    daysCheckedIn: checkedInDates.length,
    vowsKept: inJourney.fold(
      0,
      (sum, record) => sum + record.keptVowIds.intersection(vowIds).length,
    ),
    missedDays: missedDays,
  );
}
