import 'local_date.dart';

enum JourneyPhase { upcoming, active, complete }

/// Maps calendar dates to day numbers for one journey.
class JourneyClock {
  const JourneyClock({required this.startDate, required this.plannedDays})
    : assert(plannedDays > 0);

  final LocalDate startDate;
  final int plannedDays;

  LocalDate get lastDate => startDate.addDays(plannedDays - 1);

  JourneyPhase phaseOn(LocalDate today) {
    if (today.isBefore(startDate)) return JourneyPhase.upcoming;
    if (today.isAfter(lastDate)) return JourneyPhase.complete;
    return JourneyPhase.active;
  }

  /// The 1-based day number of [date], or null if it is outside the journey.
  int? dayNumberOn(LocalDate date) {
    final day = date.daysSince(startDate) + 1;
    return (day < 1 || day > plannedDays) ? null : day;
  }

  LocalDate dateOfDay(int dayNumber) {
    if (dayNumber < 1 || dayNumber > plannedDays) {
      throw RangeError.range(dayNumber, 1, plannedDays, 'dayNumber');
    }
    return startDate.addDays(dayNumber - 1);
  }

  int daysUntilStart(LocalDate today) =>
      today.isBefore(startDate) ? startDate.daysSince(today) : 0;

  /// Days that have begun, counting today. 0 before the start.
  int daysElapsedOn(LocalDate today) =>
      (today.daysSince(startDate) + 1).clamp(0, plannedDays);

  /// Share of the journey that has begun, from 0 to 1.
  double progressOn(LocalDate today) => daysElapsedOn(today) / plannedDays;
}
